from builtins import LookupError, exit
from io import BytesIO
import os, boto3, json, tempfile, zipfile


# INPUT JSON EXAMPLE
# [
#     {
#         "ecs-task": "storefront-service",
#         "imageUri": "556085509259.dkr.ecr.us-east-1.amazonaws.com/storefront/service-storefront:0.3.0-develop"
#     },
#     {
#         "ecs-task": "producer-service",
#         "imageUri": "556085509259.dkr.ecr.us-east-1.amazonaws.com/storefront/service-producer:0.0.1-develop"
#     },
#     {
#         "s3-website": "order-site",
#         "artifact": "client-sfc-order",
#         "version": "0.0.1-develop"
#     },
#     {
#         "s3-website": "pickup-site",
#         "artifact": "client-sfc-pickup",
#         "version": "0.0.1-develop"
#     }
# ]


# MANUALLY INVOKE:
# aws lambda invoke \
#     --function-name arn:aws:lambda:us-east-1:849270710079:function:sf-dev-service-deploy out \
#     --payload '{"name": "sf-dev-storefront-service", "imageUri": "556085509259.dkr.ecr.us-east-1.amazonaws.com/storefront/service-storefront:0.2.0-rc.1"}' \
#     --log-type Tail --query 'LogResult' --output text --region us-east-1 |  base64 -D

# OUTPUT JSON EXAMPLE
# [
#   {
#     "name": "sf-dev-storefront-service",
#     "imageUri": "556085509259.dkr.ecr.us-east-1.amazonaws.com/storefront/service-storefront:0.2.0-rc.1"
#   }
# ]


def lambda_handler(event, context):
    target_bucket = os.environ['queue_target_bucket_name']
    source_bucket = os.environ['artifacts_source_bucket_name']
    name_prefix = os.environ['name_prefix']

    s3_client = boto3.client('s3')
    s3_resource = boto3.resource('s3')
    ecs_client = boto3.client('ecs')

    # Event must be in array format
    for item in event:
        if type(item) is dict:
            if 'ecs-task' in item.keys() and 'imageUri' in item.keys():
                family = f"{name_prefix}-{item['ecs-task']}"
                image_uri = item['imageUri']
                print(f"Preparing to update ECS Task {family}.")

                latest_revision = ecs_client.describe_task_definition(taskDefinition=family)
                existing_revision_arn = latest_revision['taskDefinition']['taskDefinitionArn']
                print(f"Retrieved current (latest) Task Definition for {family}: {existing_revision_arn}.")

                existing_revision = latest_revision['taskDefinition']
                container_definitions = existing_revision['containerDefinitions']
                container_definitions[0]['image'] = image_uri
                task_role_arn = existing_revision['taskRoleArn']
                execution_role_arn = existing_revision['executionRoleArn']
                network_mode = existing_revision['networkMode']
                volumes = existing_revision['volumes']
                placement_constraints = existing_revision['placementConstraints']
                requires_compatibilities = existing_revision['requiresCompatibilities']
                cpu = existing_revision['cpu']
                memory = existing_revision['memory']
                print(f"Updating Task Definition for {family} with new image: {image_uri}.")
                result = ecs_client.register_task_definition(
                    family=family,
                    taskRoleArn=task_role_arn,
                    executionRoleArn=execution_role_arn,
                    networkMode=network_mode,
                    containerDefinitions=container_definitions,
                    volumes=volumes,
                    placementConstraints=placement_constraints,
                    requiresCompatibilities=requires_compatibilities,
                    cpu=cpu,
                    memory=memory
                )
                print(f"Task Definition for {family} updated to: {result['taskDefinition']['taskDefinitionArn']}.")
                target_key = f"{family}.zip"
                zip_file_object = BytesIO()
                with zipfile.ZipFile(zip_file_object, mode="w", compression=zipfile.ZIP_DEFLATED) as zf:
                    filename = f"{family}.json"
                    zf.writestr(filename, "{}".encode('UTF'))
                    zf.close()
                    s3_client.put_object(Bucket=target_bucket, Key=target_key, Body=zip_file_object.getvalue())
                    print(f"{target_bucket}/{target_key} queued.")

            if 'ecs-service' in item.keys() and 'imageUri' in item.keys():
                service = f"{name_prefix}-{item['ecs-service']}"
                target_contents = [
                    {
                        "name": service,
                        "imageUri": item['imageUri']
                    }
                ]
                target_key = f"{service}.zip"
                print(f"Queuing for ECS deployment at {target_bucket}/{target_key}.")

                zip_file_object = BytesIO()
                with zipfile.ZipFile(zip_file_object, mode="w", compression=zipfile.ZIP_DEFLATED) as zf:
                    if target_key.endswith('.zip'):
                        filename = f"{target_key[:-4]}.json"
                        zf.writestr(filename, json.dumps(target_contents).encode('UTF'))
                        zf.close()
                        s3_client.put_object(Bucket=target_bucket, Key=target_key, Body=zip_file_object.getvalue())
                        print(f"{target_bucket}/{target_key} queued.")

            if 's3-website' in item.keys() and 'artifact' in item.keys() and 'version' in item.keys():
                source_key = f"{item['artifact']}/{item['version']}/{item['artifact']}-{item['version']}.zip"
                target_key = f"{name_prefix}-{item['s3-website']}.zip"
                print(f"Queuing {source_key} from bucket {source_bucket} to {target_bucket}/{target_key}.")

                source_tagging = s3_resource.BucketTagging(source_bucket)
                source_tagging.load()
                target_tagging = source_tagging.tag_set
                target_tagging.append({'Key': 'Version', 'Value': item['version']})
                target_tagging.append({'Key': 'Origin', 'Value': f"{source_bucket}/{source_key}"})

                copy_source = {'Bucket': source_bucket, 'Key': source_key}
                s3_client.copy_object(Bucket=target_bucket, Key=target_key, CopySource=copy_source)
                print(f"Tagging {target_key} with Version {item['version']} and Origin {source_bucket}/{source_key}.")
                s3_client.put_object_tagging(Bucket=target_bucket, Key=target_key, Tagging={'TagSet': target_tagging})

