#! /usr/bin/bash

cur_tag=$(git tag | tail -1 | head -n1)
taskID="estasie/$previous_tag"


testResult=$(npm run test 2>&1 | tr "\\\\\\\\" "/"| tr -s "\n" " ")

  findTaskID=$(
    curl -s -X POST https://api.tracker.yandex.net/v2/issues/_search? \
    --header "Content-Type: application/json" \
    --header "Authorization: OAuth $OAuth" \
    --header "X-Org-Id: $OrganisationID" \
    --data-raw '{
    "filter": {
         "unique":"'"$taskID"'"
      }
    }' | jq -r '.[].id'
  )


    createNewComment=$(
    curl  -s -o dev/null -w '%{http_code}' -X POST https://api.tracker.yandex.net/v2/issues/$taskID/comments \
    --header "Content-Type: application/json" \
    --header "Authorization: OAuth $OAuth" \
    --header "X-Org-Id: $OrganisationID" \
    --data-raw '{
        "text":"'"$testResult"'"
    }')

    if [ $createNewComment = 201 ]; then
      echo "Added new comment TEST RESULT"
    elif [ $createNewComment = 404 ]; then
      echo "Cannot add new comment, task is not found"
    else
      echo "Checkout your request"
    fi