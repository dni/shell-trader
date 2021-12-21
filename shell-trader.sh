#/usr/bin/env sh
data=$(tail -n 1 data.txt)
price=$(cut -d "," -f 1)
order_type=$(cut -d "," -f 2)
side=$(cut -d "," -f 3)

close_all() {
  send_request "DELETE" "/v1/futures/all/close"
}
cancel_all() {
  send_request "DELETE" "/v1/futures/all/cancel"
}

send_test() {
  send_request "POST" "/v1/futures" '{"type":"l","side":"b","price":40000,"quantity":1,"leverage":10}'
}


# sample create request on futures
#{
#
#    "type": "l", market or limit order
#    "side": "b", buy and sell
#    "price": 10000,
#    "stoploss": 9000,
#    "takeprofit": 11000,
#    "quantity": 100,
#    "leverage": 50
#
#}

send_request() {
  method=$1
  path=$2
  json_string=$3
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

source ./.env
send_test
# close_all
cancel_all
#send_request "GET" "/v1/futures/ticker"




