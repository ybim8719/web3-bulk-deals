// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {DeployedDeal} from "./structs/BulkDealProposal.sol";

contract BulkDeal {
    /*//////////////////////////////////////////////////////////////
                            STATES
    //////////////////////////////////////////////////////////////*/
    address private immutable i_owner;
    DeployedDeal private s_deal;
    address[] s_customers;

    /*//////////////////////////////////////////////////////////////
                            MODIFIERS
    //////////////////////////////////////////////////////////////*/
    modifier onlyOwner() {
        require(msg.sender == i_owner, "PROUT");
        _;
    }

    constructor(DeployedDeal memory deal) {
        i_owner = deal.seller;
        s_deal = deal;
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

    /*//////////////////////////////////////////////////////////////
                            GETTERS
    //////////////////////////////////////////////////////////////*/
    function getOwner() public view returns (address) {
        return i_owner;
    }

    function getInternalId() public view returns (string memory) {
        return s_deal.internalId;
    }

    function getDeal()
        public
        view
        returns (
            string memory goodsDescription,
            uint256 individualFeeInWei,
            uint256 requiredNbOfCustomers,
            address seller,
            string memory imageUrl,
            string memory internalId
        )
    {
        return (
            s_deal.goodsDescription,
            s_deal.individualFeeInWei,
            s_deal.requiredNbOfCustomers,
            s_deal.seller,
            s_deal.imageUrl,
            s_deal.internalId
        );
    }
}
