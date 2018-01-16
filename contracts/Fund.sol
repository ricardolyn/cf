pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/DetailedERC20.sol';

contract Fund {
    
    mapping(address => uint256) pendingRequests;
    address pendingWallet;

    function request(){
        uint256 weiAmount = msg.value;

        pendingRequests[msg.sender] = pendingRequests[msg.sender].add(weiAmount); // add amount to the pending requests to be processed
        pendingWallet.transfer(weiAmount); // add amount to the wallet

        TokenRequest(msg.sender, weiAmount);
    }

    function getRequestedAmount() returns (uint256){
        return pendingRequests(msg.sender);
    }

    event TokenRequest(address indexed purchaser, uint256 amount);
}