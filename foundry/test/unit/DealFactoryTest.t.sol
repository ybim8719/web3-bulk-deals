// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DealFactory} from "../../src/DealFactory.sol";

import {BulkDeal} from "../../src/BulkDeal.sol";
import {DeployDealFactory} from "../../script/DeployDealFactory.s.sol";

contract DealFactoryTest is Test {
    DealFactory factory;
    address coconuts = makeAddr("coconuts");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 private constant SEND_VALUE = 0.01 ether;

    function setUp() external {
        DeployDealFactory deployFactory = new DeployDealFactory();
        factory = deployFactory.run();
        vm.deal(coconuts, STARTING_BALANCE);
    }

    modifier addMember() {
        vm.prank(coconuts);
        factory.applyForMembership{value: SEND_VALUE}();
        // assert(address(fundMe).balance > 0);
        _;
    }

    function testOwnerIsMsgSender() public view {
        // when passing throught a script, caller of test is the msg.sender to the final contract
        assertEq(factory.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = factory.getPriceFeedVersion();
        assertEq(version, 4);
    }

    //list of scenarios
    // function testApplyFormMembershipFailsWithoutInsufficientFund() public {
    //     vm.expectRevert();

    //     factory.applyForMembership(); // <- We send 0 value
    // }

    // function testAddMemberToArrayOfMembers() public {
    //     vm.startPrank(alice);
    //     fundMe.fund{value: SEND_VALUE}();
    //     vm.stopPrank();

    //     address funder = fundMe.getFunder(alice);
    //     assertEq(funder, alice);
    // }

    // can submit deal
    // function testSubmitProposal() public {
    //     vm.prank(alice);
    //     fundMe.fund{value: SEND_VALUE}();
    //     uint256 amountFunded = fundMe.getAddressToAmountFunded(alice);
    //     assertEq(amountFunded, SEND_VALUE);
    // }

    // function testOnlyMemberCandSubmitProposal() public funded {
    //     vm.expectRevert();
    //     vm.prank(alice);
    //     fundMe.withdraw();
    // }

    // function testOwnerCanValidateProposal() public funded {
    //     vm.expectRevert();
    //     vm.prank(alice);
    //     fundMe.withdraw();
    // }

    //function canRemoveMembership()
    // function onlySenderOrOwnerCanCancelProposal
}
