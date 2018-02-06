const web3 = global.web3;

const Fund = artifacts.require('Fund');
const OpenFundToken = artifacts.require('OpenFundToken');

import expectThrow from 'zeppelin-solidity/test/helpers/expectThrow';
import expectEvent from 'zeppelin-solidity/test/helpers/expectEvent';

const BigNumber = web3.BigNumber;

contract('Fund', function ([ownerWallet, investmentWallet, wallet, purchaser]) {

    const initialParams = {
        name: "teste",
        tokenSymbol: "TST"
    };

    let fund;
    let token;

    beforeEach(async function () {
        fund = await Fund.new(investmentWallet, initialParams.name, initialParams.tokenSymbol, 0, 0, 100);// 0% fee
        token = OpenFundToken.at(await fund.token());
    });

    it("should set initial attributes", async function () {
        assert.equal(await fund.getPendingAmount({ from: purchaser }), 0);
        assert.equal(await fund.name(), initialParams.name);
        assert.equal(await token.name(), initialParams.name);
    });

    it("should purchase amount bigger than zero", async function () {
        await expectThrow(fund.purchase({ from: purchaser, value: 0 }));
    });

    it("should sell amount bigger than zero", async function () {
        await expectThrow(fund.sell(0));
    });

    it("should have reserves for selling", async function () {
        //TODO
    });

    it("should trigger event when calling purchase", async function () {
        await expectEvent.inTransaction(
            fund.purchase({ from: purchaser, value: 100 }),
            'TokenPurchaseRequest'
        );
    });

    it("should sum purchase orders", async function () {
        await fund.purchase({ from: purchaser, value: 100 })
        await fund.purchase({ from: purchaser, value: 100 })
        let pendingAmount = await fund.getPendingAmount({ from: purchaser })
        assert.equal(pendingAmount.toNumber(), 200);
    });

    it("should increase deposit amount", async function () {
        let depositValue = 1;

        await fund.deposit({ from: investmentWallet, value: depositValue });

        let reserve = await fund.reserveBalance()
        assert.equal(reserve.toNumber(), depositValue);
    });

    it("should decrease reserve amount", async function () {
        let nav = 1;
        let sellTokens = 100;
        let depositValue = 200;

        await mockPurchase(1000, nav)

        await fund.sell(sellTokens, { from: purchaser });
        await fund.deposit({ from: investmentWallet, value: depositValue });
        await fund.processSell(nav, purchaser);

        let reserve = await fund.reserveBalance()
        assert.equal(reserve.toNumber(), depositValue - sellTokens);
    });

    it("should add requested amount in tokens", async function () {
        let nav = 10;
        let tokenValue = 200;
        let weiValue = tokenValue * nav;

        await fund.purchase({ from: purchaser, value: weiValue })
        let requestedAmount = await fund.getPendingAmount({ from: purchaser });
        assert.equal(requestedAmount.toNumber(), weiValue);

        await fund.processPurchase(nav, purchaser, { value: requestedAmount });

        let balance = await token.balanceOf(purchaser);
        let totalSupply = await token.totalSupply();

        assert.equal(balance.toNumber(), tokenValue);
        assert.equal(totalSupply.toNumber(), tokenValue);
    });

    it("should sell tokens", async function () {
        let nav = 3;
        let tokenAmount = 1000;
        let weiValue = tokenAmount * nav;

        //await mockPurchase(tokenAmount, nav)
        await fund.purchase({ from: purchaser, value: weiValue })
        await fund.processPurchase(nav, purchaser, { value: weiValue });

        let sellTokens = 100;

        await fund.sell(sellTokens, { from: purchaser });
        await fund.deposit({ from: investmentWallet, value: sellTokens * nav });
        await fund.processSell(nav, purchaser)

        let balance = await token.balanceOf(purchaser);
        assert.equal(balance.toNumber(), tokenAmount - sellTokens);
    });

    async function mockPurchase(tokenAmount, nav) {
        let weiValue = tokenAmount * nav;

        await fund.purchase({ from: purchaser, value: weiValue })
        await fund.processPurchase(nav, purchaser, { value: weiValue });
    }
});

