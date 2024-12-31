// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DealFactory} from "../../src/Deals/DealFactory.sol";

import {BulkDeal} from "../../src/Deals/BulkDeal.sol";
import {DeployDealFactory} from "../../script/Deals/DeployDealFactory.s.sol";
import {DeployedMinimal} from "../../src/Deals/structs/BulkDealProposal.sol";

contract DealFactoryTest is Test {
    DealFactory factory;

    /*//////////////////////////////////////////////////////////////
                        ACCOUNTS
    //////////////////////////////////////////////////////////////*/
    address coconuts = makeAddr("coconuts");
    uint256 constant STARTING_BALANCE = 10 ether;

    /*//////////////////////////////////////////////////////////////
                            CONSTANTS
    //////////////////////////////////////////////////////////////*/
    uint256 private constant SEND_VALUE = 0.01 ether;
    string private constant TEST_DESCRIPTION = "bulk packs of 100.000 eggs to be divided by 5";
    uint256 private constant TEST_INVIDIDUAL_FEE = 100;
    uint256 private constant TEST_NB_OF_CUSTOMERS = 5;
    string private constant TEST_IMG_URL = "www.eggs-url/1";
    string private constant TEST_INTERNAL_ID = "BBB111110";

    function setUp() external {
        DeployDealFactory deployFactory = new DeployDealFactory();
        factory = deployFactory.run();
        vm.deal(coconuts, STARTING_BALANCE);
    }

    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier registered() {
        vm.prank(coconuts);
        factory.applyForMembership{value: SEND_VALUE}();
        assert(address(factory).balance == SEND_VALUE);
        assertEq(factory.getMember(address(coconuts)), true);
        _;
    }

    modifier registeredAndSubmitted() {
        vm.prank(coconuts);
        factory.applyForMembership{value: SEND_VALUE}();
        assert(address(factory).balance == SEND_VALUE);
        assertEq(factory.getMember(address(coconuts)), true);
        vm.prank(coconuts);
        factory.submitProposal(
            TEST_DESCRIPTION, TEST_INVIDIDUAL_FEE, TEST_NB_OF_CUSTOMERS, TEST_IMG_URL, TEST_INTERNAL_ID
        );
        assertEq(factory.getNbOfPendingProposals(address(coconuts)), 1);
        _;
    }

    /*//////////////////////////////////////////////////////////////
                            MEMBERSHIP
    //////////////////////////////////////////////////////////////*/
    function testOwnerIsMsgSender() public view {
        // when passing throught a script, caller of test is the msg.sender to the final contract
        assertEq(factory.getOwner(), msg.sender);
    }

    function testPriceFeedVersionIsAccurate() public view {
        uint256 version = factory.getPriceFeedVersion();
        assertEq(version, 4);
    }

    function testOwnerIsAlsoMember() public view {
        assertEq(factory.getMember(msg.sender), true);
    }

    function testApplyFormMembershipFailsWithInsufficientFund() public {
        vm.prank(coconuts);
        vm.expectRevert();
        factory.applyForMembership(); // <- We send 0 value
    }

    function testCantApplyOfAlreadyMember() public registered {
        vm.prank(coconuts);
        vm.expectRevert();
        factory.applyForMembership{value: SEND_VALUE}();
    }

    function testMemberCantRemoveMembership() public registered {
        vm.prank(coconuts);
        vm.expectRevert();
        factory.removeMembership(address(coconuts));
    }

    function testOwnerCanRemoveMembership() public registered {
        vm.prank(msg.sender);
        factory.removeMembership(address(coconuts));
        assertEq(factory.getMember(address(coconuts)), false);
        // membership fees sent back to coconuts
        assertEq(address(coconuts).balance, STARTING_BALANCE);
    }

    function testOwnerCantRemoveMembership() public registeredAndSubmitted {
        vm.prank(msg.sender);
        vm.expectRevert();
        factory.removeMembership(address(coconuts));
    }

    /*//////////////////////////////////////////////////////////////
                            SUBMIT PROPOSAL
    //////////////////////////////////////////////////////////////*/
    function testCanSubmitProposal() public registeredAndSubmitted {
        assertEq(factory.getPendingProposal(0, address(coconuts)).internalId, TEST_INTERNAL_ID);
    }

    /*//////////////////////////////////////////////////////////////
                            CANCEL PROPOSAL
    //////////////////////////////////////////////////////////////*/
    function testMemberCancelHisProposal() public registeredAndSubmitted {
        vm.prank(coconuts);
        factory.cancelPendingProposal(TEST_INTERNAL_ID);
        assertEq(factory.getNbOfPendingProposals(address(coconuts)), 0);
    }

    function testOwnerCanCancelMembersProposal() public registeredAndSubmitted {
        vm.prank(msg.sender);
        factory.ownerCancelsPendingProposal(address(coconuts), TEST_INTERNAL_ID);
        assertEq(factory.getNbOfPendingProposals(address(coconuts)), 0);
    }

    /*//////////////////////////////////////////////////////////////
                            DEPLOY PROPOSAL
    //////////////////////////////////////////////////////////////*/
    function testOWnerDeployedProperly() public registeredAndSubmitted {
        vm.prank(msg.sender);
        factory.approveAndDeployProposal(address(coconuts), TEST_INTERNAL_ID);
        DeployedMinimal memory bulkDealInfo = factory.getDeployed(address(coconuts), 0);
        assertEq(bulkDealInfo.deployed != address(0), true);
        assertEq(factory.getNbOfPendingProposals(address(coconuts)), 0);
        BulkDeal bulkDeal = BulkDeal(bulkDealInfo.deployed);
        assertEq(bulkDeal.getInternalId(), TEST_INTERNAL_ID);
    }

    function testNonOwnerCantDeployProposal() public {
        vm.prank(coconuts);
        vm.expectRevert();
        factory.approveAndDeployProposal(address(coconuts), TEST_INTERNAL_ID);
    }

    /**
     * TODO test multiple proposal with many customers and check indexes et content of s_proposals.
     */

    //
}
