FROM payout1/github_action:alpine

LABEL "name"="Payout Actions - Tag"
LABEL "maintainer"="Simple GitHub Actions for taging commits <tech@payout.one>"
LABEL "version"="1.0.0"

LABEL "com.github.actions.name"="Payout Actions"
LABEL "com.github.actions.description"="Simple GitHub Action to create tag by CircleCI build number "
LABEL "com.github.actions.icon"="feather-tag"
LABEL "com.github.actions.color"="purple"

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
