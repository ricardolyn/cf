pragma solidity ^0.4.18;

import "../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./OpenFundToken.sol";

contract Fund is Ownable {
    using SafeMath for uint256;

    string public name;
    string public tokenSymbol;
    OpenFundToken public token;
    
    mapping(address => uint256) pendingPurchases;
    mapping(address => uint256) pendingSells;
    address investmentWallet;

    function Fund(address _investmentWallet, string _name, string _tokenSymbol) public {
        investmentWallet = _investmentWallet;
        name = _name;
        tokenSymbol = _tokenSymbol;
        token = createTokenContract();
    }

    function createTokenContract() internal returns (OpenFundToken) {
        return new OpenFundToken(name, tokenSymbol, 8);
    }

    function () external payable {
        purchase();
    }

    function purchase() public payable {
        uint256 weiAmount = msg.value;
        address buyer = msg.sender;
        pendingPurchases[buyer] = pendingPurchases[buyer].add(weiAmount); // add amount to the pending requests to be processed
        owner.transfer(weiAmount); // add amount to the wallet

        TokenPurchaseRequest(buyer, weiAmount);
    }

    function sell(uint256 tokenAmount) public onlyOwner {
        address buyer = msg.sender;
        pendingSells[buyer] = pendingSells[buyer].add(tokenAmount);

        TokenPurchaseRequest(buyer, tokenAmount);
    }

    function getPendingAmount() public view returns (uint256) {
        return pendingPurchases[msg.sender];
    }

    function pendingAmountOf(address buyer) public view onlyOwner returns (uint256) {
        return pendingPurchases[buyer];
    }

    function processPurchase(uint256 nav, address buyer) public onlyOwner payable { // nav: net asset value. is the price per share of the fund
        uint256 weiAmount = pendingPurchases[buyer];

        uint256 tokens = getTokenAmount(weiAmount, nav);

        token.mint(buyer, tokens);
        investmentWallet.transfer(weiAmount);

        delete pendingPurchases[buyer];
    }

    function processSell(uint256 nav, address buyer) public onlyOwner payable {
        uint256 weiAmount = pendingSells[buyer];

        uint256 tokens = getWeiAmount(weiAmount, nav);

        token.burn(buyer, tokens);
        buyer.transfer(weiAmount);

        delete pendingSells[buyer];
    }

    function getTokenAmount(uint256 weiAmount, uint256 nav) internal pure returns(uint256) {
        return weiAmount.div(nav);
    }

    function getWeiAmount(uint256 tokenAmount, uint256 nav) internal pure returns(uint256) {
        return tokenAmount.mul(nav);
    }

    event TokenPurchaseRequest(address indexed purchaser, uint256 amount);
    event TokenSellRequest(address indexed purchaser, uint256 amount);
}