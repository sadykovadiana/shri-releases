#!/usr/bin/env

current_tag=$(git tag | sort -r | head -n1)
uniqueTag="estasie/$current_tag"

findExistingTask="https://api.tracker.yandex.net/v2/issues/_search"


headerAuth="Authorization: OAuth ${OAuth}"
headerOrgID="X-Org-Id: ${OrganizationId}"
contentType="Content-Type: application/json"

testRes=$(npm run test 2>&1  | tr -s "\n" " ")

taskRequest=$(curl --silent --location --request POST ${findExistingTask} \
        --header "${headerAuth}" \
        --header "${headerOrgID}" \
        --header "${contentType}" \
        --data-raw '{
            "filter": {
                "unique": "'"${uniqueTag}"'"
              }
         }' | jq -r '.[0].key')
echo "TASK ID: $taskRequest"

createCommentURL="https://api.tracker.yandex.net/v2/issues/${taskRequest}/comments"

comment="Tests:\n${testRes}"

createComment=$(curl --write-out '%{http_code}' --silent --output /dev/null --location --request POST ${createCommentURL} \
        --header "${headerAuth}" \
        --header "${headerOrgID}" \
        --header "${contentType}" \
        --data-raw '{
            "text": "'"${comment}"'"
         }')
echo $createComment

    echo "Create new comment result: $createComment"

    if [ $createComment = 201 ]; then
      echo "Added new comment TEST RESULT"
    elif [ $createComment = 404 ]; then
      echo "Cannot add new comment, task is not found"
    else
      echo "Checkout your request"
    fi
