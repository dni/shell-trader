#/usr/bin/env sh

dirname=$(dirname $(realpath "/usr/bin/lnm") )

# source env variable for api credentials
source $dirname/.env.lnm

# sanity check if all dependencies are met
if ! type "curl" 2> /dev/null > /dev/null; then
  echo "curl not installed" && exit
fi
if ! type "jq" 2> /dev/null > /dev/null; then
  echo "jq not installed" && exit
fi

send_request() {
  method=$1
  if [ "$method" == "GET" ] || [ "$method" == "DELETE" ]; then
    # path should not contain any params for signing
    path=$(echo $2 | cut -d "?" -f 1)
    echo $2 | grep -q "?" && params_or_json=$(echo $2 | cut -d "?" -f 2)
    # full path with arguments for url
    url=$API_ENDPOINT$2
  else
    # if its not a GET use the JSON
    path=$2
    params_or_json=$3
    url=$API_ENDPOINT$path
  fi

  # DEBUGGING :)
  # echo "params_or_json: $params_or_json"
  # echo "path: $path"
  # echo "url: $url"

  ts=$(date +"%s")000
  signed_message=$(echo -n "$ts$method$path$params_or_json" | openssl dgst -sha256 -hmac $API_SECRET -binary | base64 )
  if [ "$method" == "GET" ] || [ "$method" == "DELETE" ]; then
    curl $url -H "LNM-ACCESS-KEY: $API_KEY" -H "LNM-ACCESS-PASSPHRASE: $API_PASSPHRASE" \
      -H "LNM-ACCESS-SIGNATURE: $signed_message" -H "LNM-ACCESS-TIMESTAMP: $ts" \
      -H "Content-Type: application/json" --request "$method" 2>/dev/null | jq
  else
    curl $url -H "LNM-ACCESS-KEY: $API_KEY" -H "LNM-ACCESS-PASSPHRASE: $API_PASSPHRASE" \
      -H "LNM-ACCESS-SIGNATURE: $signed_message" -H "LNM-ACCESS-TIMESTAMP: $ts" \
      -H "Content-Type: application/json" --request "$method" --data "$params_or_json" 2>/dev/null | jq
  fi
}

positions() {
  if [ -z $1 ]; then
    value="running"
  else
    value=$1
  fi
  send_request "GET" "/v1/futures?type=$value"
}

close() {
  [[ -z $1 ]] && echo "required argument pid missing" && exit
  send_request "DELETE" "/v1/futures?pid=$1"
}
close_all() {
  send_request "DELETE" "/v1/futures/all/close"
}
cancel() {
  [[ -z $1 ]] && echo "required argument pid missing" && exit
  send_request "POST" "/v1/futures/cancel" '{"pid":"'$1'"}'
}
cancel_all() {
  send_request "DELETE" "/v1/futures/all/cancel"
}

add_margin() {
  [[ -z $1 ]] && echo "required argument pid missing" && exit
  [[ -z $2 ]] && echo "required argument amount missing" && exit
  send_request "POST" "/v1/futures/add-margin" '{"pid":"'$1'","amount":'$2'}'
}
take_profit() {
  [[ -z $1 ]] && echo "required argument pid missing" && exit
  [[ -z $2 ]] && echo "required argument amount missing" && exit
  send_request "POST" "/v1/futures/cash-in" '{"pid":"'$1'","amount":'$2'}'
}



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
  send_request "POST" "/v1/futures" '{'$stoploss$takeprofit$price'"type":"'$order_type'","side":"'$side'","quantity":'$qty',"leverage":'$leverage'}'
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
index_history() {
  send_request "GET" "/v1/futures/history/index?limit=1"
}
user() {
  send_request "GET" "/v1/user"
}
balance() {
  send_request "GET" "/v1/user" | grep balance | cut -d " " -f 4 | cut -d "," -f 1
}


"$@"
