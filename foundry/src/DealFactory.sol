// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { BulkDeal } from "./BulkDeal.sol";
import { DealProposalToValidate, DealProposalDeployed } from "../src/structs/BulkDealProposal.sol";


/**
 * 
 */
contract DealFactory {
    /** Errors */
    error DealFactory__InvalidMembershipFee(uint256 required, uint256 passed);
    error DealFactory__ApplierAlreadyRegistered(address applier);
    error DealFactory__UnsufficientFunds(uint256 contractBalance);
    error DealFactory__ProposalAlreadySubmitted(string internalId);
    error DealFactory__ProposalToCancelWasNotFoundOrAlreadyDeployed(string internalI);

    /** events */
    event ProposalPublished(
        address indexed _newContract,
        address indexed _seller,
        string _internalId
    );

    /** attributes */
    uint256 private constant MINIMAL_MEMBERSHIP_FEE = 0.01 ether;
    address immutable i_owner;
    mapping(address member => bool isRegistered) s_members;
    mapping(address vendor => mapping(string proposalId => DealProposalToValidate)) s_pendingProposals;
    mapping(address vendor => mapping(address proposalId => DealProposalDeployed[])) s_deployedProposals;
    address[] private publishedBulkDeals;

    AggregatorV3Interface private s_priceFeed;

    constructor() {
        i_owner = msg.sender;
        // Owner is added to member lists since he can also propose deals
        s_members[msg.sender] = true;
        s_priceFeed = AggregatorV3Interface(priceFeed);
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
            revert DealFactory__InvalidMembershipFee({required: MINIMAL_MEMBERSHIP_FEE, passed: msg.value});
        }
        if (s_members[msg.sender] == true) {
            revert DealFactory__ApplierAlreadyRegistered({applier: msg.sender});
        }
        s_members[msg.sender] = true;
    }

    function removeMembership(address memberToRemove) public ownerOnly {
        require(s_members[memberToRemove] = true, "not in list");
        // TODO + has no pending proposal
        // require(s_members[memberToRemove] != , "not in list");

        // refund membership fee if contract funds are ok
        if(address(this).balance > MINIMAL_MEMBERSHIP_FEE) {
            revert DealFactory__UnsufficientFunds(address(this).balance);
        }
        // refund the initial fee to the member to remove
        (bool callSuccess,) = payable(memberToRemove).call{value: MINIMAL_MEMBERSHIP_FEE}("");
        require(callSuccess, "Call failed");
        s_members[memberToRemove] = false;
    }

    // deployment of proposal by admin
    function approveAndDeployProposal(address seller, string memory internalId) public ownerOnly {
        // convert price in eth -> into eth in deployed contract
        DealProposalToValidate memory deal = s_pendingProposals[seller][internalId];
        // BulkDeal publishedDeal = new BulkDeal({
        //     proposal: deal
        // });

        // publishedBulkDeals.push(address(publishedDeal));
        // emit ProposalPublished(address(publishedDeal), seller, internalId);
    }

    function submitProposal(
        string memory _goodsDescription,
        uint256 _individualFeeInEur,
        uint256 _requiredNbOfCustomers,
        string memory _imageUrl,
        string memory internalId
    ) public memberOnly {
        // check if proposal (with internalId) sent by customer is not already submitted
        if (s_pendingProposals[msg.sender][internalId].individualFeeInEur == 0) {
            revert DealFactory__ProposalAlreadySubmitted(internalId);
        }

        DealProposalToValidate memory deal = DealProposalToValidate({
            goodsDescription: _goodsDescription,
            individualFeeInEur: _individualFeeInEur,
            requiredNbOfCustomers: _requiredNbOfCustomers,
            imageUrl: _imageUrl
        });
        s_pendingProposals[msg.sender][internalId] = deal;
    }

    function cancelPendingProposal(string memory internalId) public memberOnly {
        // check if proposal (with internalId) sent by customer is not already submitted
        if (s_pendingProposals[msg.sender][internalId].individualFeeInEur != 0) {
            revert DealFactory__ProposalToCancelWasNotFoundOrAlreadyDeployed(internalId);
        }
        // remove proposal from pending list
        s_pendingProposals[msg.sender][internalId].individualFeeInEur = 0;
    }
    
    /** getters */
    function getMembershipFee() public pure returns(uint256) {
        return MINIMAL_MEMBERSHIP_FEE;
    } 

    // function getProposalsByMember() public returns () {
        
    // }

    function getOwner() external view returns(address) {
        return i_owner;
    }

    // function getDeployedDeal(uint256 index) public view returns (address) {
    //     return publishedBulkDeals[index];
    // }

    function getVersion() public view returns (uint256){
        AggregatorV3Interface priceFeed = AggregatorV3Interface(s_priceFeed);
        return priceFeed.version();
    }
}
