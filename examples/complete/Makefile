
IMAGE    = nginx:latest
REGISTRY = 249974707517.dkr.ecr.us-east-1.amazonaws.com
REPO    ?= foo
TAG     ?= test

BUCKET = eg-test-artifacts
PREFIX = sites/
SITE  ?= oof

ecr-login:
	`aws ecr get-login --no-include-email --region us-east-1`

ecr-tag: ecr-login
	docker tag $(IMAGE) $(REGISTRY)/$(REPO):$(TAG)

ecr-push: ecr-tag
	docker push $(REGISTRY)/$(REPO):$(TAG)

site-push:
	echo 'Hello, World [$(TAG)]' > index.html
	zip $(SITE)-$(TAG).zip index.html
	aws s3 cp $(SITE)-$(TAG).zip s3://$(BUCKET)/sites/$(SITE)/$(SITE)-$(TAG).zip
	rm index.html
	rm $(SITE)-$(TAG).zip
