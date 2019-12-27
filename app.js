const express = require('express');
const app = express();
const bodyParser = require('body-parser');
const path = require('path');
const fs = require("fs-extra");
app.get('/', function (req, res) {
  res.send('Hello World!')
})
app.use(bodyParser.json());
app.post('/genesis', function (req, res) {

  let chainId = req.body.chainId;
  let consensus = req.body.consensus;
  let timestamp = req.body.timestamp;
  let extraData = req.body.extraData;
  let gasLimit = req.body.gasLimit;
  let difficulty = req.body.difficulty;
  let alloc = req.body.alloc;
  let genesis = {
    "chainId": chainId,
    "consensus": consensus,
    "timestamp": timestamp,
    "extraData": extraData,
    "gasLimit": gasLimit,
    "difficulty": difficulty,
    "alloc": alloc
  }
  genesis = JSON.stringify(genesis);
  fs.writeFile('./genesis/genesis_' + chainId + '.json', genesis, (err) => {
      if (err) throw err;
      console.log('Genesis Saved');
  });
  const file = `${__dirname}/genesis/genesis_${chainId}.json`;
  res.download(file); 
})

app.listen(3000, function () {
  console.log('Example app listening on port 3000!')
})