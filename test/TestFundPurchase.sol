pragma solidity ^0.4.18;

import "truffle/Assert.sol";
import "truffle/DeployedAddresses.sol";
import "../contracts/Fund.sol";

contract TestFundPurchase {

  Fund internal fund;

  function TestFundPurchase() public {
    FundFactory factory = new FundFactory();
    fund = factory.fund();
  }

  function testPurchaseNotAllowedWithZeroAmount() public {
    Assert.isFalse(execute("purchase()", 0), "Should not allow zero amount");
  }

  function execute(string signature, uint256 value) internal returns (bool) {
    bytes4 sig = bytes4(keccak256(signature));
    return fund.call.value(value)(sig);
  }
}

contract FundFactory {

  Fund public fund;

  function FundFactory() public {
    fund = new Fund(msg.sender, "name", "n", 0,0,1);
  }
}