cur_tag=$(git tag | tail -1 | head -n1)
previous_tag=$(git tag | tail -2 | head -n1)
cur_tag_author=$(git show $cur_tag --no-patch)
cur_tag_date=$(git show $cur_tag --no-patch)
log=`git log $previous_tag`

summary="Test issue ${lastTag}"
desc="${cur_tag_author}:${cur_tag_date}:${cur_tag}"
unique="Test estasie/${lastTag}"
createTaskReqUrl="https://api.tracker.yandex.net/v2/issues/"

responseStatus=$(curl --write-out '%{http_code}' --silent --output /dev/null --location --request POST ${createTaskReqUrl} \
--header "Authorization: OAuth ${OAuth}" \
--header "X-Org-Id: ${OrganizationId}" \
--header 'Content-Type: application/json' \
--data-raw '{
    "queue": "TMP",
    "summary": "'"${summary}"'",
    "type": "task",
    "description": "'"${desc}"'",
    "unique": "'"${unique}"'"
}')

echo responseStatus