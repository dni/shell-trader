#/usr/bin/env sh

# source env variable for api credentials
source ./.env

# sanity check if all dependencies are met
if ! type "curl" 2> /dev/null > /dev/null; then
  echo "curl not installed" && exit
fi
if ! type "jq" 2> /dev/null > /dev/null; then
  echo "jq not installed" && exit
fi

send_request() {
  method=$1
  if [ "$method" == "GET" ]; then
    # path should not contain any params for signing
    path=$(echo $2 | cut -d "?" -f 1)
    params_or_json=$(echo $2 | grep "?" && cut -d "?" -f 2)
    url=$API_ENDPOINT$2
  else
    # if its not a GET use the JSON
    path=$2
    params_or_json=$3
    url=$API_ENDPOINT$path
  fi

  # DEBUGGING :)
  # echo "path: $path"
  # echo "params_or_json: $params_or_json"
  # echo "url: $url"

  ts=$(date +"%s")000
  signed_message=$(echo -n "$ts$method$path$params_or_json" | openssl dgst -sha256 -hmac $API_SECRET -binary | base64 )

  curlcmd="curl $url --header 'LNM-ACCESS-KEY: $API_KEY' --header 'LNM-ACCESS-PASSPHRASE: $API_PASSPHRASE' \
    --header 'LNM-ACCESS-SIGNATURE: $signed_message' --header 'LNM-ACCESS-TIMESTAMP: $ts' \
    --header 'Content-Type: application/json' --request $method"

  if [ "$method" == "GET" ]; then
    $curlcmd 2>/dev/null | jq
  else
    $curlcmd --data "$params_or_json" 2>/dev/null | jq
  fi
}

trade_history() {
  if [ -z $1 ]; then
    value="running"
  else
    value=$1
  fi
  send_request "GET" "/v1/futures?type=$value"
}

# update_order() {
# # Allows user to modify stoploss or takeprofit parameters of an existing position.
# # {
# #     "pid": "b87eef8a-52ab-2fea-1adc-c41fba870b0f",
# #     "type": "takeprofit",
# #     "value": 13290.5
# # }
# }


create_order() {
  order_type=$1 # m or l, market or limit
  side=$2
  qty=$3
  leverage=$4
  [[ -z $order_type ]] && echo "required argument type missing" && exit
  [[ -z $side ]] && echo "required argument side missing" && exit
  [[ -z $qty ]] && echo "required argument qty missing" && exit
  [[ -z $leverage ]] && echo "required argument leverage missing" && exit
  if [ "$order_type" == "l" ]; then
    price=$5
    [[ -z $price ]] && echo "required argument price missing" && exit
    stoploss=$6
    takeprofit=$7
  fi
  if [ "$order_type" == "m" ]; then
    stoploss=$5
    takeprofit=$6
  fi
  [[ -z $price ]] || price='"price":'$price','
  [[ -z $stoploss ]] || stoploss='"stoploss":'$stoploss','
  [[ -z $takeprofit ]] || takeprofit='"takeprofit":'$takeprofit','
  echo '{'$stoploss$takeprofit$price'"type":"'$order_type'","side":"'$side'","quantity":'$qty',"leverage":'$leverage'}'
  # send_request "POST" "/v1/futures" '{'$stoploss$takeprofit$price'"type":"'$order_type'","side":"'$side'","quantity":'$qty',"leverage":'$leverage'}'
}
limit() {
  create_order "l" $@
}
market() {
  create_order "m" $@
}
buy_limit() {
  limit "b" $@
}
buy_market() {
  market "b" $@
}
sell_limit() {
  limit "s" $@
}
sell_market() {
  market "s" $@
}
ticker() {
  send_request "GET" "/v1/futures/ticker"
}
close_all() {
  send_request "DELETE" "/v1/futures/all/close"
}
cancel_all() {
  send_request "DELETE" "/v1/futures/all/cancel"
}

"$@"
