var OpenFundToken = artifacts.require('./OpenFundToken.sol')

module.exports = (deployer) => {
  deployer.deploy(OpenFundToken, "Fund 1 Token", "F1T", 8);
};
