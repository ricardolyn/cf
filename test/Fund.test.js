const web3 = global.web3;

const Fund = artifacts.require('Fund');
const OpenFundToken = artifacts.require('OpenFundToken');

const BigNumber = web3.BigNumber;

contract('Fund', function([ownerWallet, investmentWallet, wallet, purchaser]) {

    const initialParams = {
        name: "teste",
        tokenSymbol: "TST"
    };

    let fund;
    let token;

    beforeEach(async function() {
        fund = await Fund.new(investmentWallet, initialParams.name, initialParams.tokenSymbol);
        token = OpenFundToken.at(await fund.token());
    });

    it("should set initial attributes", async function() {
        assert.equal(await fund.getPendingAmount({from: purchaser}), 0);
        assert.equal(await fund.name(), initialParams.name);
        assert.equal(await token.name(), initialParams.name);
    });

    it("should add requested amount in tokens", async function() {
        let nav = 10;
        let tokenValue = 200;
        let weiValue = tokenValue * nav;

        await fund.purchase({from: purchaser, value: weiValue})
        let requestedAmount = await fund.getPendingAmount({from: purchaser});
        assert.equal(requestedAmount.toNumber(), weiValue);
        
        await fund.processPurchase(nav, purchaser, {value: requestedAmount});
        
        let balance = await token.balanceOf(purchaser);
        let totalSupply = await token.totalSupply();

        assert.equal(balance.toNumber(), tokenValue);
        assert.equal(totalSupply.toNumber(), tokenValue);
    });

    it("should sell tokens", async function() {
        // // logs?
        // var event = fund.Log();
        // event.watch(function(error, result){
        //     if (!error)
        //         console.log(result.args.amount.toNumber());
        // });

        let nav = 3;
        let tokenValue = 1000;
        let weiValue = tokenValue * nav;

        await fund.purchase({from: purchaser, value: weiValue})
        await fund.processPurchase(nav, purchaser, {value: weiValue});

        let sellTokens = 100;
        
        await fund.sell(sellTokens, {from: purchaser});
        await fund.processSell(nav, purchaser, {value: weiValue})

        let balance = await token.balanceOf(purchaser);
        assert.equal(balance.toNumber(), tokenValue - sellTokens);
    });

});