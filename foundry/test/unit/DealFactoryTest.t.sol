// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DealFactory} from "../../src/DealFactory.sol";

import {BulkDeal} from "../../src/BulkDeal.sol";
import {DeployDealFactory} from "../../script/DeployDealFactory.s.sol";

contract DealFactoryTest is Test {
    DealFactory factory;
    address alice = makeAddr("alice");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 private constant SEND_VALUE = 0.1 ether;

    function setUp() external {
        DeployDealFactory deployFactory = new DeployDealFactory();
        factory = deployFactory.run();
        vm.deal(alice, STARTING_BALANCE);
    }

    modifier fundUser() {
        vm.prank(alice);
        // fundMe.fund{value: SEND_VALUE}();
        // assert(address(fundMe).balance > 0);
        _;
    }

    function testOwnerIsMsgSender() public {
        console.log(factory.getOwner());
        console.log(address(this));
        assertEq(factory.getOwner(), address(this));
    }

    // retrived from mock chainlink or real oracle
    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = factory.getVersion();
        assertEq(version, 4);
    }

    // list of scenarios
}

// function testFundFailsWIthoutEnoughETH() public {
//     vm.expectRevert(); // <- The next line after this one should revert! If not test fails.
//     fundMe.fund(); // <- We send 0 value
// }

// function testFundUpdatesFundDataStructure() public {
//     vm.prank(alice);
//     fundMe.fund{value: SEND_VALUE}();
//     uint256 amountFunded = fundMe.getAddressToAmountFunded(alice);
//     assertEq(amountFunded, SEND_VALUE);
// }

// function testAddsFunderToArrayOfFunders() public {
//     vm.startPrank(alice);
//     fundMe.fund{value: SEND_VALUE}();
//     vm.stopPrank();

//     address funder = fundMe.getFunder(0);
//     assertEq(funder, alice);
// }

// function testOnlyOwnerCanWithdraw() public funded {
//     vm.expectRevert();
//     vm.prank(alice);
//     fundMe.withdraw();
// }
