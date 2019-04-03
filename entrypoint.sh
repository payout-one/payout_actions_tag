#!/usr/bin/env bash

set -e

#GITHUB_EVENT_PATH="./event.json"
#GITHUB_SHA=ef8a9445243bb0113e5dade4e97b54aef1bb7aad

# Get build number from CircleCI url
BUILD_NUMBER=$(jq '.target_url' < "$GITHUB_EVENT_PATH"  | sed 's/[^0-9]*//g')

# Check if we get build number
if [ -z "BUILD_NUMBER" ]
then
      echo "No build number, no tag"
else
    # Create with arg and build number
    TAG="${1}${BUILD_NUMBER}"

    # Set git config
    git config --global user.email "tech@payout.one"
    git config --global user.name "Payout Github Actions"

    # Tag commit
    git tag -a $TAG $GITHUB_SHA -m "GitHub Actions automated tag ${BUILD_NUMBER}"
    # Push commit
    git push origin $TAG
fi
