#!/usr/bin/env bash

if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
    docker tag ipinfo:$TRAVIS_BRANCH $DOCKER_SERVER/$DOCKER_REPOSITORY_NAME:$TRAVIS_BRANCH
    docker push $DOCKER_SERVER/$DOCKER_REPOSITORY_NAME:$TRAVIS_BRANCH

    VERSION="$TRAVIS_BRANCH"-"$TRAVIS_COMMIT"
    ZIP="$VERSION".zip
    DOCKER_CREDENTIALS_FILE=".dockercfg"

    aws configure set default.region "$DOCKER_REPOSITORY_REGION"

    sed -i='' "s/<EB_BUCKET_NAME>/$EB_BUCKET_NAME/" Dockerrun.aws.json
    sed -i='' "s/<DOCKER_CREDENTIALS_FILE>/$DOCKER_CREDENTIALS_FILE/" Dockerrun.aws.json
    sed -i='' "s/<AWS_ACCOUNT_ID>/$AWS_ACCOUNT_ID/" Dockerrun.aws.json
    sed -i='' "s/<DOCKER_REPOSITORY_REGION>/$DOCKER_REPOSITORY_REGION/" Dockerrun.aws.json
    sed -i='' "s/<DOCKER_REPOSITORY_NAME>/$DOCKER_REPOSITORY_NAME/" Dockerrun.aws.json
    sed -i='' "s/<TRAVIS_BRANCH>/$TRAVIS_BRANCH/" Dockerrun.aws.json

    zip -r "$ZIP" .ebextensions Dockerrun.aws.json

    aws s3 cp "$ZIP" s3://"$EB_BUCKET_NAME"/"$ZIP"
    aws s3 cp ~/.docker/config.json s3://"$EB_BUCKET_NAME"/"$DOCKER_CREDENTIALS_FILE"

    aws elasticbeanstalk create-application-version --application-name "$EB_APP_NAME" --version-label "$VERSION" --source-bundle S3Bucket="$EB_BUCKET_NAME",S3Key="$ZIP" --region "us-west-2"
    aws elasticbeanstalk update-environment --environment-name "$EB_ENV_NAME" --version-label "$VERSION" --region "us-west-2"
else
    echo "Pull request in $TRAVIS_BRANCH"
fi


