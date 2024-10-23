// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DealFactory} from "../../src/DealFactory.sol";

import {BulkDeal} from "../../src/BulkDeal.sol";
import {DeployDealFactory} from "../../script/DeployDealFactory.s.sol";
import {DeployedMinimal} from "../../src/structs/BulkDealProposal.sol";

contract DealFactoryTest is Test {
    DealFactory factory;
    address coconuts = makeAddr("coconuts");
    uint256 constant STARTING_BALANCE = 10 ether;
    uint256 private constant SEND_VALUE = 0.01 ether;

    string private constant TEST_DESCRIPTION =
        "bulk packs of 1000 eggs to be divided by 5";
    uint256 private constant TEST_INVIDIDUAL_FEE = 100;
    uint256 private constant TEST_NB_OF_CUSTOMERS = 5;
    string private constant TEST_IMG_URL = "www.eggs-url/1";
    uint256 private constant TEST_INTERNAL_ID = 11111100;

    function setUp() external {
        DeployDealFactory deployFactory = new DeployDealFactory();
        factory = deployFactory.run();
        vm.deal(coconuts, STARTING_BALANCE);
    }

    modifier registerMember() {
        vm.prank(coconuts);
        factory.applyForMembership{value: SEND_VALUE}();
        assert(address(factory).balance == SEND_VALUE);
        assertEq(factory.getMember(address(coconuts)), true);
        _;
    }

    /*** MEMBERSHIP */
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

    function testCantApplyOfAlreadyMember() public registerMember {
        vm.prank(coconuts);
        vm.expectRevert();
        factory.applyForMembership{value: SEND_VALUE}();
    }

    function testMemberCantRemoveMembership() public registerMember {
        vm.prank(coconuts);
        vm.expectRevert();
        factory.removeMembership(address(coconuts));
    }

    function testOwnerCanRemoveMembership() public registerMember {
        vm.prank(msg.sender);
        factory.removeMembership(address(coconuts));
        assertEq(factory.getMember(address(coconuts)), false);
        // membership fees sent back to coconuts
        assertEq(address(coconuts).balance, STARTING_BALANCE);
    }

    // todo can't remove member if has pending proposals

    /*** SUBMIT PROPOSAL */
    function testCanSubmitProposal() public registerMember {
        vm.prank(coconuts);
        factory.submitProposal(
            TEST_DESCRIPTION,
            TEST_INVIDIDUAL_FEE,
            TEST_NB_OF_CUSTOMERS,
            TEST_IMG_URL,
            TEST_INTERNAL_ID
        );
        assertEq(factory.getNbOfPendingProposals(address(coconuts)), 1);
        assertEq(
            factory.getPendingProposal(0, address(coconuts)).internalId,
            TEST_INTERNAL_ID
        );
    }

    /*** CANCEL PROPOSAL*/
    //

    /*** DEPLOY PROPOSAL*/
    function testOWnerDeployedProperly() public registerMember {
        vm.prank(coconuts);
        factory.submitProposal(
            TEST_DESCRIPTION,
            TEST_INVIDIDUAL_FEE,
            TEST_NB_OF_CUSTOMERS,
            TEST_IMG_URL,
            TEST_INTERNAL_ID
        );
        assertEq(factory.getNbOfPendingProposals(address(coconuts)), 1);
        vm.prank(msg.sender);

        factory.approveAndDeployProposal(address(coconuts), TEST_INTERNAL_ID);
        DeployedMinimal memory deployedInfo = factory.getDeployed(
            address(coconuts),
            0
        );
        assertEq(deployedInfo.deployed != address(0), true);
        assertEq(factory.getNbOfPendingProposals(address(coconuts)), 0);
        BulkDeal bulkDeal = BulkDeal(deployedInfo.deployed);
        assertEq(bulkDeal.getInternalId(), TEST_INTERNAL_ID);
    }

    // only owner can deploy proposal

    //
    //function testAddMemberToArrayOfMembers() public {
    //   vm.startPrank(alice);
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

    // function onlySenderOrOwnerCanCancelProposal
}
