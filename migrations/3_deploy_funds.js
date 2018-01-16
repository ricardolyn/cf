var Fund = artifacts.require('./Fund.sol')

module.exports = (deployer) => {
  deployer.deploy(Fund);
};
