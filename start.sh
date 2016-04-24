#!/usr/bin/env bash

echo "tasks: $(curl -s `curl -s 169.254.169.254/latest/meta-data/local-ipv4`:51678/v1/tasks)"

export TASK_ID=$(curl -s `curl -s 169.254.169.254/latest/meta-data/local-ipv4`:51678/v1/tasks | jq --arg hostname $HOSTNAME '.Tasks[] | select(.Containers[].DockerId | contains($hostname)).Arn' | sed -n -e 's/^.*task\///p')
echo "TASK_ID: $TASK_ID"
npm start
