pragma solidity ^0.4.18;

import "../node_modules/zeppelin-solidity/contracts/math/SafeMath.sol";
import '../node_modules/zeppelin-solidity/contracts/token/ERC20/MintableToken.sol';

contract OpenFundToken is MintableToken {
    using SafeMath for uint256;

    string public name;
    string public symbol;
    uint8 public decimals;
    
    function OpenFundToken(string _name, string _symbol, uint8 _decimals) public {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    event Burn(address indexed burner, uint256 value);

    /**
    * @dev Burns a specific amount of tokens.
    * @param _value The amount of token to be burned.
    */
    function burn(uint256 _value) public canMint {
        require(_value <= balances[msg.sender]);

        address burner = msg.sender;
        burn(burner, _value);
    }

    function burn(address burner, uint256 _value) public onlyOwner canMint {
        require(_value <= balances[burner]);
        // no need to require value <= totalSupply, since that would imply the
        // sender's balance is greater than the totalSupply, which *should* be an assertion failure

        balances[burner] = balances[burner].sub(_value);
        totalSupply_ = totalSupply_.sub(_value);
        Burn(burner, _value);
    }
}