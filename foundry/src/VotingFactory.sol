// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

contract VotingFactory {
    address[] public deployedContracts;
    
    function getDeployedContract(uint256 index) public view returns (address) {
        return deployedContracts[index];
    }
}