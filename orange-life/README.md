# Orange Smart Contracts

## Requirements

 - Node, npm
 - Ganache running locally for development

## Usage

 - `truffle migrate` to deploy
 - `truffle console` to interact with it
    ```js
let orange = await OrangeLife.deployed();
let accounts = await web3.eth.getAccounts();
orange.getMedicalRecords(accounts[0]);
orange.addMedicalRecord("QmbWqxBEKC3P8tqsKc98xmWNzrzDtRLMiMPL8wBuTGsMnR", 1, {"from": accounts[0]});
// orange.addMedicalRecord(accounts[0], "QmbWqxBEKC3P8tqsKc98xmWNzrzDtRLMiMPL8wBuTGsMnR", 1);
    ```
 - see `test` for more
