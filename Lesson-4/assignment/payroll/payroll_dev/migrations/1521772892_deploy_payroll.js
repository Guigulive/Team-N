var PayRoll = artifacts.require("./PayRoll.sol");
module.exports = function(deployer) {
  // Use deployer to state migration tasks.
  deployer.deploy(PayRoll);
};
