// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract TrusteeVoting {
    string private s_description;
    address private s_owner;
    
    constructor (string memory description) {
        s_description = description;
        s_owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == s_owner)    
    }

    function getDescription() public view returns (string) {
        return s_description;
    }

    function getOwner() public view returns (address) {
        return s_owner;
    }
}