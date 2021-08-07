const OrangeLife = artifacts.require("OrangeLife");

module.exports = function (deployer) {
  // TODO: this address is matic gsnv2's Forwarder of Mumbai Testnet
  // source: https://docs.matic.network/docs/develop/metatransactions/metatransactions-gsn/#gsnv2
  deployer.deploy(OrangeLife, "0xF65De530849aC11d6931b07A52C17e054489920e");
};
