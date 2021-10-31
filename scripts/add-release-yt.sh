#! /usr/bin/bash

cur_tag=$(git tag | tail -1 | head -n1)
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

taskIDREQUEST=$(curl --silent --location --request POST ${taskURL} \
   --header "Authorization: OAuth ${OAuth}" \
--header "X-Org-Id: ${OrganizationId}" \
--header "Content-Type: application/json" \
    --data-raw '{
        "filter": {
            "unique": "'"${taskID}"'"
        }
    }' | jq -r '.[0].key'
)
if [ "$responseStatus" -eq 409 ]
then
    echo "Duplicated tasks"
    getStatusReq=$(curl --write-out '%{http_code}' --silent --output /dev/null --location --request PATCH "${taskURL}${taskIDREQUEST}"\
        --header "Authorization: OAuth ${OAuth}" \
        --header "X-Org-Id: ${OrganizationId}" \
        --header "Content-Type: application/json" \
        --data-raw '{
            "summary": "'"${summary}"'",
            "description": "'"${desc}"'"
        }'
    )

    if [ "$getStatusReq" -ne 200 ]
    then
        echo "Cannot update task"
        exit 1
    else
        echo "Task updated"
    fi

elif [ "$createStatusCode" -ne 201 ]
then
    echo "Cannot create task"
    exit 1
else
    echo "New release task created"
fi

newCommentURL="https://api.tracker.yandex.net/v2/issues/${taskIDREQUEST}/comments"

createNewCommentReq=$(curl --write-out '%{http_code}' --silent --output /dev/null --location --request POST "${newCommentURL}" \
        --header "Authorization: OAuth ${OAuth}" \
        --header "X-Org-Id: ${OrganizationId}" \
        --header "Content-Type: application/json" \
         --data-raw '{
            "text": "'"${log}"'",
        }'
)

if [ "$createNewCommentReq" -ne 201 ]
then
    echo "Cannot create new comment"
    exit 1
else
    echo "Comment had been created in ${taskIDREQUEST}"
fi