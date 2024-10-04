// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {BulkDeal} from "./BulkDeal.sol";

contract BulkDealFactory {
    // address immutable i_owner;
    mapping(address member => bool isRegistered) s_members;
    mapping(address proposer => BulkDealProposal projectContent) s_proposals;
    address[] private publishedBulkDeals;

    struct BulkDealProposal {
        string goodsDescription;
        // date de fin ?
        uint256 minimalContribution;
        uint256 requiredNbOfAttendees;
        address seller;
    }

    // modifier ownerOnly {
    //     require(msg.sender == i_owner);
    //     _;
    // }

    modifier memberOnly() {
        require(s_members[msg.sender]);
        _;
    }

    // when factory is initialized, all legitimate member addresses of the coownership must be added by the admin
    function applyForMembership() public payable {}

    // if a
    function leaveMembership(address member) public {}

    function approveDealDeployment() public {
        // BulkDeal publishedBulkDeal = new BulkDeal();
        // publishedBulkDeals.push(address(publishedBulkDeal));
    }

    function getDeployedDeal(uint256 index) public view returns (address) {
        return publishedBulkDeals[index];
    }
}
