#! /usr/bin/bash

cur_tag=$(git tag | tail -1 | head -n1)
previous_tag=$(git tag | tail -2 | head -n1)
cur_tag_author=$(git show $cur_tag  --pretty=format:"Author: %an" --date=format:'%Y-%m-%d %H:%M:%S' --no-patch)
cur_tag_date=$(git show ${cur_tag} | grep Date:)
log=`git log $previous_tag`
desc=$(git log --pretty=format:"%h - %s (%an, %ar)\n" | tr -s "\n")

summary="$cur_tag: Estasie App update"
description="${cur_tag_author}:${cur_tag_date}:${cur_tag}"
taskURL="https://api.tracker.yandex.net/v2/issues/"
taskID="Unique/estasie/$cur_tag"

responseStatus=$(curl --write-out '%{http_code}' --silent --output /dev/null --location --request POST ${taskURL} \
--header "Authorization: OAuth ${OAuth}" \
--header "X-Org-Id: ${OrganizationId}" \
--header "Content-Type: application/json" \
--data-raw '{
    "queue": "TMP",
    "summary": "'"${summary}"'",
    "type": "task",
    "description": "'"${desc}"'",
    "taskID": "'"${taskID}"'"
}')
if [ "$responseStatus" -ne 201 ]
    then
        echo "ERROR: ${responseStatus}"
    else
        echo "Task added"
        echo "$cur_tag, $previous_tag"
fi

getTaskId=$(curl --silent --location --request POST "https://api.tracker.yandex.net/v2/issues/_search" \
--header "Authorization: OAuth ${OAuth}" \
--header "X-Org-Id: ${OrganizationId}" \
--header "Content-Type: application/json" \
    --data-raw '{
        "filter": {
            "taskID": "'"${taskID}"'"
        }
    }' | jq -r '.[0].key'
)


if [ "$responseStatus" -eq 409 ]
then
    echo "Version duplicate, creating comment"
    getCommentStatusRequest=$(curl --write-out '%{http_code}' --silent --output /dev/null --location --request PATCH \
        "https://api.tracker.yandex.net/v2/issues/${getTaskId}" \
        --header "${authHeader}" \
        --header "${orgHeader}" \
        --header "${contentType}" \
        --data-raw '{
            "summary": "'"${updatingSummary}"'",
            "description": "'"${description}"'"
        }'
    )

    if [ "$getCommentStatusRequest" -ne 200 ]
    then
        echo "ERROR: CANNOT UPDATE ${taskKey}"
        exit 1
    else
        echo "SUCCSESS: ${taskKey} UPDATED"
    fi

