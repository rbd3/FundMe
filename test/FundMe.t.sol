// SPDX-License-Identifier: MIT

pragma solidity 0.8.28;
import {Test, console} from "forge-std/Test.sol";
import {FundMe} from "../src/FundMe.sol";

error NotOwner();

contract FundMeTest is Test {
    uint256 number = 1;
    FundMe fundMe;
    function setUp() external {
        number = 2;
        fundMe = new FundMe();
    }
    function testDemo() public view {
        console.log(number);
        console.log("Hi guys");
        assertEq(number, 2);
    }
    function testMinimum() public view {
        assertEq(fundMe.MINIMUM_USD(), 5e18);
    }
    function testOwnerIsMsgSender() public view {
        assertEq(fundMe.i_owner(), address(this));
    }
    function testWithdraw() public {
        vm.expectRevert(NotOwner.selector);
        vm.prank(address(0));
        fundMe.withdraw();
    }
}
