// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {LuckyDip} from "../../src/NFT/structs/LuckyDip.sol";
import {NFTLuckyDip} from "../../src/NFT/NFTLuckyDip.sol";
import {DeployNFTLuckyDip} from "../../script/NFT/DeployLuckyDip.s.sol";

contract NftLuckyDipTest is Test {
    /** USERS */
    uint256 constant STARTING_BALANCE = 10 ether;
    address user1 = makeAddr("cochonou");
    /** MOCKED LUCKY DIP */
    string constant DEFAULT_MOCK_NAME = "JeanMiMock";
    uint256 constant DEFAULT_MOCK_STARTINGBID = 2500000000000000;
    uint256 constant DEFAULT_MOCK_BIDSTEP = 10000000000000;
    // svg encoded on CLI
    string constant MOCK_IMAGE_URI1 =
        "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/PgoKPCEtLSBVcGxvYWRlZCB0bzogU1ZHIFJlcG8sIHd3dy5zdmdyZXBvLmNvbSwgR2VuZXJhdG9yOiBTVkcgUmVwbyBNaXhlciBUb29scyAtLT4KPHN2ZyBmaWxsPSIjMDAwMDAwIiB3aWR0aD0iODAwcHgiIGhlaWdodD0iODAwcHgiIHZpZXdCb3g9IjAgMCA1MTIgNTEyIiB2ZXJzaW9uPSIxLjEiIHhtbDpzcGFjZT0icHJlc2VydmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiPgoKPGcgaWQ9ImdpZnRfYm94LWJveF8taGVhcnQtbG92ZS12YWxlbnRpbmUiPgoKPHBhdGggZD0iTTQwOCwxNjBoLTY0YzE1LjU1LTAuMDIxLDI4LjQ4My0xMi43MTksMjguNTA0LTI4LjI2OWMwLjAyMS0xNS41NS0xMi41NjgtMjguMTM5LTI4LjExOC0yOC4xMTggICBjMC4wMjMtMTcuNDg2LTE1LjktMzEuMjI4LTM0LjA0OC0yNy41MDRDMjk3LjEyNCw3OC44MiwyODgsOTEuMDg1LDI4OCwxMDQuNTc1djUuNjY3Yy00LjI1Ni0zLjgzOC05LjgzMS02LjI0Mi0xNi02LjI0MmgtMzIgICBjLTYuMTY5LDAtMTEuNzQ0LDIuNDA0LTE2LDYuMjQydi01LjY2N2MwLTEzLjQ5MS05LjEyNC0yNS43NTUtMjIuMzM5LTI4LjQ2N2MtMTguMTQ4LTMuNzI0LTM0LjA3MSwxMC4wMTgtMzQuMDQ4LDI3LjUwNCAgIGMtMTUuNTQ5LTAuMDIxLTI4LjEzOCwxMi41NjgtMjguMTE4LDI4LjExOEMxMzkuNTE3LDE0Ny4yODEsMTUyLjQ1LDE1OS45NzksMTY4LDE2MGgtNjRjLTE3LjY3MywwLTMyLDE0LjMyNy0zMiwzMnY4ICAgYzAsMTcuNjczLDE0LjMyNywzMiwzMiwzMmg5NnYxNkg5NnYxNjEuMjhjMCwxNi45NjYsMTMuNzU0LDMwLjcyLDMwLjcyLDMwLjcySDIwMGM4LjgzNywwLDE2LTcuMTYzLDE2LTE2VjE2OGg4MHYyNTYgICBjMCw4LjgzNyw3LjE2MywxNiwxNiwxNmg3My4yOGMxNi45NjYsMCwzMC43Mi0xMy43NTQsMzAuNzItMzAuNzJWMjQ4SDMxMnYtMTZoOTZjMTcuNjczLDAsMzItMTQuMzI3LDMyLTMydi04ICAgQzQ0MCwxNzQuMzI3LDQyNS42NzMsMTYwLDQwOCwxNjB6IE0yMzIsMTUydi0yNGMwLTQuNDEsMy41ODYtOCw4LThoMzJjNC40MTQsMCw4LDMuNTksOCw4djI0SDIzMnoiLz4KCjwvZz4KCjxnIGlkPSJMYXllcl8xIi8+Cgo8L3N2Zz4=";
    uint256 constant DEFAULT_MOCK_IMAGE_URI_LENGTH = 4;
    uint256 constant DEFAULT_MOCK_NB_OF_LUCKY_DIPS = 1;
    string constant DEFAULT_MOCK_DESCRIPTION =
        "A nice collection from Jean Michel Mock";

    string[] s_tmpImageUris;
    NFTLuckyDip public s_luckyDip;

    function setUp() external {
        DeployNFTLuckyDip deployer = new DeployNFTLuckyDip();
        s_luckyDip = deployer.runMocked(msg.sender);
        vm.deal(user1, STARTING_BALANCE);
    }

    /*** MODIFIERS */

    /*** UNIT TESTS */
    function testLuckyDipAddingWorks() public view {
        // related to nft imageUris
        assertEq(
            s_luckyDip.getLuckyDipNFTLength(0),
            DEFAULT_MOCK_IMAGE_URI_LENGTH
        );
        // TODO encoding of svg seems to behave differently on each machine (base64 -i <path-to-svg-file>)
        //assertEq(luckyDip.getLuckyDipNFT(0, 0), MOCK_LUCKY_DIP_IMAGE_URI1);
        // other fields
        assertEq(s_luckyDip.getLuckyDipStatus(0), false);
        assertEq(s_luckyDip.getNbOfLuckyDips(), DEFAULT_MOCK_NB_OF_LUCKY_DIPS);
        assertEq(
            s_luckyDip.getLuckyDipDescription(0),
            DEFAULT_MOCK_DESCRIPTION
        );

        assertEq(s_luckyDip.getStartingBid(0), DEFAULT_MOCK_STARTINGBID);
        assertEq(
            s_luckyDip.getNextBiddingPriceInWei(0),
            (DEFAULT_MOCK_STARTINGBID + (0 * DEFAULT_MOCK_BIDSTEP))
        );
    }

    function testOnlyOwnerCanAddLuckyDip() public {
        s_tmpImageUris = new string[](0);
        s_tmpImageUris.push('fake uri which will fail');
        s_tmpImageUris.push('fake uri which will fail2');

        vm.prank(user1);
        vm.expectRevert();
            s_luckyDip.addLuckyDip(
            "fake description",
            "fake symbol",
            "fake _name",
            10000000000,
            1000000000,
            s_tmpImageUris
        );
    }

    // TODO anyone can bid with suficient amount
    function testCantBidWithInvalidAmount() public view {}
}
