#!/usr/bin/env bash

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
    echo "Refusing to deploy a pull request"
    exit
fi

if [ "${TRAVIS_BRANCH}" != "master" ]; then
    echo "Refusing to deploy non-master branch"
    exit
fi

docker tag deploy_test:$TRAVIS_BRANCH $DOCKER_SERVER/$DOCKER_REPOSITORY_NAME:$TRAVIS_BRANCH
docker push $DOCKER_SERVER/$DOCKER_REPOSITORY_NAME:$TRAVIS_BRANCH

VERSION="$TRAVIS_BRANCH"-"$TRAVIS_COMMIT"
ZIP="release.zip"
DOCKER_CREDENTIALS_FILE=".dockercfg"

for region in "us-east-1"; do
    echo "Deploying to $region"

    cp Dockerrun.aws.json Dockerrun.aws.json.back

    EB_BUCKET_NAME="elasticbeanstalk-$region-$AWS_ACCOUNT_ID"

    sed -i='' "s/<EB_BUCKET_NAME>/$EB_BUCKET_NAME/" Dockerrun.aws.json
    sed -i='' "s/<DOCKER_CREDENTIALS_FILE>/$DOCKER_CREDENTIALS_FILE/" Dockerrun.aws.json
    sed -i='' "s/<AWS_ACCOUNT_ID>/$AWS_ACCOUNT_ID/" Dockerrun.aws.json
    sed -i='' "s/<DOCKER_REPOSITORY_REGION>/$DOCKER_REPOSITORY_REGION/" Dockerrun.aws.json
    sed -i='' "s/<DOCKER_REPOSITORY_NAME>/$DOCKER_REPOSITORY_NAME/" Dockerrun.aws.json
    sed -i='' "s/<TRAVIS_BRANCH>/$TRAVIS_BRANCH/" Dockerrun.aws.json

    zip -r "$ZIP" .ebextensions Dockerrun.aws.json

    aws s3 cp ~/.docker/config.json s3://"$EB_BUCKET_NAME"/"$DOCKER_CREDENTIALS_FILE" --region "$region"
    eb deploy --region "$region"

    rm "$ZIP"
    cp Dockerrun.aws.json.back Dockerrun.aws.json
done

# cleanup
aws ecr list-images --region "$DOCKER_REPOSITORY_REGION" --repository-name "$DOCKER_REPOSITORY_NAME" --query 'imageIds[?type(imageTag)!=`string`].[imageDigest]' --output text | while read line; do aws ecr batch-delete-image --region "$DOCKER_REPOSITORY_REGION" --repository-name "$DOCKER_REPOSITORY_NAME" --image-ids imageDigest=$line; done
