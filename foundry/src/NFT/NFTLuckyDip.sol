// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {LuckyDip} from "./structs/LuckyDip.sol";

// TODO FOR LATER
// 1) add an oracle triggering service to execute automatically closure of luckyDipBidden depending on validity time
// 2) rethink about payable membership...

/**
 * @title NFTLuckyDip is a bid application of luckyDips selling the ownership of a set of nft designed by a unique artist
 * The artworks are hosted on chain, since they are  svg files encoded on base 64. The particylarity of the lukcy dips is that the
 * pictures are only exposed when the final bid is achieved and final NFT contract deployed.
 * @author ybim
 * @notice After deployment of contract, a unlimited number of lucky dips can be send by the owner of the contract
 * For more, follow instructions in the read me file or in the Contract script/DeployNFTLuckyDip.s.sol
 */
contract NFTLuckyDip {
    /** * ERRORS */
    error NFTLuckyDip__OwnerOnly();
    error NFTLuckyDip__MemberOnly();
    error NFTLuckyDip__InvalidMembershipFeeSent(
        uint256 required,
        uint256 passed
    );
    error NFTLuckyDip__CantRemoveOwnerFromMembers();
    error NFTLuckyDip__ApplierAlreadyRegistered(address applier);
    error NFTLuckyDip__UnsufficientFunds(uint256 contractBalance);
    error NFTLuckyDip__InexistantMember(address memberToRemove);

    /** * CONSTANTS */
    uint256 private constant MEMBERSHIP_FEE = 0.01 ether;
    /** * Events */
    event NewBid(
        uint256 indexed luckyDipIndex,
        address indexed bestBidder,
        uint256 indexed bid,
        address prevBidder
    );
    /** * STATES */
    address private i_owner;
    LuckyDip[] private s_luckyDips;

    /*** MODIFIERS */
    modifier ownerOnly() {
        if (msg.sender != i_owner) {
            revert NFTLuckyDip__OwnerOnly();
        }
        _;
    }

    constructor() {
        i_owner = msg.sender;
    }

    function addLuckyDip(
        string memory _description,
        string memory _symbol,
        string memory _name,
        uint256 _startingBid,
        uint256 _bidStep,
        string[] memory imageUris
    ) public ownerOnly {
        // TODO require is owner
        s_luckyDips.push(
            LuckyDip(
                false,
                _description,
                _symbol,
                _name,
                _startingBid,
                _bidStep,
                0,
                address(0),
                address(0),
                imageUris.length,
                imageUris
            )
        );
    }

    function bidForLuckyDip(uint256 i) public payable {
        //check if amount sent is ok for winning
        // cehck conract balance and send back the money to previous bidder.
        // update the luckydip info with the new bestBidder address, and the next step to reach
        // create the event
    }

    function openLuckyDipBid(uint256 i) public ownerOnly {
        s_luckyDips[i].isPublished = true;
    }

    function endLuckyDipBid() public ownerOnly {
        // for given lucky dip check avialbiliy duration and pick the winner, create the ERC721 contract and mint the related nft
        // give the address the full ownership of thjis contract
    }

    /*** GETTERS */
    function getNbOfLuckyDips() public view returns (uint256) {
        return s_luckyDips.length;
    }

    function getLuckyDipNFT(
        uint256 i,
        uint256 j
    ) public view returns (string memory) {
        return s_luckyDips[i].nftImageUris[j];
    }
    
    function getLuckyDipDescription(uint256 i) public view returns (string memory) {
        return s_luckyDips[i].description;
    }

    function getLuckyDipNFTLength(uint256 i) public view returns (uint256) {
        return s_luckyDips[i].nftImageUris.length;
    }

    function getStartingBid(uint256 i) public view returns (uint256) {
        return s_luckyDips[i].startingBid;
    }

    function getNextBiddingPriceInWei(uint256 i) public view returns (uint256) {
        return (s_luckyDips[i].startingBid +
            (s_luckyDips[i].bidStep * s_luckyDips[i].nextBidStep));
    }

    function getLuckyDipStatus(uint256 i) public view returns (bool) {
        return s_luckyDips[i].isPublished;
    }

    function getOwner() public virtual returns (address) {
        return i_owner;
    }
}
