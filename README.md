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
#### ticker / index_history
```sh
  lnm ticker
  lnm index_history
```

