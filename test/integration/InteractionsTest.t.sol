// SPDX-License-Identifier: MIT


pragma solidity ^0.8.18;


import {Test, console} from "lib/forge-std/src/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";
import { FundFundMe, WithdrawFundMe } from "../../script/Interactions.s.sol";



contract InteractionsTest is Test{
      //uint256 number = 1;
    FundMe public fundMe;
    DeployFundMe deployFundMe;

    address alice = makeAddr("alice");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_USER_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;


   function setUp()  external {
      deployFundMe = new DeployFundMe();
      fundMe = deployFundMe.run();
      vm.deal(alice, STARTING_USER_BALANCE);
   }


   function testUserCanFundAndOwnerWithdraw() public {
     uint256 preUserBalance = address(alice).balance;
     uint256 preOwnerBalance = address(fundMe.getOwner()).balance;

     // Using vm.prank to simulate funding from the USER address
      vm.prank(alice);
      fundMe.fund{value: SEND_VALUE}();

       //FundFundMe fundFundMe = new FundFundMe();
      // vm.prank(USER);
      // vm.deal(USER, 1e18);
     // fundFundMe.fundFundMe(address(fundMe));


      WithdrawFundMe  withdrawFundMe = new WithdrawFundMe();
      withdrawFundMe.withdrawFundMe(address(fundMe));

      uint256 afterUserBalance = address(alice).balance;
      uint256 affterOwnerBalance = address(fundMe.getOwner()).balance;

      assert(address(fundMe).balance == 0);
      assertEq(afterUserBalance + SEND_VALUE , preUserBalance);
      assertEq(preOwnerBalance + SEND_VALUE, affterOwnerBalance);
      
      
      // address funder = fundMe.getFunder(0);
      // assertEq(funder, USER);
   }


}