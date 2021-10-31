#! /usr/bin/bash

cur_tag=$(git tag | sort -r | head -n1)
previous_tag=$(git tag | tail -2 | head -n1)
cur_tag_author=$(git show $cur_tag  --pretty=format:"Author: %an" --date=format:'%Y-%m-%d %H:%M:%S' --no-patch)
cur_tag_date=$(git show ${cur_tag} | grep Date:)
log=`git log $previous_tag`
desc=$(git log --pretty=format:"%h - %s (%an, %ar)\n" | tr -s "\n")

summary="$cur_tag: Estasie App update"
taskURL="https://api.tracker.yandex.net/v2/issues/"
taskID="estasie/$cur_tag"

echo "$taskID"
responseStatus=$(curl --write-out '%{http_code}' --silent --output /dev/null --location --request POST ${taskURL} \
--header "Authorization: OAuth ${OAuth}" \
--header "X-Org-Id: ${OrganizationId}" \
--header "Content-Type: application/json" \
--data-raw '{
    "queue": "TMP",
    "summary": "'"${summary}"'",
    "type": "task",
    "description": "'"${desc}"'",
    "unique": "'"${taskID}"'"
}')


if [ $responseStatus = 201 ]; then
  echo "Release created successfully"
elif [ $responseStatus = 404 ]; then
  echo "Not found"
elif [ $responseStatus = 409 ]; then
   echo "Cannot create task with the same release version"
   echo "Adding new comment then"
  headerAuth="Authorization: OAuth ${OAuth}"
  headerOrgID="X-Org-Id: ${OrganizationId}"
  contentType="Content-Type: application/json"
  findTaskID=$(curl --silent --location --request POST ${findExistingTask} \
        --header "${headerAuth}" \
        --header "${headerOrgID}" \
        --header "${contentType}" \
        --data-raw '{
            "filter": {
                "unique": "'"${uniqueTag}"'"
              }
         }' | jq -r '.[0].key')
echo "TASK ID: $findTaskID"

    echo "TASK ID: $findTaskID"

    updateTask=$(curl -s -o dev/null -w '%{http_code}' -X PATCH https://api.tracker.yandex.net/v2/issues/$taskID \
    --header "Content-Type: application/json" \
    --header "Authorization: OAuth $OAuth" \
    --header "X-Org-Id: $OrganizationId" \
    --data-raw '{
        "summary":"'"$summary"'",
        "description":"'"$description"'"
    }')

    if [ $updateTask -eq 200 ]; then
      echo "Task updated"
    elif [ $updateTask -eq 404 ]; then
      echo "Task not found :("
    else [ $updateTask -eq 409 ]
      echo "Checkout your request request"
    fi
  else
    echo "ERROR: $updateTask"
fi
