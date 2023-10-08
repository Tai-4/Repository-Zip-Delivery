DISCORD_EMBED_COLOR=7505882 # Color code: #7287DA
LINK_TO_USER_CONTENT="https://avatars.githubusercontent.com/"
DISCORD_WEBHOOK="https://discord.com/api/webhooks/1155130578753028097/SL4LvXXJRbn434h9EZCkxnz6EKfqiWHS1AKvOCKusjI9ctnQqwr4PAezYCjyjOvhFCfe"
LINK_TO_REPOSITORY_ARCHIVE="https://github.com/aleph-42/period_controller/archive"
LINK_TO_REPOSITORY_WORKFLOWS="https://github.com/aleph-42/period_controller/actions/run"

TAB=$(printf '\t')
US=$(printf '\037')
tsv_to_usv() {
  INPUT=$(cat)
  US_ESCAPED_INPUT=${INPUT//$US/\\\\037}
  USV=${US_ESCAPED_INPUT//$TAB/$US}
  echo "$USV"
}

COMMITS_JSON='[
  {
    "author": {
      "email": "ka1ntrk@gmail.com",
      "name": "Tai-4",
      "username": "Tai-4"
    },
    "committer": {
      "email": "ka1ntrk@gmail.com",
      "name": "Tai-4",
      "username": "Tai-4"
    },
    "distinct": true,
    "id": "cacf681a447e6decedffdecbd6c6130223323c97",
    "message": "test of \\n",
    "timestamp": "2023-09-29T18:42:12+09:00",
    "tree_id": "d0d069e05e262e0b800cbd7f0381a2c914ff74e0",
    "url": "https://github.com/aleph-42/period_controller/commit/cacf681a447e6decedffdecbd6c6130223323c97"
  },
  {
    "author": {
      "email": "ka1ntrk@gmail.com",
      "name": "Tai-4",
      "username": "Tai-4"
    },
    "committer": {
      "email": "ka1ntrk@gmail.com",
      "name": "Tai-4",
      "username": "Tai-4"
    },
    "distinct": true,
    "id": "75dde56866626695a991766152b784987938f6d9",
    "message": "chore: add bash_test and \\n test\n\ndescription is here\n\nhere is description",
    "timestamp": "2023-09-29T18:42:14+09:00",
    "tree_id": "a6fb70a8d5c32bede03dd21f8a691926cca60730",
    "url": "https://github.com/aleph-42/period_controller/commit/75dde56866626695a991766152b784987938f6d9"
  }
]'

build_commits_info() {
  jq -r '.[] | [.id, .url, .message] | @tsv' <<< $COMMITS_JSON | tsv_to_usv | {
    COMMITS_INFO=''
    while IFS=$US; read -r COMMIT_ID COMMIT_URL COMMIT_MESSAGE; do
      COMMIT_PARTIAL_ID=${COMMIT_ID:0:7}
      ZIP_FILE_LINK="$LINK_TO_REPOSITORY_ARCHIVE/$COMMIT_ID.zip"
      COMMIT_SUMMARY=${COMMIT_MESSAGE%%\\n\\n*}
      COMMIT_ROW="[\`$COMMIT_PARTIAL_ID\`]($COMMIT_URL) - [Download Zip]($ZIP_FILE_LINK)  |  $COMMIT_SUMMARY"
      COMMITS_INFO="$COMMITS_INFO$COMMIT_ROW\n"
    done
    COMMITS_INFO=${COMMITS_INFO%\\n}
    echo "$COMMITS_INFO"
  }
}

build_head_commit_info() {
  HEAD_COMMIT_ID="75dde56866626695a991766152b784987938f6d9"
  HEAD_COMMIT_PARTIAL_ID=${HEAD_COMMIT_ID:0:7}
  HEAD_COMMIT_URL="https://github.com/aleph-42/period_controller/commit/75dde56866626695a991766152b784987938f6d9"
  HEAD_COMMIT_ZIP_FILE_LINK="$LINK_TO_REPOSITORY_ARCHIVE/$HEAD_COMMIT_ID.zip"
  HEAD_COMMIT_INFO="The head commit is [\`$HEAD_COMMIT_PARTIAL_ID\`]($HEAD_COMMIT_URL), whose zip file is [here]($HEAD_COMMIT_ZIP_FILE_LINK) for download!"

  COMPARE_LINK="https://github.com/aleph-42/period_controller/compare/2a5620667515bf3448b8aec7d3a631d116eb841f...af21c877e50f286765ff998fd3470a98534a8d43"
  COMPARE_INFO="You can also check out the changes in this push, [here]($COMPARE_LINK) it comes."

  PUSH_INFO="$HEAD_COMMIT_INFO\n$COMPARE_INFO"
}

build_discord_embed_title() {
  REPOSITORY_OWNER_NAME='Tai-4'
  REPOSITORY_AND_OWNER_NAME='Tai-4/Raumy'
  REPOSITORY_NAME=${REPOSITORY_AND_OWNER_NAME#"$REPOSITORY_OWNER_NAME/"}
  DISCORD_EMBED_TITLE="[$REPOSITORY_NAME:main] Zip Delivery!"
}

build_webhook_json() {
  DISCORD_EMBED_DESCRIPTION="$PUSH_INFO\n\n$COMMITS_INFO"
  WEBHOOK_JSON=$(
    jq -n -c \
      --arg discord_embed_title "$DISCORD_EMBED_TITLE" \
      --arg discord_embed_description "$DISCORD_EMBED_DESCRIPTION" \
      '
      {
        "embeds": [
          {
            "title": $discord_embed_title,
            "description": $discord_embed_description
          }
        ]
      }
      '
  )
  WEBHOOK_JSON=$(echo -e $WEBHOOK_JSON)
}

post_webhook_json() {
  curl -X POST "$DISCORD_WEBHOOK" -H 'Content-Type: application/json' -d "$WEBHOOK_JSON"
}

COMMITS_INFO=$(build_commits_info)
build_head_commit_info
build_discord_embed_title
build_webhook_json
post_webhook_json
