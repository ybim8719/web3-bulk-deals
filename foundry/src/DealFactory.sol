// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BulkDeal} from "./BulkDeal.sol";
import {DealProposalToValidate, DealProposalDeployed} from "../src/structs/BulkDealProposal.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./utils/PriceConverter.sol";



/**
 *
 */
contract DealFactory {
    using PriceConverter for uint256;
    /** * Errors*/
    error DealFactory__InvalidMembershipFeeSent(uint256 required, uint256 passed);
    error DealFactory__ApplierAlreadyRegistered(address applier);
    error DealFactory__UnsufficientFunds(uint256 contractBalance);
    error DealFactory__ProposalAlreadySubmitted(uint256 internalId);
    error DealFactory__ProposalToCancelWasNotFoundOrAlreadyDeployed(uint256 internalId);
    error DealFactory__InexistantMember(address memberToRemove);
    error DealFactory__MemberHasPendingProposal(address memberToRemove);
    error DealFactory__ProposalNotFound(uint256 internalId, address seller);
    error DealFactory__OwnerOnly();
    error DealFactory__MemberOnly();
    /** * Const*/
    uint256 private constant MINIMAL_MEMBERSHIP_FEE = 0.01 ether;
    uint256 private constant MAX_PENDING_PROPOSALS_PER_MEMBER = 10; 
    /*** events*/
    event ProposalPublished(address indexed _newContract, address indexed _seller, uint256 _internalId);
    /** * storage */
    AggregatorV3Interface private immutable i_priceFeed;
    address immutable private i_owner;
    mapping(address member => bool isRegistered) private s_members;
    mapping(address vendor => DealProposalToValidate[]) private s_pendingProposals;
    mapping(address vendor => mapping(uint256 proposalId => address deployed)) private s_deployedProposals;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        // Owner is added to member lists since he can also propose deals
        s_members[msg.sender] = true;
        i_priceFeed = AggregatorV3Interface(priceFeed);
    }

    /*** modifiers */
    modifier ownerOnly() {
        if (msg.sender != i_owner) {
            revert DealFactory__OwnerOnly();
        }
        _;
    }

    modifier memberOnly() {
        if (s_members[msg.sender] == false) {
            revert DealFactory__MemberOnly();
        }
        _;
    }

    // OK / Any address could join the membership by paying a membership fee
    function applyForMembership() public payable {
        if (msg.value == MINIMAL_MEMBERSHIP_FEE) {
            revert DealFactory__InvalidMembershipFeeSent({required: MINIMAL_MEMBERSHIP_FEE, passed: msg.value});
        }
        if (s_members[msg.sender] == true) {
            revert DealFactory__ApplierAlreadyRegistered({applier: msg.sender});
        }
        s_members[msg.sender] = true;
    }
    // OK /
    function removeMembership(address memberToRemove) public ownerOnly {
        if (s_members[memberToRemove] = true) {
            revert DealFactory__InexistantMember(memberToRemove);
        }
    
        if (s_pendingProposals[memberToRemove].length > 0) {
            revert DealFactory__MemberHasPendingProposal(memberToRemove);
        }

        // refund membership fee if contract funds are ok
        if (address(this).balance > MINIMAL_MEMBERSHIP_FEE) {
            revert DealFactory__UnsufficientFunds(address(this).balance);
        }
        // refund the initial fee to the member to remove
        (bool callSuccess,) = payable(memberToRemove).call{value: MINIMAL_MEMBERSHIP_FEE}("");
        require(callSuccess, "Call failed");
        s_members[memberToRemove] = false;
    }

    // acceptance and deployment of a proposal by owner
    function approveAndDeployProposal(address seller, uint256 internalId) public ownerOnly {
        if (s_pendingProposals[seller].length == 0) {
            revert DealFactory__ProposalNotFound(internalId, seller);
        }
        // find proposal and deploy it
        uint256 indexToRemove = MAX_PENDING_PROPOSALS_PER_MEMBER;
        for (uint256 i = 0; i < s_pendingProposals[seller].length; i++) {
            if (s_pendingProposals[seller][i].internalId == internalId) {
                DealProposalToValidate memory deal = s_pendingProposals[seller][i];
                // TODO / convert eur individualFeeInEur into individualFeeInEth with chainlink datafeed
                //uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
                uint256 requiredAmountInWei = PriceConverter.getConversionRate(deal.individualFeeInUsd, i_priceFeed);
                // GO deploy
                DealProposalDeployed memory enrichedDeal = DealProposalDeployed({
                    goodsDescription: deal.goodsDescription,
                    individualFeeInWei: requiredAmountInWei,
                    requiredNbOfCustomers: deal.requiredNbOfCustomers,
                    seller: seller,
                    imageUrl: deal.imageUrl,
                    internalId: deal.internalId
                });
                BulkDeal deployedDeal = new BulkDeal(enrichedDeal);
                // add to deployed list
                s_deployedProposals[seller][deal.internalId] = address(deployedDeal);
                emit ProposalPublished(address(deployedDeal), seller, internalId);
                indexToRemove = i;
            }
        }
        // remove from pending list
        removePendingProposal(indexToRemove, msg.sender);
    }

    function submitProposal(
        string memory _goodsDescription,
        uint256 _individualFeeInUsd,
            uint256 _requiredNbOfCustomers,
        string memory _imageUrl,
        uint256 _internalId
    ) public memberOnly {
        // check if proposal (by internalId) sent by customer is not already in list
        if (s_pendingProposals[msg.sender].length > 0) {
            for (uint256 i = 0; i < s_pendingProposals[msg.sender].length; i++) {
                if (s_pendingProposals[msg.sender][i].internalId == _internalId) {
                    revert DealFactory__ProposalAlreadySubmitted(_internalId);
                }
            }
        }

        DealProposalToValidate memory deal = DealProposalToValidate({
            goodsDescription: _goodsDescription,
            individualFeeInUsd: _individualFeeInUsd,
            requiredNbOfCustomers: _requiredNbOfCustomers,
            imageUrl: _imageUrl,
            internalId: _internalId
        });
        s_pendingProposals[msg.sender].push(deal);
    }

    // member can remove his previous proposal
    function cancelPendingProposal(uint256 _internalId) public memberOnly {
        if (s_pendingProposals[msg.sender].length == 0) {
            revert DealFactory__ProposalNotFound(_internalId, msg.sender);
        }
        uint256 indexToRemove = MAX_PENDING_PROPOSALS_PER_MEMBER;
        // find correct index in proposal[] 
        for (uint256 i = 0; i < s_pendingProposals[msg.sender].length; i++) {
            if (s_pendingProposals[msg.sender][i].internalId == _internalId) {
                indexToRemove = i;
            }
        }
        removePendingProposal(indexToRemove, msg.sender);
    }

    function removePendingProposal(uint256 _indexToRemove, address _member) internal {
        if (_indexToRemove < MAX_PENDING_PROPOSALS_PER_MEMBER) {
            for (uint256 i = _indexToRemove; i < s_pendingProposals[_member].length - 1; i++) {
                s_pendingProposals[_member][i] = s_pendingProposals[_member][i + 1];
            }
            s_pendingProposals[_member].pop();
        }
    }

    /**
     * getters
     */
    function getMembershipFee() public pure returns (uint256) {
        return MINIMAL_MEMBERSHIP_FEE;
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function getVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(i_priceFeed);
        return priceFeed.version();
    }

    // function getDeployedDeal(uint256 index) public view returns (address) {
    //     return publishedBulkDeals[index];
    // }
       // function getProposalsByMember() public returns () {
    // }

    fallback() external payable {}
    receive() external payable {}
}
