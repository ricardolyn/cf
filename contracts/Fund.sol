pragma solidity ^0.4.18;

import "../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./OpenFundToken.sol";
import "./OpenFund.sol";

contract Fund is OpenFund, Ownable {
    using SafeMath for uint256;

    string public tokenSymbol;
    uint256 public purchaseFeePP;
    uint256 public sellFeePP;
    uint256 public feeDenominator;
    
    mapping(address => uint256) pendingPurchases;
    mapping(address => uint256) pendingSells;
    address investmentWallet;

    function Fund(address _investmentWallet, string _name, string _tokenSymbol, uint256 _purchaseFeePP, uint256 _sellFeePP, uint _feeDenominator) public {
        investmentWallet = _investmentWallet;
        name = _name;
        tokenSymbol = _tokenSymbol;
        purchaseFeePP = _purchaseFeePP;
        sellFeePP = _sellFeePP;
        feeDenominator = _feeDenominator;
        token = createTokenContract();
    }

    function createTokenContract() internal returns (OpenFundToken) {
        return new OpenFundToken(name, tokenSymbol, 8);
    }

    function () external payable {
        purchase();
    }

    function purchase() public payable {
        //todo what happens if amount is less than NAV?
        uint256 weiAmount = msg.value;
        address buyer = msg.sender;

        pendingPurchases[buyer] = pendingPurchases[buyer].add(weiAmount); // add amount to the pending requests to be processed
        owner.transfer(weiAmount); // add amount to the wallet

        TokenPurchaseRequest(buyer, weiAmount);
    }

    function sell(uint256 tokenAmount) public {
        require(token.balanceOf(msg.sender) >= tokenAmount);

        pendingSells[msg.sender] = pendingSells[msg.sender].add(tokenAmount);

        TokenSellRequest(msg.sender, tokenAmount);
    }

    function getPendingAmount() public view returns (uint256) {
        return pendingPurchases[msg.sender];
    }

    function pendingAmountOf(address buyer) public view onlyOwner returns (uint256) {
        return pendingPurchases[buyer];
    }

    function processPurchase(uint256 nav, address buyer) public onlyOwner payable { // nav: net asset value. is the price per share of the fund
        uint256 weiAmount = pendingPurchases[buyer];
        uint256 fee = weiAmount.mul(purchaseFeePP).div(feeDenominator);
        uint256 tokens = getTokenAmount(weiAmount - fee, nav);
        
        token.mint(buyer, tokens);

        delete pendingPurchases[buyer];

        TokenPurchased(buyer, tokens, nav, fee);
    }

    function processSell(uint256 nav, address buyer) public onlyOwner payable {
        uint256 tokenAmount = pendingSells[buyer];
        uint256 weiAmount = getWeiAmount(tokenAmount, nav);
        uint256 fee = weiAmount.mul(sellFeePP).div(feeDenominator);

        token.burn(buyer, tokenAmount);
        buyer.transfer(weiAmount - fee);

        delete pendingSells[buyer];

        TokenSold(buyer, tokenAmount, nav, fee);
    }

    function getTokenAmount(uint256 weiAmount, uint256 nav) internal pure returns(uint256) {
        return weiAmount.div(nav);
    }

    function getWeiAmount(uint256 tokenAmount, uint256 nav) internal pure returns(uint256) {
        return tokenAmount.mul(nav);
    }

    event TokenPurchaseRequest(address indexed purchaser, uint256 amount);
    event TokenPurchased(address indexed purchaser, uint256 tokenAmount, uint256 nav, uint256 fee);
    event TokenSellRequest(address indexed purchaser, uint256 amount);
    event TokenSold(address indexed purchaser, uint256 tokenAmount, uint256 nav, uint256 fee);
}