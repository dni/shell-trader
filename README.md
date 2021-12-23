# shell-trader CLI
#### for lnmarkets and maybe more exchanges
shellscript for interacting with lnmarkets.com

## todo
maybe do a ftx, if some1 is interested


## setup
clone the repository
```sh
 git clone https://github.com/dni/shell-trader
```
### setup lnmarkets CLI
make the script executable
```sh
  sudo chmod +x ~/repos/trading/shell-trader/lnm.sh
```
symlink the script to /usr/bin
```sh
  sudo ln -s ~/repos/trading/shell-trader/lnm.sh /usr/bin/lnm
```
setting up the enviroment variable
```sh
  cd ~/repos/trading/shell-trader
  mv .env.lnm.example .env.lnm
  $EDITOR .env.lnm
```

## usage

#### buy_limit / sell_limit
* required arguments: $qty, $leverage, $price
* optional arguments: $stoploss, $takeprofit
```sh
  lnm sell_limit $qty $leverage $price $stoploss $takeprofit
```

#### buy_market / sell_market
* required arguments: $qty, $leverage
* optional arguments: $stoploss, $takeprofit
```sh
  lnm buy_market $qty $leverage $stoploss $takeprofit
```

#### positions
```sh
  lnm positions
  lnm positions open
```

#### add_margin / take_profit
```sh
  lnm add_margin $pid $amount
  lnm take_profit $pid $amount
```

#### close/ cancel
```sh
  lnm close $pid
  lnm cancel $pid
```

#### close_all / cancel_all
```sh
  lnm close_all
  lnm cancel_all
```

#### ticker / index_history
```sh
  lnm ticker
  lnm index_history
```

#### user / balance
```sh
  lnm user
  lnm balance
```


