var Fund = artifacts.require("./Fund.sol");
var OpenFundToken = artifacts.require("./OpenFundToken.sol");

module.exports = function (callback) {
    var fund = Fund.deployed();
    fund.then(async function (instance) {
        let token = await OpenFundToken.at(await instance.token());
        let tokenAmount = await token.balanceOf(web3.eth.accounts[1]);
        instance.sell(tokenAmount, { from: web3.eth.accounts[1] });
    });
}

