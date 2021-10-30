cur_tag=$(git tag | tail -1 | head -n1)
previous_tag=$(git tag | tail -2 | head -n1)
cur_tag_author=$(git show $CURRENT_TAG_NAME --no-patch)
cur_tag_date=$(git show $CURRENT_TAG_NAME --no-patch)
log=`git log $PREVIOUS_TAG_NAME`

summary="Test issue ${lastTag}"
desc="${cur_tag_author}:${cur_tag_date}:${cur_tag}"
getTaskReqUrl="https://api.tracker.yandex.net/v2/issues/_search"
createTaskReqUrl="https://api.tracker.yandex.net/v2/issues/"
updateTaskReqUrl="https://api.tracker.yandex.net/v2/issues/"

response=$(curl --write-out '%{http_code}' --silent --output /dev/null --location --request POST ${createTaskReqUrl} \
--header "Authorization: OAuth ${YCAUTH}" \
--header "X-Org-Id: ${YCID}" \
--header 'Content-Type: application/json' \
--data-raw '{
    "queue": "TMP",
    "summary": "'"${summary}"'",
    "type": "task",
    "description": "'"${desc}"'",
}')

if [ "$req" -ne 201 ]
then
    echo "ERROR: Cannot create release task"
    exit 1
else
    echo "Task had been created ^_^"
    exit 0
fi