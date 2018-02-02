var Fund = artifacts.require("./Fund.sol");

module.exports = function(callback) {
    var fund = Fund.deployed();
    fund.then(async function(instance) {
        instance.purchase({from: web3.eth.accounts[1], value: web3.toWei(1, 'ether')});
    });
  }

