#! /usr/bin/bash

current_tag=$(git tag | sort -r | head -1)
taskID="estasie/$cur_tag"

findExistingTask="https://api.tracker.yandex.net/v2/issues/_search"

authHeader="Authorization: OAuth ${OAuth}"
orgHeader="X-Org-Id: ${OrganizationId}"
contentType="Content-Type: application/json"

imageName="store_app:${current_tag}"


docker build . -f Dockerfile -t ${imageName}

if [ $? -ne 0 ]
then
    echo "ERROR: Cannot create docker image"
    exit 1
else
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

  createCommentUrl="https://api.tracker.yandex.net/v2/issues/${taskRequest}/comments"

  message="Docker image created: ${imageName}"

createComment=$(curl --write-out '%{http_code}' --silent --output /dev/null --location --request POST ${createCommentURL} \
        --header "${headerAuth}" \
        --header "${headerOrgID}" \
        --header "${contentType}" \
        --data-raw '{
            "text": "'"${message}"'"
         }')
echo $createComment
echo "Create new comment result: $createComment"
  if [ "$createComment" -ne 201 ]
  then
    echo "ERROR: cannot create comment for ${taskKey}"
    exit 1
  else
    echo ${message}
  fi
fi