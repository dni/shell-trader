#/usr/bin/env sh
json_string=$(tail -n 1 signal-log.txt)
source ./.env

send_request() {
  method=$1
  path=$2
  ts=$(date +"%s")000
  signed_message=$(echo -n "$ts$method$path$json_string" | openssl dgst -sha256 -hmac $API_SECRET -binary | base64 )
  curl $API_ENDPOINT$path \
    --header "LNM-ACCESS-KEY: $API_KEY" \
    --header "LNM-ACCESS-PASSPHRASE: $API_PASSPHRASE" \
    --header "LNM-ACCESS-SIGNATURE: $signed_message" \
    --header "LNM-ACCESS-TIMESTAMP: $ts" \
    --header "Content-Type: application/json" \
    --request $method \
    --data "$json_string"
}

close_all() {
  send_request "DELETE" "/v1/futures/all/close"
}
cancel_all() {
  send_request "DELETE" "/v1/futures/all/cancel"
}
create_order() {
  send_request "POST" "/v1/futures"
}

create_order
# cancel_all
# close_all
