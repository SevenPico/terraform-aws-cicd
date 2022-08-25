#!/bin/bash

image=nginx:latest
repo=249974707517.dkr.ecr.us-east-1.amazonaws.com/example-foo
tag=latest

$(aws ecr get-login --no-include-email --region us-east-1)
docker tag $image $repo:$tag
docker push $repo:$tag
