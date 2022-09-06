def test_start():
    pass


def test_succeed():
    pass


e_start = {
    "version": "0",
    "id": "3b5e71b2-ebbf-bc76-5609-98da197e03ea",
    "detail-type": "CodePipeline Pipeline Execution State Change",
    "source": "aws.codepipeline",
    "account": "361658082066",
    "time": "2022-09-06T15:06:48Z",
    "region": "us-east-1",
    "resources": [
        "arn:aws:codepipeline:us-east-1:361658082066:sfc-cci-brad-cicd-ecs-sfc-cci-brad-content-service"
    ],
    "detail": {
        "pipeline": "sfc-cci-brad-cicd-ecs-sfc-cci-brad-content-service",
        "execution-id": "354da29a-83d4-4537-ac61-0ba134e3316c",
        "execution-trigger": {
            "trigger-type": "ChangeAutomation",
            "trigger-detail": "s3",
        },
        "state": "STARTED",
        "version": 4.0,
    },
}

e_succeded = {
    "version": "0",
    "id": "308a3b80-59aa-27a2-e209-aceaedcfcfbb",
    "detail-type": "CodePipeline Pipeline Execution State Change",
    "source": "aws.codepipeline",
    "account": "361658082066",
    "time": "2022-09-06T15:15:08Z",
    "region": "us-east-1",
    "resources": [
        "arn:aws:codepipeline:us-east-1:361658082066:sfc-cci-brad-cicd-ecs-sfc-cci-brad-content-service"
    ],
    "detail": {
        "pipeline": "sfc-cci-brad-cicd-ecs-sfc-cci-brad-content-service",
        "execution-id": "354da29a-83d4-4537-ac61-0ba134e3316c",
        "state": "SUCCEEDED",
        "version": 4.0,
    },
}
