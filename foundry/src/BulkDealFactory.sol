// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { BulkDeal } from "./BulkDeal.sol";
import { DealProposalToValidate, DealProposalDeployed } from "../src/structs/BulkDealProposal.sol";


/**
 * 
 */
contract BulkDealFactory {
    /** Errors */
    error BulkDealFactory__InvalidMembershipFee(uint256 required, uint256 passed);
    error BulkDealFactory__ApplierAlreadyRegistered(address applier);
    error BulkDealFactory__UnsufficientFunds(uint256 contractBalance);
    error BulkDealFactory__ProposalAlreadySubmitted(string internalId);
    /** events */

    /** attributes */
    uint256 private constant MINIMAL_MEMBERSHIP_FEE = 0.01 ether;
    address immutable i_owner;
    mapping(address member => bool isRegistered) s_members;
    mapping(address vendor => mapping(string proposalId => DealProposalToValidate)) s_pendingProposals;
    mapping(address vendor => mapping(address deployedContract => DealProposalDeployed[])) s_deployedProposals;
    address[] private publishedBulkDeals;

    constructor() {
        i_owner = msg.sender;
        // Owner is added to member lists since he can also propose deals
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

    /** prout */

    // Any address could join the membership by paying a membership fee
    function applyForMembership() public payable {
        if (msg.value == MINIMAL_MEMBERSHIP_FEE) {
            revert BulkDealFactory__InvalidMembershipFee({required: MINIMAL_MEMBERSHIP_FEE, passed: msg.value});
        }
        if (s_members[msg.sender] == true) {
            revert BulkDealFactory__ApplierAlreadyRegistered({applier: msg.sender});
        }
        s_members[msg.sender] = true;
    }

    function removeMembership(address memberToRemove) public ownerOnly {
        require(s_members[memberToRemove] = true, "not in list");
        // TODO + has no pending proposal
        // refund memebership fee if contract funds are ok
        if(address(this).balance > MINIMAL_MEMBERSHIP_FEE) {
            revert BulkDealFactory__UnsufficientFunds(address(this).balance);
        }
        // refund the initial fee to the member to remove
        (bool callSuccess,) = payable(memberToRemove).call{value: MINIMAL_MEMBERSHIP_FEE}("");
        require(callSuccess, "Call failed");
        s_members[memberToRemove] = false;
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
        // TODO check if internalId sent by customer is not already taken 
        if (s_pendingProposals[msg.sender][internalId].individualFeeInEur == 0) {
            revert BulkDealFactory__ProposalAlreadySubmitted(internalId);
        }

        DealProposalToValidate memory deal = DealProposalToValidate({
            goodsDescription: _goodsDescription,
            individualFeeInEur: _individualFeeInEur,
            requiredNbOfCustomers: _requiredNbOfCustomers
        });
        s_pendingProposals[msg.sender][internalId] = deal;
    }

    function cancelProposal() public memberOnly {

    }

    
    /** getters */
    function getMembershipFee() public pure returns(uint256) {
        return MINIMAL_MEMBERSHIP_FEE;
    } 

    // function getProposalsByMember() public returns () {
        
    // }

    // function getDeployedDeal(uint256 index) public view returns (address) {
    //     return publishedBulkDeals[index];
    // }
}
