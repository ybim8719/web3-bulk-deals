// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {DeployedDeal} from "../src/structs/BulkDealProposal.sol";

contract BulkDeal {
    /**
     * error
     */
    /**
     * events
     */

    /**
     * data
     */
    address private immutable i_owner;
    DeployedDeal private s_deal;
    address[] s_customers;

    constructor(DeployedDeal memory deal) {
        i_owner = deal.seller;
        s_deal = deal;
    }

    /**
     * modifiers
     */
    modifier onlyOwner() {
        require(msg.sender == i_owner, "PROUT");
        _;
    }

    /**
     * transactions
     */
    function buy() external payable {
        // convert ETH send into EUR
        // require minimal amount is enought and equal to contribution.
        // if
        s_customers.push(msg.sender);
    }

    /**
     * getters
     */
    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getDeal() public view returns (DeployedDeal memory) {}
}
