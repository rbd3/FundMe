// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

error NotOwner();

contract FundMeTest is Test {
    uint256 number = 1;
    FundMe fundMe;
    address USER = address(0);
    uint256 SEND_VALUE = 6e18; // 6 ETH

    function setUp() external {
        number = 2;
        fundMe = new FundMe();

        // Mock the Chainlink price feed to return a fixed rate
        vm.mockCall(
            address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419), // Chainlink ETH/USD price feed address
            abi.encodeWithSignature("latestRoundData()"),
            abi.encode(0, 2000e8, 0, 0, 0) // Mock price of 2000 USD per ETH
        );
    }

    // Add a receive function to allow the test contract to accept Ether
    receive() external payable {}

    function testDemo() public view {
        console.log(number);
        console.log("Hi guys");
        assertEq(number, 2);
    }
    function testMinimum() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.getOwner(), address(this));
    }
    function testWithdraw() public {
        vm.expectRevert(NotOwner.selector);
        vm.prank(address(0));
        fundMe.withdraw();
    }

    function testfundNotEnoughETH() public {
        vm.expectRevert();
        fundMe.fund();
    }

    // function testfundUpdateData() {
    //     FundMe.fund(value: 10e18);
    // }

    modifier funded() {
        vm.deal(USER, SEND_VALUE);
        vm.prank(USER);
        fundMe.fund{value: SEND_VALUE}();
        _;
    }

    function testOnlyownerWithdraw() public funded {
        vm.prank(USER);
        vm.expectRevert(NotOwner.selector);
        fundMe.withdraw();
    }

    function testWithdrawSingleFunder() public funded {
        uint256 startingOwnerBalance = fundMe.getOwner().balance;
        uint256 startingFundMeBalance = address(fundMe).balance;
        vm.prank(fundMe.getOwner());
        fundMe.withdraw();

        uint256 endingOwnerBalance = fundMe.getOwner().balance;
        uint256 endingFundMeBalance = address(fundMe).balance;
        assertEq(endingFundMeBalance, 0);
        assertEq(
            startingFundMeBalance + startingOwnerBalance,
            endingOwnerBalance
        );
    }
}
