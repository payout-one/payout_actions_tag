#!/usr/bin/env bash

set -e

#GITHUB_EVENT_PATH="./event.json"
#GITHUB_SHA=ef8a9445243bb0113e5dade4e97b54aef1bb7aad

# Get build number from CircleCI url
BUILD_NUMBER=$(jq '.target_url' < "$GITHUB_EVENT_PATH"  | sed 's/[^0-9]*//g')
CONTEXT=$(jq '.context' < "$GITHUB_EVENT_PATH")

cat $GITHUB_EVENT_PATH
echo $BUILD_NUMBER
echo $CONTEXT
STATE=$(jq '.state' < "$GITHUB_EVENT_PATH" | tr -d \" )

# Check if CI/CD finished
if [[ "${STATE}" == "success" && "${CONTEXT}" != "\"ci/circleci: release\"" ]]
then
    # Check if we get build number
    if [[ -z "$BUILD_NUMBER" ]]
    then
          echo "No build number, no tag"
    else
        LAST_TAG=$(git describe --always --tags $GITHUB_SHA )
        echo $LAST_TAG
        if [[ ($LAST_TAG == *"test-"* || $LAST_TAG == *"qa-"* || $LAST_TAG == *"sandbox-"* ) && $LAST_TAG == *"${BUILD_NUMBER}" ]]
        then
            echo "Current build is for Test, QA or Sandbox env"
        else
            # Create with arg and build number
            TAG="${1}${BUILD_NUMBER}"
            echo $TAG
            # Set git config
            git config --global user.email "tech@payout.one"
            git config --global user.name "Payout Github Actions"
            git config --global github.user oliver-kriska
            git config --global github.token $GITHUB_TOKEN

            # Get commit message
            MESSAGE=$(git log --format=%B -n 1 $GITHUB_SHA)
            # Tag commit
            git tag -a $TAG $GITHUB_SHA -m "${MESSAGE}"
            # Push commit
            git push origin tag $TAG
        fi
    fi
else
    echo $STATE
    echo "CI/CD is not finished yet or it's release job"
fi
