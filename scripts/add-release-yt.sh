#! /usr/bin/bash

cur_tag=$(git tag | sort -r | head -1)
previous_tag=$(git tag | sort -r | head -2 | tail -1)
cur_tag_author=$(git show ${cur_tag} | grep Author: )
cur_tag_date=$(git show ${cur_tag} | grep Date:)
log=`git log $previous_tag`

summary="Test issue ${cur_tag}"
description="${cur_tag_author}:${cur_tag_date}:${cur_tag}"
taskURL="https://api.tracker.yandex.net/v2/issues/"

responseStatus=$(curl --write-out '%{http_code}' --silent --output /dev/null --location --request POST ${taskURL} \
--header "Authorization: OAuth ${OAuth}" \
--header "X-Org-ID: ${OrganizationId}" \
--header "Content-Type: application/json" \
--data-raw '{
    Some text
}')



 if [ "$responseStatus" -ne 200 ]
    then
        echo "ERROR: ${responseStatus}"
        exit 1
    else
        echo "Task added"
        exit 0
    fi

