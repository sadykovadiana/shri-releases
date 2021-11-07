#! /usr/bin/bash

current_tag=$(git tag | sort -r | head -1)
taskID="estasie/$cur_tag"

authHeader="Authorization: OAuth ${OAuth}"
orgHeader="X-Org-Id: ${OrganizationId}"
contentType="Content-Type: application/json"

imageName="store_app:${current_tag}"

docker build . -f Dockerfile -t ${imageName}

if [ $? -ne 0 ]
then
    echo "ERROR: Cannot create docket image"
    exit 1
else
  taskKey=$(curl --silent --location --request POST https://api.tracker.yandex.net/v2/issues/_search \
    --header "${authHeader}" \
    --header "${orgHeader}" \
    --header "${contentType}" \
    --data-raw '{
      "filter": {
        "unique": "'"${taskID}"'"
      }
    }' | jq -r '.[0].key'
  )

  createCommentUrl="https://api.tracker.yandex.net/v2/issues/${taskKey}/comments"

  message="Docker image created: ${imageName}"

  createCommentStatusCode=$(curl --write-out '%{http_code}' --silent --output /dev/null --location --request POST \
    "${createCommentUrl}" \
    --header "${authHeader}" \
    --header "${orgHeader}" \
    --header "${contentType}" \
    --data-raw '{
      "text": "'"${message}"'"
    }'
  )

  if [ "$createCommentStatusCode" -ne 201 ]
  then
    echo "ERROR: cannot create comment for ${taskKey}"
    exit 1
  else
    echo ${message}
  fi
fi