var OpenFundToken = artifacts.require("./OpenFundToken.sol");

module.exports = function(callback) {
    console.log(web3.eth.accounts[1]);
    var token = OpenFundToken.deployed();
    token.then(async function(instance) {
        instance.mint(web3.eth.accounts[1], 100);
        console.log(await instance.getName());
        console.log(await instance.balanceOf(web3.eth.accounts[1]));
        console.log(await instance.balanceOf(web3.eth.accounts[2]));
    });
  }

