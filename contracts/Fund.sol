pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/DetailedERC20.sol';
import 'zeppelin-solidity/contracts/math/SafeMath.sol';

contract Fund {
    using SafeMath for uint256;
    
    mapping(address => uint256) pendingRequests;
    address pendingWallet;

    function Fund(address _pendingWallet) public {
        pendingWallet = _pendingWallet;
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

    event TokenRequest(address indexed purchaser, uint256 amount);
}