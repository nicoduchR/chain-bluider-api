const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const path = require('path');
const fs = require("fs-extra");
app.get('/', function (req, res) {
  res.send('Hello World!')
})
app.use(bodyParser.json());
app.get('/genesis', function (req, res) {

  let chainId = ((req.body.chainId != undefined) ? req.body.chainId : Math.floor(Math.random() * 10000) + 100 );
  let consensus = ((req.body.consensus != undefined) ? req.body.consensus : 'clique' );
  let timestamp = ((req.body.timestamp != undefined) ? req.body.timestamp : Date.now() );
  let extraData = ((req.body.extraData != undefined) ? req.body.extraData : '' );
  let gasLimit = ((req.body.gasLimit != undefined) ? req.body.gasLimit : "0x47b760" );
  let difficulty = ((req.body.difficulty != undefined) ? req.body.difficulty : "0x1" );
  let alloc = ((req.body.alloc != undefined) ? req.body.alloc : "7a54c3375e06f05e07866fa842e51c6811219e0d" );
  let period = ((req.body.period != undefined) ? req.body.period : 15 );
  
  let genesis = {
    "config":{
       "chainId": chainId,
       "homesteadBlock":0,
       "eip150Block":0,
       "eip150Hash":"0x0000000000000000000000000000000000000000000000000000000000000000",
       "eip155Block":0,
       "eip158Block":0,
       "byzantiumBlock":0,
       "constantinopleBlock":0,
       "petersburgBlock":0,
       "clique":{
          "period": period,
          "epoch":30000
       }
    },
    "nonce":"0x0",
    "timestamp": `${timestamp}`,
    "extraData": extraData,
    "gasLimit": gasLimit,
    "difficulty": difficulty,
    "mixHash":"0x0000000000000000000000000000000000000000000000000000000000000000",
    "coinbase":"0x0000000000000000000000000000000000000000",
    "alloc":{
       "7a54c3375e06f05e07866fa842e51c6811219e0d":{
          "balance":"0x200000000000000000000000000000000000000000000000000000000000000"
       },
    },
    "number":"0x0",
    "gasUsed":"0x0",
    "parentHash":"0x0000000000000000000000000000000000000000000000000000000000000000"
 }


  genesis = JSON.stringify(genesis);
  res.setHeader('Content-Type', 'application/json');
  res.end(genesis);
})


app.listen(3000, function () {
  console.log('Example app listening on port 3000!')
})