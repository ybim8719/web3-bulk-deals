// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import {DealProposalToValidate} from "../src/structs/BulkDealProposal.sol";

contract BulkDeal {
    address immutable i_owner;
    DealProposalToValidate s_proposal;

    constructor(DealProposalToValidate memory proposal) {
        i_owner = msg.sender;
        s_proposal = proposal;
    }

    modifier onlyOwner() {
        require(msg.sender == i_owner, "PROUT");
        _;
    }

    function getOwner() public view returns (address) {
        return i_owner;
    }
}
