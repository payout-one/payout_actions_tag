#!/usr/bin/env bash
#GITHUB_EVENT_PATH="./event.json"

BUILD_NUMBER=$(jq '.target_url' < "$GITHUB_EVENT_PATH"  | sed 's/[^0-9]*//g')
echo $BUILD_NUMBER
git tag -a "1.1.${BUILD_NUMBER}"
