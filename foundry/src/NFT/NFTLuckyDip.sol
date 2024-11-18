// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {LuckyDip} from "./structs/LuckyDip.sol";
import {console} from "forge-std/Script.sol";
// TODO FOR LATER
// 1) Add a time interval which is validity duration in seconds of the bip. 
// 2) this interval has to be .... before any validation of winning bid 
// 3) add an oracle triggering service to execute automatically closure of luckyDipBidden

/**
 * @title NFTLuckyDip is a bid application of luckyDips selling the ownership of a set of nft designed by a unique artist
 * The artworks are hosted on chain, since they are  svg files encoded on base 64. The particylarity of the lukcy dips is that the
 * pictures are only exposed when the final bid is achieved and final NFT contract deployed.
 * @author ybim
 * @notice After deployment of contract, a unlimited number of lucky dips can be send by the owner of the contract
 * For more, follow instructions in the read me file or in the Contract script/DeployNFTLuckyDip.s.sol
 */
contract NFTLuckyDip {
    /*** ERRORS */
    error NFTLuckyDip__OwnerOnly();
    error NFTLuckyDip__InvalidBiddingAmount(address caller, uint256 sentValue);
    error NFTLuckyDip__BidAlreadyAchieved(uint256 index);
    error NFTLuckyDip__BidNotOpenYet(uint256 index);
    error NFTLuckyDip__UnsufficientFunds(uint256 amountToSend, uint currentBalance);
    error NFTLuckyDip__CantBidWhenAlreadyBestBidder(uint256 index);
    /*** CONSTANTS */
    uint256 private constant MEMBERSHIP_FEE = 0.01 ether;
    /*** Events */
    event NewBid(uint256 indexed luckyDipIndex, address indexed bestBidder, uint256 indexed bid);
    /*** STATES */
    address private i_owner;
    LuckyDip[] private s_luckyDips;

    /*** MODIFIERS */
    modifier ownerOnly() {
        if (msg.sender != i_owner) {
            revert NFTLuckyDip__OwnerOnly();
        }
        _;
    }

    modifier isBiddable(uint256 i) {
        if (s_luckyDips[i].isPublished == false) {
            revert NFTLuckyDip__BidNotOpenYet(i);
        }
        // check if not already deployed 
        if (s_luckyDips[i].deployed != address(0)) {
            revert NFTLuckyDip__BidAlreadyAchieved(i);
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
                imageUris
            )
        );
    }

    function bidForLuckyDip(uint256 i) public payable isBiddable(i) {
        //check if previous isn't the same as msg.sender
        if (msg.sender == s_luckyDips[i].bestBidder) {
            revert NFTLuckyDip__CantBidWhenAlreadyBestBidder(i);
        }
        //check if amount sent is ok for winning the bid
        if (msg.value != getNextBiddingPriceInWei(i)) {
            revert NFTLuckyDip__InvalidBiddingAmount(msg.sender, msg.value);
        }

        // Check if it has a previous bidder. 
        if (s_luckyDips[i].bestBidder != address(0)) {
            uint256 prevBid = s_luckyDips[i].startingBid + (s_luckyDips[i].bidStep * (s_luckyDips[i].nextBidStep - 1));
            // then check contract balance 
            if (address(this).balance < prevBid) {
                revert NFTLuckyDip__UnsufficientFunds(prevBid, address(this).balance);
            }
            // send back the previous bid amount to prev bidder
            (bool callSuccess,) = payable(s_luckyDips[i].bestBidder).call{value: prevBid}("");
            require(callSuccess, "Call failed");
        }
        s_luckyDips[i].bestBidder = msg.sender;
        s_luckyDips[i].nextBidStep++;
        emit NewBid(i, msg.sender, msg.value);
    }

    function openBid(uint256 i) public ownerOnly {
        s_luckyDips[i].isPublished = true;
    }

    // for given lucky dip check avialbiliy duration and pick the winner, create the ERC721 contract and mint the related nft
    function endLuckyDipBid() public ownerOnly {  
        // no one has ever bid  
        if (getBestBidder(0) != address(0)) {

        }
        // give the address the full ownership of thjis contract
    }

    /*** GETTERS*/
    function isLuckyDipPublished(uint256 i) public view returns (bool) {
        return s_luckyDips[i].isPublished;
    }

    function getNbOfLuckyDips() public view returns (uint256) {
        return s_luckyDips.length;
    }

    function getLuckyDipNFT(uint256 i, uint256 j) public view returns (string memory) {
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
        return (s_luckyDips[i].startingBid + (s_luckyDips[i].bidStep * s_luckyDips[i].nextBidStep));
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }
    
    function getBestBidder(uint256 i) public view returns (address) {
        return s_luckyDips[i].bestBidder;
    }
}
