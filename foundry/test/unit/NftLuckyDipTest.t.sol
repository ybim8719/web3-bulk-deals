// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {LuckyDip} from "../../src/NFT/structs/LuckyDip.sol";
import {NFTLuckyDip} from "../../src/NFT/NFTLuckyDip.sol";
import {DeployNFTLuckyDip} from "../../script/NFT/DeployLuckyDip.s.sol";

contract NftLuckyDipTest is Test {
    uint256 constant STARTING_BALANCE = 10 ether;
    string constant MOCK_LUCKY_DIP_NAME = "JeanMiMock";
    uint256 constant MOCK_LUCKY_DIP_STARTINGBID = 2500000000000000;
    uint256 constant MOCK_LUCKY_DIP_BIDSTEP = 10000000000000;
    // svg encoded on CLI
    string constant MOCK_LUCKY_DIP_IMAGE_URI1 =
        "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/PgoKPCEtLSBVcGxvYWRlZCB0bzogU1ZHIFJlcG8sIHd3dy5zdmdyZXBvLmNvbSwgR2VuZXJhdG9yOiBTVkcgUmVwbyBNaXhlciBUb29scyAtLT4KPHN2ZyBmaWxsPSIjMDAwMDAwIiB3aWR0aD0iODAwcHgiIGhlaWdodD0iODAwcHgiIHZpZXdCb3g9IjAgMCA1MTIgNTEyIiB2ZXJzaW9uPSIxLjEiIHhtbDpzcGFjZT0icHJlc2VydmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiPgoKPGcgaWQ9ImdpZnRfYm94LWJveF8taGVhcnQtbG92ZS12YWxlbnRpbmUiPgoKPHBhdGggZD0iTTQwOCwxNjBoLTY0YzE1LjU1LTAuMDIxLDI4LjQ4My0xMi43MTksMjguNTA0LTI4LjI2OWMwLjAyMS0xNS41NS0xMi41NjgtMjguMTM5LTI4LjExOC0yOC4xMTggICBjMC4wMjMtMTcuNDg2LTE1LjktMzEuMjI4LTM0LjA0OC0yNy41MDRDMjk3LjEyNCw3OC44MiwyODgsOTEuMDg1LDI4OCwxMDQuNTc1djUuNjY3Yy00LjI1Ni0zLjgzOC05LjgzMS02LjI0Mi0xNi02LjI0MmgtMzIgICBjLTYuMTY5LDAtMTEuNzQ0LDIuNDA0LTE2LDYuMjQydi01LjY2N2MwLTEzLjQ5MS05LjEyNC0yNS43NTUtMjIuMzM5LTI4LjQ2N2MtMTguMTQ4LTMuNzI0LTM0LjA3MSwxMC4wMTgtMzQuMDQ4LDI3LjUwNCAgIGMtMTUuNTQ5LTAuMDIxLTI4LjEzOCwxMi41NjgtMjguMTE4LDI4LjExOEMxMzkuNTE3LDE0Ny4yODEsMTUyLjQ1LDE1OS45NzksMTY4LDE2MGgtNjRjLTE3LjY3MywwLTMyLDE0LjMyNy0zMiwzMnY4ICAgYzAsMTcuNjczLDE0LjMyNywzMiwzMiwzMmg5NnYxNkg5NnYxNjEuMjhjMCwxNi45NjYsMTMuNzU0LDMwLjcyLDMwLjcyLDMwLjcySDIwMGM4LjgzNywwLDE2LTcuMTYzLDE2LTE2VjE2OGg4MHYyNTYgICBjMCw4LjgzNyw3LjE2MywxNiwxNiwxNmg3My4yOGMxNi45NjYsMCwzMC43Mi0xMy43NTQsMzAuNzItMzAuNzJWMjQ4SDMxMnYtMTZoOTZjMTcuNjczLDAsMzItMTQuMzI3LDMyLTMydi04ICAgQzQ0MCwxNzQuMzI3LDQyNS42NzMsMTYwLDQwOCwxNjB6IE0yMzIsMTUydi0yNGMwLTQuNDEsMy41ODYtOCw4LThoMzJjNC40MTQsMCw4LDMuNTksOCw4djI0SDIzMnoiLz4KCjwvZz4KCjxnIGlkPSJMYXllcl8xIi8+Cgo8L3N2Zz4=";
    uint256 constant MOCK_LUCKY_DIP_IMAGE_URI_LENGTH = 4;
    uint256 constant MOCK_NB_OF_LUCKY_DIPS = 1;
    string constant MOCK_LUCKY_DIP_DESCRIPTION =
        "A nice collection from Jean Michel Mock";

    address user1 = makeAddr("cochonou");

    NFTLuckyDip public luckyDip;

    function setUp() external {
        DeployNFTLuckyDip deployer = new DeployNFTLuckyDip();
        luckyDip = deployer.runMocked(msg.sender);
        vm.deal(user1, STARTING_BALANCE);
    }

    /*** MODIFIERS */

    /*** UNIT TESTS */
    function testLuckyDipAddingWorks() public view {
        // related to nft imageUris
        assertEq(
            luckyDip.getLuckyDipNFTLength(0),
            MOCK_LUCKY_DIP_IMAGE_URI_LENGTH
        );
        assertEq(luckyDip.getLuckyDipNFT(0, 0), MOCK_LUCKY_DIP_IMAGE_URI1);
        // other fields
        assertEq(luckyDip.getLuckyDipStatus(0), false);
        assertEq(luckyDip.getNbOfLuckyDips(), MOCK_NB_OF_LUCKY_DIPS);
        assertEq(
            luckyDip.getLuckyDipDescription(0),
            MOCK_LUCKY_DIP_DESCRIPTION
        );

        assertEq(luckyDip.getStartingBid(0), MOCK_LUCKY_DIP_STARTINGBID);
        assertEq(
            luckyDip.getNextBiddingPriceInWei(0),
            (MOCK_LUCKY_DIP_STARTINGBID + (0 * MOCK_LUCKY_DIP_BIDSTEP))
        );
    }

    // TODO only owner can add luckyDips
    function testOnlyOwnerCanAddLuckyDip() public view {
        // vm.prank user
        // addLufkcyDip must failed
        // expectRevert()
    }

    // TODO anyone can bid with suficient amount
    function testCantBidWithInvalidAmount() public view {}
}
