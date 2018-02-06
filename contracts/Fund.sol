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
    
    uint256 public reserveBalance;
    address public manager;

    mapping(address => uint256) pendingPurchases;
    mapping(address => uint256) pendingSells;

    function Fund(address _manager, string _name, string _tokenSymbol, uint256 _purchaseFeePP, uint256 _sellFeePP, uint _feeDenominator) public {
        manager = _manager;
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

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    function getTokenAmount(uint256 weiAmount, uint256 nav) internal pure returns(uint256) {
        return weiAmount.div(nav);
    }

    function getWeiAmount(uint256 tokenAmount, uint256 nav) internal pure returns(uint256) {
        return tokenAmount.mul(nav);
    }

    function getPendingAmount() public view returns (uint256) {
        return pendingPurchases[msg.sender];
    }

    function pendingAmountOf(address buyer) public view onlyOwner returns (uint256) {
        return pendingPurchases[buyer];
    }

    function purchase() public payable {
        require((pendingPurchases[msg.sender] + msg.value) > pendingPurchases[msg.sender]);

        //TODO what happens if amount is less than NAV?

        pendingPurchases[msg.sender] = pendingPurchases[msg.sender].add(msg.value); // add amount to the pending requests to be processed

        TokenPurchaseRequest(msg.sender, msg.value);
    }
    
    function sell(uint256 tokenAmount) public {
        require(token.balanceOf(msg.sender) >= tokenAmount);
        require((pendingSells[msg.sender] + tokenAmount) > pendingSells[msg.sender]);

        pendingSells[msg.sender] = pendingSells[msg.sender].add(tokenAmount);

        TokenSellRequest(msg.sender, tokenAmount);
    }

    function processPurchase(uint256 nav, address buyer) public onlyOwner payable {
        uint256 weiAmount = pendingPurchases[buyer];
        uint256 fee = weiAmount.mul(purchaseFeePP).div(feeDenominator);
        uint256 weiNetAmount = weiAmount - fee;
        uint256 tokens = getTokenAmount(weiNetAmount, nav);
        
        token.mint(buyer, tokens);
        manager.transfer(weiNetAmount);

        delete pendingPurchases[buyer];

        TokenPurchased(buyer, tokens, nav, fee);
    }
    
    function processSell(uint256 nav, address buyer) public onlyOwner payable {
        uint256 tokenAmount = pendingSells[buyer];
        uint256 weiAmount = getWeiAmount(tokenAmount, nav);

        require(reserveBalance >= weiAmount);

        uint256 fee = weiAmount.mul(sellFeePP).div(feeDenominator);

        reserveBalance = reserveBalance.sub(weiAmount);
        token.burn(buyer, tokenAmount);
        buyer.transfer(weiAmount - fee);

        delete pendingSells[buyer];

        TokenSold(buyer, tokenAmount, nav, fee);
    }//"test": "concurrently --kill-others \"npm run blockchain\" \"npm start\""

    function deposit() public onlyManager payable {
        reserveBalance = reserveBalance.add(msg.value);

        FundManagerDeposit(msg.value);
    }

    event TokenPurchaseRequest(address indexed purchaser, uint256 amount);
    event TokenPurchased(address indexed purchaser, uint256 tokenAmount, uint256 nav, uint256 fee);
    event TokenSellRequest(address indexed purchaser, uint256 amount);
    event TokenSold(address indexed purchaser, uint256 tokenAmount, uint256 nav, uint256 fee);

    event FundManagerDeposit(uint256 weiAmount);
}