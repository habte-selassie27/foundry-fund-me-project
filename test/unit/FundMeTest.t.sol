// SPDX-License-Identifier: MIT


pragma solidity ^0.8.18;


import {Test, console} from "forge-std/Test.sol";
import { FundMe } from "../../src/FundMe.sol";
import { DeployFundMe } from "../../script/DeployFundMe.s.sol";


contract FundMeTest is Test{
    //uint256 number = 1;

    FundMe fundMe;

    address USER = makeAddr("user");

    uint256 constant SEND_VALUE = 0.1 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 constant GAS_PRICE = 1;

    function setUp() external {
      // number = 2;
       // fundMe = new FundMe(0x694AA1769357215DE4FAC081bf1f309aDC325306);
      DeployFundMe deployFundMe = new DeployFundMe();
      fundMe = deployFundMe.run();
      vm.deal(USER, STARTING_BALANCE);
    }

    function testMinimumUsdIsFive() public {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
        // console.log(number);
        // console.log("Hello bro!");
        // assertEq(number, 2);
    }

    function testOwnerIsMsgSender() public {
        console.log(fundMe.getOwner());
        console.log(msg.sender);
        assertEq(fundMe.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public {
        uint256 version = fundMe.getVersion();
        assertEq(version, 4);
    }

    function testFundFailsWithoutEnoughETH() public {
        vm.expectRevert(); // hey, the next line , should revert!
        // assert(This tx fails/reverts)
        //uint256 cat = 1;
        fundMe.fund();
    }

    function testFundUpdatesFundedDataStructure() public {
        vm.prank(USER); // The next Tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}();
       
        uint256 amountFunded = fundMe.getAddressToAmountFunded(USER);
        assertEq(amountFunded, SEND_VALUE);
    }

    function testAddsFunderToArrayOfFunders() public {
        vm.prank(USER); // The next Tx will be sent by USER
        fundMe.fund{value: SEND_VALUE}();

        address funder = fundMe.getFunder(0);
        assertEq(funder, USER);
    }

    modifier funded() {
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyOwnerCanWithdraw() public funded{
        vm.prank(USER);
        vm.expectRevert();
        fundMe.withdraw();
    }

    function testWithDrawWithSingleFunder() public funded {
        // Arrange 
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        
        uint256 startingFundMeBalance = address(fundMe).balance;



        // Act
        uint256 gasStart = gasleft(); // 1000
        vm.txGasPrice(GAS_PRICE);


        vm.prank(fundMe.getOwner()); // c: 200
        fundMe.withdraw(); // should have spent gas?

        uint256 gasEnd = gasleft(); // 800
        uint256 gasUsed = (gasStart - gasEnd) * tx.gasprice;
        console.log("Withdraw consumed: %d gas",gasUsed);

        // Assert
        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;

        assertEq(endingFundMeBalance, 0);
        assertEq(startingFundMeBalance + startingOwnerBalance, endingOwnerBalance);
    }

    function testWithdrawFromMultitpleFunders() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address 
            // vm.deal new address 

            // address()

            hoax(address(i) , SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();

            // fund the fundMe contract

        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.withdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);

    }

    function testWithdrawFromMultitpleFundersCheaper() public funded {
        // Arrange
        uint160 numberOfFunders = 10;
        uint160 startingFunderIndex = 1;
        for (uint160 i = startingFunderIndex; i < numberOfFunders; i++) {
            // vm.prank new address 
            // vm.deal new address 

            // address()

            hoax(address(i) , SEND_VALUE);
            fundMe.fund{value: SEND_VALUE}();

            // fund the fundMe contract

        }

        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        
        // Act
        vm.startPrank(fundMe.getOwner());
        fundMe.cheaperWithdraw();
        vm.stopPrank();

        // Assert
        assert(address(fundMe).balance == 0);
        assert(startingOwnerBalance + startingFundMeBalance == fundMe.getOwner().balance);

    }


}
