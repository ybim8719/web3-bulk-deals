// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BulkDeal} from "./BulkDeal.sol";
import {DealProposalToValidate, DeployedDeal, DeployedMinimal} from "../src/structs/BulkDealProposal.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import {PriceConverter} from "./utils/PriceConverter.sol";

/**
 * @title A sample Raffle Contract
 * @author moi
 * @notice This contract is for creating a sample raffle
 * @dev It implements Chainlink VRFv2 and Chainlink Automation
 */
contract DealFactory {
    using PriceConverter for uint256;
    /** * ERRORS */
    error DealFactory__InvalidMembershipFeeSent(
        uint256 required,
        uint256 passed
    );
    error DealFactory__CantRemoveOwnerFromMembers();
    error DealFactory__ApplierAlreadyRegistered(address applier);
    error DealFactory__UnsufficientFunds(uint256 contractBalance);
    error DealFactory__ProposalAlreadySubmitted(string internalId);
    error DealFactory__ProposalToCancelWasNotFoundOrAlreadyDeployed(
        string internalId
    );
    error DealFactory__InexistantMember(address memberToRemove);
    error DealFactory__MemberHasPendingProposal(address memberToRemove);
    error DealFactory__ProposalNotFound(string internalId, address seller);
    error DealFactory__MaxNumberOfProposalReached(
        string internalId,
        address seller
    );

    error DealFactory__OwnerOnly();
    error DealFactory__MemberOnly();
    /** * CONSTANTS */
    uint256 private constant MEMBERSHIP_FEE = 0.01 ether;
    uint256 private constant MAX_PENDING_PROPOSALS_PER_MEMBER = 10;
    /*** EVENTS */
    event ProposalPublished(
        address indexed _newContract,
        address indexed _seller,
        string _internalId
    );
    event ProposalCancelled(address member, string internalId);

    /** * STORAGE */
    AggregatorV3Interface private immutable i_priceFeed;
    address private immutable i_owner;
    mapping(address member => bool isRegistered) private s_members;
    mapping(address vendor => DealProposalToValidate[] pending)
        private s_pendingProposals;
    mapping(address vendor => DeployedMinimal[] deployed)
        private s_deployedProposals;

    constructor(address priceFeed) {
        i_owner = msg.sender;
        // Owner is added to member lists since he can also propose deals
        s_members[msg.sender] = true;
        i_priceFeed = AggregatorV3Interface(priceFeed);
    }

    /*** MODIFIERS */
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

    function applyForMembership() public payable {
        if (msg.value != MEMBERSHIP_FEE) {
            revert DealFactory__InvalidMembershipFeeSent({
                required: MEMBERSHIP_FEE,
                passed: msg.value
            });
        }
        if (s_members[msg.sender] == true) {
            revert DealFactory__ApplierAlreadyRegistered({applier: msg.sender});
        }
        s_members[msg.sender] = true;
    }

    // TODO MAKE the pending proposal payable ?

    function removeMembership(address memberToRemove) public ownerOnly {
        if (msg.sender == memberToRemove) {
            revert DealFactory__CantRemoveOwnerFromMembers();
        }
        if (s_members[memberToRemove] == false) {
            revert DealFactory__InexistantMember(memberToRemove);
        }

        if (s_pendingProposals[memberToRemove].length > 0) {
            revert DealFactory__MemberHasPendingProposal(memberToRemove);
        }

        // refund membership fee if contract funds are ok
        if (address(this).balance > MEMBERSHIP_FEE) {
            revert DealFactory__UnsufficientFunds(address(this).balance);
        }
        // refund the initial fee to the member to remove
        (bool callSuccess, ) = payable(memberToRemove).call{
            value: MEMBERSHIP_FEE
        }("");
        require(callSuccess, "Call failed");
        s_members[memberToRemove] = false;
    }

    function submitProposal(
        string memory _goodsDescription,
        uint256 _individualFeeInUsd,
        uint256 _requiredNbOfCustomers,
        string memory _imageUrl,
        string memory _internalId
    ) public memberOnly {
        if (s_pendingProposals[msg.sender].length > 0) {
            // max num of proposal reached
            if (
                s_pendingProposals[msg.sender].length ==
                MAX_PENDING_PROPOSALS_PER_MEMBER
            ) {
                revert DealFactory__MaxNumberOfProposalReached(
                    _internalId,
                    msg.sender
                );
            }
            // check if proposal (by internalId) sent by customer is not already in list
            for (
                uint256 i = 0;
                i < s_pendingProposals[msg.sender].length;
                i++
            ) {
                if (keccak256(abi.encodePacked(s_pendingProposals[msg.sender][i].internalId)) == keccak256(abi.encodePacked(_internalId))) {
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

    function ownerCancelsPendingProposal(
        address _member,
        string memory _internalId
    ) public ownerOnly {
        if (s_pendingProposals[_member].length == 0) {
            revert DealFactory__ProposalNotFound(_internalId, _member);
        }
        findAndDeletePendingProposal(_member, _internalId);
    }

    function cancelPendingProposal(string memory _internalId) public memberOnly {
        if (s_pendingProposals[msg.sender].length == 0) {
            revert DealFactory__ProposalNotFound(_internalId, msg.sender);
        }
        findAndDeletePendingProposal(msg.sender, _internalId);
    }

    function findAndDeletePendingProposal(
        address _member,
        string memory _internalId
    ) internal {
        // this index is max length of proposals array, it can't be reached
        uint256 indexToRemove = MAX_PENDING_PROPOSALS_PER_MEMBER;
        // find related index in proposals[]
        for (uint256 i = 0; i < s_pendingProposals[_member].length; i++) {
            if (keccak256(abi.encodePacked(s_pendingProposals[_member][i].internalId)) == keccak256(abi.encodePacked(_internalId))) {
                indexToRemove = i;
            }
        }
        deletePendingProposal(indexToRemove, _member, _internalId);
    }

    function approveAndDeployProposal(
        address _seller,
        string memory _internalId
    ) public ownerOnly {
        if (s_pendingProposals[_seller].length == 0) {
            revert DealFactory__ProposalNotFound(_internalId, _seller);
        }
        // find proposal and deploy it
        uint256 indexToRemove = MAX_PENDING_PROPOSALS_PER_MEMBER;

        for (uint256 i = 0; i < s_pendingProposals[_seller].length; i++) {
            if (keccak256(abi.encodePacked(s_pendingProposals[_seller][i].internalId)) == keccak256(abi.encodePacked(_internalId))) {
                DealProposalToValidate memory deal = s_pendingProposals[
                    _seller
                ][i];
                // TODO / convert eur individualFeeInEur into individualFeeInEth with chainlink datafeed
                //uint256 public constant MINIMUM_USD = 5 * 10 ** 18;
                uint256 requiredAmountInWei = PriceConverter.getConversionRate(
                    deal.individualFeeInUsd,
                    i_priceFeed
                );
                // GO deploy
                DeployedDeal memory enrichedDeal = DeployedDeal({
                    goodsDescription: deal.goodsDescription,
                    individualFeeInWei: requiredAmountInWei,
                    requiredNbOfCustomers: deal.requiredNbOfCustomers,
                    seller: _seller,
                    imageUrl: deal.imageUrl,
                    internalId: deal.internalId
                });
                BulkDeal deployedDeal = new BulkDeal(enrichedDeal);
                // add to deployed list
                DeployedMinimal memory minimal = DeployedMinimal({
                    deployed: address(deployedDeal),
                    internalId: _internalId
                });
                s_deployedProposals[_seller].push(minimal);
                emit ProposalPublished(
                    address(deployedDeal),
                    _seller,
                    _internalId
                );
                indexToRemove = i;
            }
        }
        if (indexToRemove == MAX_PENDING_PROPOSALS_PER_MEMBER) {
            revert DealFactory__ProposalNotFound(_internalId, _seller);
        }
        // remove from pending list
        deletePendingProposal(indexToRemove, _seller, _internalId);
    }

    function deletePendingProposal(
        uint256 _indexToRemove,
        address _member,
        string memory _internalId
    ) internal {
        if (_indexToRemove < MAX_PENDING_PROPOSALS_PER_MEMBER) {
            if (s_pendingProposals[_member].length > 0) {
                for (
                    uint256 i = _indexToRemove;
                    i < s_pendingProposals[_member].length - 1;
                    i++
                ) {
                    s_pendingProposals[_member][i] = s_pendingProposals[
                        _member
                    ][i + 1];
                }
                s_pendingProposals[_member].pop();
                emit ProposalCancelled(_member, _internalId);
            }
        }
    }

    /*** GETTERS */
    function getMembershipFee() public pure returns (uint256) {
        return MEMBERSHIP_FEE;
    }

    function getOwner() external view returns (address) {
        return i_owner;
    }

    function isMember(address member) external view returns (bool) {
        return s_members[member];
    }

    function getPriceFeedVersion() public view returns (uint256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(i_priceFeed);
        return priceFeed.version();
    }

    function getUsdToEthCurrentRate() public view returns (int256) {
        AggregatorV3Interface priceFeed = AggregatorV3Interface(i_priceFeed);
        (, int256 answer, , , ) = priceFeed.latestRoundData();
        return answer;
    }

    function getNbOfPendingProposals(
        address member
    ) external view returns (uint256) {
        return s_pendingProposals[member].length;
    }

    function getPendingProposal(
        uint256 index,
        address member
    ) public view returns (DealProposalToValidate memory) {
        return s_pendingProposals[member][index];
    }

    function getDeployed(
        address member,
        uint256 index
    ) public view returns (DeployedMinimal memory) {
        //TODO verify that index exists ?
        return s_deployedProposals[member][index];
    }

    function getNbOfDeployed(address member) public view returns (uint256) {
        return s_deployedProposals[member].length;
    }

    function getMember(address member) public view returns (bool) {
        return s_members[member];
    }

    fallback() external payable {}

    receive() external payable {}
}
