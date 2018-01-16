pragma solidity ^0.4.18;

import 'zeppelin-solidity/contracts/token/MintableToken.sol';
import 'zeppelin-solidity/contracts/token/DetailedERC20.sol';

contract OpenFundToken is MintableToken {
    string public name;
    string public symbol;
    uint8 public decimals;
    
    function OpenFundToken(string _name, string _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    function getName() constant public returns (string) {
        return name;
    }
}