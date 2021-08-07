const OrangePayMaster = artifacts.require("OrangePayMaster");

module.exports = function (deployer) {
  deployer.deploy(OrangePayMaster);
};
