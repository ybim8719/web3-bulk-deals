// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;
import { TrusteeVoting } from './TrusteeVoting.sol';

contract VotingFactory {
    address immutable i_owner;
    address[] private deployedContracts;
    mapping (address member => bool isRegistered) s_members;
    mapping (address proposer => VotingProposal projectContent) s_proposals;
    
    // should contain a 
    struct VotingProposal {
        string description;
        uint256 amountToSend; 
    }

    modifier onlyOwner {
        require(msg.sender == i_owner);  
    }

    modifier onlyMember {
        require(s_members[msg.sender]);    
    }

    // when factory is initialized, all legitimate member addresses of the coownership must be added by the admin
    function addVoter(address addVoter) public {
        
    }

    function submitProposal() public {

    }

  

    // add members of the committee / only possible by 

    function addMember() {

    }

    function removeMember(address member) {

    }


    function getDeployedContract(uint256 index) public view returns (address) {
        return deployedContracts[index];
    }

    function deployNewContract() public {
        TrusteeVoting deployedContract = new TrusteeVoting();
        deployedContracts.push(address(deployedContract));
    }
}