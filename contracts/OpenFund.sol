pragma solidity ^0.4.18;

import "./OpenFundToken.sol";

contract OpenFund {
    string public name;
    OpenFundToken public token;

    function purchase() public payable;
    function sell(uint256 tokenAmount) public;
}