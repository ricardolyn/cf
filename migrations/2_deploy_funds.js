var Fund = artifacts.require('./Fund.sol')

module.exports = async (deployer, network, accounts) => {
  let investmentAccount = accounts[1];
  let purchaseFeePP = 1;
  let sellFeePP = 3;
  deployer.deploy(Fund, investmentAccount, "Fund Market 1", "FUNDX1", purchaseFeePP, sellFeePP, 100);
};
