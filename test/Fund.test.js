const web3 = global.web3;

const Fund = artifacts.require('Fund');

contract('Fund', function(accounts) {

    const initialParams = {
        main: accounts[0],
        pendingWallet: accounts[1]
    };

    let fund;

    beforeEach(async function() {
        fund = await Fund.new(initialParams.pendingWallet);
    });

    it("should set initial attributes", async function() {
        assert.equal(await fund.getRequestedAmount(initialParams.main), 0);
    });
});