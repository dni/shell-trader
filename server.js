const express = require('express');
const bodyParser = require('body-parser')
const app = express()
const jsonParser = bodyParser.json()
const port = 3000
const urlencodedParser = bodyParser.urlencoded({ extended: false })
const fs = require('fs');
const helmet = require('helmet');
app.use(helmet());

// use a list of allowed ips to post to our webhook
// TradingView Accesslist
const ips = [
  "::1",
  "127.0.0.1",
  "52.89.214.238",
  "34.212.75.30",
  "54.218.53.128",
  "52.32.178.7",
];

let auth = (req, res, done) => {
  if (ips.indexOf(req.ip) !== -1) {
    done();
  } else {
    console.log("warning status 403 send for ip: " + req.ip);
    return res.sendStatus(403);
  }
};

app.get('/webhook', auth, jsonParser, (req, res) => {

  // sample create request on futures
  let data = {
    "type": "m",
    "side": "b",
    "price": 10000,
    "stoploss": 9000,
    "takeprofit": 11000,
    "quantity": 1,
    "leverage": 10
  };

  let json = JSON.stringify(data) + "\n";
  fs.appendFile('signal-log.txt', json, function (err) {
    if (err) {
      console.log("could not write to log");
      return res.sendStatus(500);
    } else {
      res.send('Signal received!')
    }
  });
})

app.listen(port, () => {
  console.log(`Example app listening at http://localhost:${port}`)
})

