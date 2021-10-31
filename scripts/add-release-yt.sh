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
    "unique": "'"${taskID}"'"
}')
if [ "$responseStatus" -eq 409 ]
    then
        echo "Cannot create task with the same release version"
        echo "Adding new comment then"
        getIssueId=$(curl --write-out '%{http_code' --silent --output /dev/null --location --request POST ${serchURL} \
        --header "Authorization: OAuth ${OAuth}" \
        --header "X-Org-Id: ${OrganisationID}" \
        --header "Content-Type: application/json" \
        --data-raw '{
                      "filter": {
                        "unique": "'${taskID}'"
                      },
        }')
        echo "$getIssueId"

elif [ "$responseStatus" -ne 201 ]
    then
        echo "ERROR: ${responseStatus}"
    else
        echo "Task added"
        echo "$responseStatus, $previous_tag"
fi