pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";

contract TestExample {

  SomeContract internal someContract;

  function TestExample() public {
    someContract = new SomeContract();
  }

  function testZero() public {
    Assert.isTrue(execute("method()", 0), "Should not allow zero amount");
  }

  function testNonZero() public {
    Assert.isTrue(execute("method()", 100), "Should allow non-zero amount");
  }

  function execute(string signature, uint256 value) internal returns (bool) {
    bytes4 sig = bytes4(keccak256(signature));
    return someContract.call.value(value)(sig);
  }
}

contract SomeContract {

  function method() public {
    ExampleEvent(msg.sender, msg.value);
  }

  event ExampleEvent(address indexed add, uint256 amount);
}