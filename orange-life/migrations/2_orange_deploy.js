const OrangeLife = artifacts.require("OrangeLife");

module.exports = function (deployer) {
  // TODO: this address is matic gsnv2's Forwarder of Mumbai Testnet
  // source: https://docs.opengsn.org/contracts/addresses.html#polygon-matic
  deployer.deploy(OrangeLife, "0x4d4581c01A457925410cd3877d17b2fd4553b2C5");
};
