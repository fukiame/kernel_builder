#!/bin/bash
#
# ...exists to not have ugly looking code blocks in ci lmao

case $1 in
  msg)
    curl -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
      -d chat_id="${CHAT_ID}" \
      -d "disable_web_page_preview=true" \
      -d "parse_mode=html" \
      -d text="$(echo "$2" | sed 's/%nl/\n/g')"
  ;;
  up | upload)
    curl -F chat_id="${CHAT_ID}" \
      -F document=@"$2" \
      -F parse_mode=html https://api.telegram.org/bot${BOT_TOKEN}/sendDocument \
      -F caption="$(echo "$3" | sed 's/%nl/\n/g')"
  ;;
esac
