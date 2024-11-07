// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {LuckyDip} from "./structs/LuckyDip.sol";

// TODO FOR LATER 
// 1) add an oracle triggering service to execute automatically closure of luckyDipBidden depending on validity time
// 2) rethink about payable membership... 

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
    /** * States */
    address private i_owner;
    mapping(address member => bool isRegistered) private s_members;
    LuckyDip[] private s_luckyDips;

    /*** MODIFIERS */
    modifier ownerOnly() {
        if (msg.sender != i_owner) {
            revert NFTLuckyDip__OwnerOnly();
        }
        _;
    }

    modifier memberOnly() {
        if (s_members[msg.sender] == false) {
            revert NFTLuckyDip__MemberOnly();
        }
        _;
    }

    constructor() {
        i_owner = msg.sender;
    }

    function addLuckyDip(
        bool _isPublished,
        string memory _description,
        string memory _symbol,
        string memory _name,
        uint256 _startingBid,
        uint256 _bidStep,
        string[] memory imageUris
    ) public {
        // TODO require is owner
        s_luckyDips.push(LuckyDip(
            _isPublished,
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
        ));
    }

    function applyForMembership() public payable {
        if (msg.value != MEMBERSHIP_FEE) {
            revert NFTLuckyDip__InvalidMembershipFeeSent({
                required: MEMBERSHIP_FEE,
                passed: msg.value
            });
        }
        if (s_members[msg.sender] == true) {
            revert NFTLuckyDip__ApplierAlreadyRegistered({applier: msg.sender});
        }
        s_members[msg.sender] = true;
    }

    function removeMembership(address memberToRemove) public ownerOnly {
        if (msg.sender == memberToRemove) {
            revert NFTLuckyDip__CantRemoveOwnerFromMembers();
        }
        if (s_members[memberToRemove] == false) {
            revert NFTLuckyDip__InexistantMember(memberToRemove);
        }
        // TODO member has bought a collectionNFT
        // if (s_pendingProposals[memberToRemove].length > 0) {
        //     revert NFTLuckyDip__MemberHasPendingProposal(memberToRemove);
        // }

        // refund membership fee if contract funds are ok
        if (address(this).balance > MEMBERSHIP_FEE) {
            revert NFTLuckyDip__UnsufficientFunds(address(this).balance);
        }
        // refund the initial fee to the member to remove
        (bool callSuccess, ) = payable(memberToRemove).call{
            value: MEMBERSHIP_FEE
        }("");
        require(callSuccess, "Call failed");
        s_members[memberToRemove] = false;
    }

    function bidForLuckyDip(uint256 i) public payable memberOnly {
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
    function getNbOfLuckyDips() public view returns(uint256) {
        return s_luckyDips.length;
    }

    function getLuckyDipNFT(uint256 i, uint256 j) public view returns(string memory) {
        return s_luckyDips[i].nftImageUris[j];
    }

    function getLuckyDipNFTLength(uint256 i) public view returns(uint256) {
        return s_luckyDips[i].nftImageUris.length;
    }

    function getNextBiddingPriceInWei(uint256 i) public view returns(uint256) {
        return (s_luckyDips[i].startingBid + (s_luckyDips[i].bidStep * s_luckyDips[i].nextBidStep));
    }

    function getLuckyDipStatus(uint256 i) public view returns(bool) {
        return s_luckyDips[i].isPublished;
    }
}
