# Orange Smart Contracts

## Contracts

### `OrangeLife.sol`

This is the main contract which handles all medical records.

### `OrangePayMaster.sol`

This is a GSN PayMaster used for gasless transactions. [Reference](https://docs.opengsn.org/javascript-client/tutorial.html#creating-a-paymaster).

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
```

 - see tests for more examples
 - `truffle test` to run tests

### Adding records on the matic mumbai testnet

```
truffle console --network matic
let accounts = await web3.eth.getAccounts();
let orange = await OrangeLife.deployed();
docId = "QmYwgzyVeVMaMjiGFtUHNW1X1NgfkZFKihn4GW5sUoZgrC";
res = await orange.addMedicalRecord(docId, "029d279e6e98d7275fe50d8dcc3019aa7a7afcc417b153ff91688dea5181be6f12", "039dde8619b2844159c57b83434370c516a1e6fd5b2d04aec4270ac592683764c3", "", "", "", 1, {"from": accounts[0]});

await orange.requestAccess(accounts[0], 1, {"from": accounts[1]});
await orange.grantAccess(accounts[1], 1, {"from": accounts[0]});
await orange.revokeAccess(accounts[1], 1, {"from": accounts[0]});
```

### Updating PayMaster contract address

```
npx truffle console --network matic

paymaster = await OrangePayMaster.deployed()
paymaster.setTarget("0x9cc6c1FB0ee80a2389a286da0BB7903dE0175172")

// pay paymaster
web3.eth.sendTransaction({from: accounts[0], to: paymaster.address, value: 1e18})
```