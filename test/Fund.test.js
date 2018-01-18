const web3 = global.web3;

const Fund = artifacts.require('Fund');
const OpenFundToken = artifacts.require('OpenFundToken');

const BigNumber = web3.BigNumber;

contract('Fund', function([_, pendingWallet, wallet, purchaser]) {

    const initialParams = {
        name: "teste",
        tokenSymbol: "TST"
    };

    let fund;
    let token;

    beforeEach(async function() {
        fund = await Fund.new(pendingWallet, initialParams.name, initialParams.tokenSymbol);
        token = await fund.token();
    });

    it("should set initial attributes", async function() {
        assert.equal(await fund.getRequestedAmount({from: purchaser}), 0);
        assert.equal(await token.name(), initialParams.name);
    });

    it("should add requested amount in tokens", async function() {
        let weiValue = 1000;
        let rate = 2;
        let tokenValue = rate * weiValue;

        await fund.request({from: purchaser, value: weiValue})

        let requestedAmount = await fund.getRequestedAmount({from: purchaser});
        assert.equal(requestedAmount.toNumber(), weiValue);
        
        await fund.processPurchase(rate, purchaser);
        
        assert.equal(await token.balanceOf(purchaser), tokenValue);
        
    });
});