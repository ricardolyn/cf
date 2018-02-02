var Fund = artifacts.require("./Fund.sol");

module.exports = function (callback) {
    web3.eth.sendTransaction({ from: web3.eth.accounts[2], to: "0xED7f4Bb6f52033535f555923E906AE64B155D9Ef", value: web3.toWei(20, 'ether') })
}

