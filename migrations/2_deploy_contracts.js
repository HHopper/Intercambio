var Intercambio = artifacts.require("./Intercambio.sol");

module.exports = function(deployer) {
  deployer.deploy(Intercambio);
};
