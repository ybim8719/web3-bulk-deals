// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {LuckyDip} from "../../src/NFT/structs/LuckyDip.sol";
import {NFTLuckyDip} from "../../src/NFT/NFTLuckyDip.sol";
import {DeployNFTLuckyDip} from "../../script/NFT/DeployLuckyDip.s.sol";

contract NftLuckyDipTest is Test {
    //TODO adding of mocked luckydips should be managed with a json file from test contract
    uint256 private constant SEND_VALUE = 0.01 ether;
    uint256 constant STARTING_BALANCE = 10 ether;
    address user1 = makeAddr("cochonou");

    NFTLuckyDip public luckyDip;

    function setUp() external {
        DeployNFTLuckyDip deployer = new DeployNFTLuckyDip();
        luckyDip = deployer.runWithoutPopulating();
        //vm.deal(user1, STARTING_BALANCE);
    }

    /*** MODIFIERS */
    modifier registered() {
        vm.prank(user1);
        luckyDip.applyForMembership{value: SEND_VALUE}();
        assert(address(luckyDip).balance == SEND_VALUE);
        // assertEq(luckyDip.getMember(address(user1)), true);
        _;
    }

    /*** UNIT TESTS */
    function testLuckyDipWasImported() public view {
        assertEq(luckyDip.getLuckyDipNFTLength(0), 2);
        assertEq(luckyDip.getLuckyDipNFTLength(1), 2);
    }

    // function testInitializedCorrectly() public view {
    //     assert(keccak256(abi.encodePacked(moodNft.name())) == keccak256(abi.encodePacked((NFT_NAME))));
    //     assert(keccak256(abi.encodePacked(moodNft.symbol())) == keccak256(abi.encodePacked((NFT_SYMBOL))));
    // }
}
