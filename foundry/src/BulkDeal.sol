// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract BulkDeal {
    string private s_description;
    address private s_owner;

    constructor() {
        s_owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == s_owner, "PROUT");
        _;
    }

    function getDescription() public view returns (string memory) {
        return s_description;
    }

    function getOwner() public view returns (address) {
        return s_owner;
    }
}
