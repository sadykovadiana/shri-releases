#! /usr/bin/bash

cur_tag=$(git tag | tail -1 | head -n1)
taskID="estasie/$cur_tag"

echo "$cur_tag"

testResult=$(npx jest 2>&1 | tr -d ':' | tr "\r\n" " " )

  echo "$testResult"

  findTaskID=$(
    curl -s -X POST https://api.tracker.yandex.net/v2/issues/_search? \
    --header "Authorization: OAuth $OAuth" \
    --header "X-Org-Id: $OrganisationID" \
    --header "Content-Type: application/json" \
    --data-raw '{
    "filter": {
         "unique": "'$taskID'"
      }
    }' | jq -r '.[].id'
  )


    createNewComment=$(
    curl  -s -o dev/null -w '%{http_code}' -X POST https://api.tracker.yandex.net/v2/issues/${findTaskID}/comments \
    --header "Content-Type: application/json" \
    --header "Authorization: OAuth $OAuth" \
    --header "X-Org-Id: $OrganisationID" \
    --data-raw '{
        "text":"'"$testResult"'"
    }')

    echo "$createNewComment"

    if [ $createNewComment = 201 ]; then
      echo "Added new comment TEST RESULT"
    elif [ $createNewComment = 404 ]; then
      echo "Cannot add new comment, task is not found"
    else
      echo "Checkout your request"
    fi
