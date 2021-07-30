const OrangeLife = artifacts.require("OrangeLife");

module.exports = function (deployer) {
  deployer.deploy(OrangeLife, "0x9399BB24DBB5C4b782C70c2969F58716Ebbd6a3b");
};
