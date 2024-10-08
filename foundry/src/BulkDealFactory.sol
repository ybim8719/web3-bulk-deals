// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BulkDeal} from "./BulkDeal.sol";
import { DealProposalToValidate, DealProposalDeployed } from "../src/structs/BulkDealProposal.sol";

error InvalidMembershipFee(uint256 required, uint256 passed);
error ApplierAlreadyRegistered(address applier);

contract BulkDealFactory {

    uint256 private constant MINIMAL_MEMBERSHIP_FEE = 0.01 ether;
    address immutable i_owner;
    mapping(address member => bool isRegistered) s_members;
    mapping(address vendor => mapping(string proposalId => DealProposalToValidate)) s_pendingProposals;
    mapping(address vendor => mapping(address deployedContract => DealProposalDeployed[])) s_deployedProposals;

    address[] private publishedBulkDeals;

    constructor() {
        i_owner = msg.sender;
        // add owner to member lists since he can propose deals
        s_members[msg.sender] = true;
    }

    /** modifiers */
    modifier ownerOnly() {
        require(msg.sender == i_owner, "Action forbidden for non owner addresses");
        _;
    }

    modifier memberOnly() {
        require(s_members[msg.sender], "Action forbidden for non member addresses");
        _;
    }

    // Any address could join the membership by paying a membership fee
    function applyForMembership() public payable {
        if (msg.value == MINIMAL_MEMBERSHIP_FEE) {
            revert InvalidMembershipFee({required: MINIMAL_MEMBERSHIP_FEE, passed: msg.value});
        }
        if (s_members[msg.sender] == true) {
            revert ApplierAlreadyRegistered({applier: msg.sender});
        }
        s_members[msg.sender] = true;
    }

    function removeMembership(address member) public ownerOnly {
        // if member is in the list of members...
        require(s_members[member] = true, "not in list");
        // TODO + has no pending proposal
        // refund if balance is ok
        require(address(this).balance > MINIMAL_MEMBERSHIP_FEE, "insufficient funds");
        s_members[member] = false;
    }

    // deployment of proposal if owner ok
    function approveProposalDeployment() public ownerOnly {
        // BulkDeal publishedBulkDeal = new BulkDeal();
        // publishedBulkDeals.push(address(publishedBulkDeal));
    }

    function submitProposal(
        string memory _goodsDescription,
        uint256 _individualFeeInEur,
        uint256 _requiredNbOfCustomers,
        string memory internalId
    ) public memberOnly {
        DealProposalToValidate memory deal = DealProposalToValidate({
            goodsDescription: _goodsDescription,
            individualFeeInEur: _individualFeeInEur,
            requiredNbOfCustomers: _requiredNbOfCustomers
        });
        s_pendingProposals[msg.sender][internalId] = deal;
    }

    /** getters */
    // function getProposalsByMember() public returns () {
        
    // }

    // function getDeployedDeal(uint256 index) public view returns (address) {
    //     return publishedBulkDeals[index];
    // }
}
