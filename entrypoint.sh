#!/usr/bin/env bash

set -e

#GITHUB_EVENT_PATH="./event.json"
#GITHUB_SHA=ef8a9445243bb0113e5dade4e97b54aef1bb7aad

# Get build number from CircleCI url
BUILD_NUMBER=$(jq '.target_url' < "$GITHUB_EVENT_PATH"  | sed 's/[^0-9]*//g')
CONTEXT=$(jq '.context' < "$GITHUB_EVENT_PATH")
GIT_REFS_URL=$(jq .repository.git_refs_url $GITHUB_EVENT_PATH | tr -d '"' | sed 's/{\/sha}//g')

STATE=$(jq '.state' < "$GITHUB_EVENT_PATH" | tr -d \" )

# Check if CI/CD finished
if [[ "${STATE}" == "success" && "${CONTEXT}" != "\"ci/circleci: release\"" ]]
then
    # Check if we get build number
    if [[ -z "$BUILD_NUMBER" ]]
    then
          echo "No build number, no tag"
    else
        COMMIT=$(git rev-parse HEAD)
        LAST_TAG=$(git describe --always --tags ${COMMIT} )
        echo ${LAST_TAG}
        if [[ (${LAST_TAG} == *"test-"* || $LAST_TAG == *"qa-"* || ${LAST_TAG} == *"sandbox-"* ) && ${LAST_TAG} == *"${BUILD_NUMBER}" ]]
        then
            echo "Current build is for Test, QA or Sandbox env"
        else
            # Create with arg and build number
            TAG="${1}${BUILD_NUMBER}"
            echo ${TAG}
            echo ${COMMIT}

            # Tag commit
            DATA="{\"ref\":\"refs/tags/$TAG\",\"sha\":\"$COMMIT\"}"
            echo ${DATA}

            curl -s -X POST ${GIT_REFS_URL} -H "Authorization: token $GITHUB_TOKEN" -d ${DATA}
        fi
    fi
else
    echo ${STATE}
    echo "CI/CD is not finished yet or it's release job"
fi
