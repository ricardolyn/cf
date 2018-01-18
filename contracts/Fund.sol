pragma solidity ^0.4.18;

import "../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import "../node_modules/zeppelin-solidity/contracts/ownership/Ownable.sol";
import "./CloseFundToken.sol";

contract Fund is Ownable {
    using SafeMath for uint256;

    string public name;
    string public tokenSymbol;
    CloseFundToken public token;
    
    mapping(address => uint256) pendingRequests;
    address pendingWallet;

    function Fund(address _pendingWallet, string _name, string _tokenSymbol) public {
        pendingWallet = _pendingWallet;
        name = _name;
        tokenSymbol = _tokenSymbol;
        token = createTokenContract();
    }

    function createTokenContract() internal returns (CloseFundToken) {
        return new CloseFundToken(1000, name, 8, tokenSymbol);
    }

    function () external payable {
        request();
    }

    function request() public payable {
        uint256 weiAmount = msg.value;
        address buyer = msg.sender;
        pendingRequests[buyer] = pendingRequests[buyer].add(weiAmount); // add amount to the pending requests to be processed
        pendingWallet.transfer(weiAmount); // add amount to the wallet

        TokenRequest(buyer, weiAmount);
    }

    function getRequestedAmount() public view returns (uint256) {
        return pendingRequests[msg.sender];
    }

    function processPurchase(uint256 rate, address buyer) public onlyOwner {
        uint256 weiAmount = pendingRequests[buyer];

        uint256 tokens = getTokenAmount(weiAmount, rate);

        //token.mint(buyer, tokens);

        delete pendingRequests[buyer];
    }

    function getTokenAmount(uint256 weiAmount, uint256 rate) internal pure returns(uint256) {
        return weiAmount.mul(rate);
    }

    event TokenRequest(address indexed purchaser, uint256 amount);
}