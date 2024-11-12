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
    uint256 constant MOCK_LUCKY_DIP_BIDSTEP = 250000000000000;
    string constant MOCK_LUCKY_DIP_IMAGE_URI1 =
        "data:image/svg+xml;base64,PD94bWwgdmVyc2lvbj0iMS4wIiA/Pg0KDQo8IS0tIFVwbG9hZGVkIHRvOiBTVkcgUmVwbywgd3d3LnN2Z3JlcG8uY29tLCBHZW5lcmF0b3I6IFNWRyBSZXBvIE1peGVyIFRvb2xzIC0tPg0KPHN2ZyBmaWxsPSIjMDAwMDAwIiB3aWR0aD0iODAwcHgiIGhlaWdodD0iODAwcHgiIHZpZXdCb3g9IjAgMCA1MTIgNTEyIiB2ZXJzaW9uPSIxLjEiIHhtbDpzcGFjZT0icHJlc2VydmUiIHhtbG5zPSJodHRwOi8vd3d3LnczLm9yZy8yMDAwL3N2ZyIgeG1sbnM6eGxpbms9Imh0dHA6Ly93d3cudzMub3JnLzE5OTkveGxpbmsiPg0KDQo8ZyBpZD0iZ2lmdF9ib3gtYm94Xy1oZWFydC1sb3ZlLXZhbGVudGluZSI+DQoNCjxwYXRoIGQ9Ik00MDgsMTYwaC02NGMxNS41NS0wLjAyMSwyOC40ODMtMTIuNzE5LDI4LjUwNC0yOC4yNjljMC4wMjEtMTUuNTUtMTIuNTY4LTI4LjEzOS0yOC4xMTgtMjguMTE4ICAgYzAuMDIzLTE3LjQ4Ni0xNS45LTMxLjIyOC0zNC4wNDgtMjcuNTA0QzI5Ny4xMjQsNzguODIsMjg4LDkxLjA4NSwyODgsMTA0LjU3NXY1LjY2N2MtNC4yNTYtMy44MzgtOS44MzEtNi4yNDItMTYtNi4yNDJoLTMyICAgYy02LjE2OSwwLTExLjc0NCwyLjQwNC0xNiw2LjI0MnYtNS42NjdjMC0xMy40OTEtOS4xMjQtMjUuNzU1LTIyLjMzOS0yOC40NjdjLTE4LjE0OC0zLjcyNC0zNC4wNzEsMTAuMDE4LTM0LjA0OCwyNy41MDQgICBjLTE1LjU0OS0wLjAyMS0yOC4xMzgsMTIuNTY4LTI4LjExOCwyOC4xMThDMTM5LjUxNywxNDcuMjgxLDE1Mi40NSwxNTkuOTc5LDE2OCwxNjBoLTY0Yy0xNy42NzMsMC0zMiwxNC4zMjctMzIsMzJ2OCAgIGMwLDE3LjY3MywxNC4zMjcsMzIsMzIsMzJoOTZ2MTZIOTZ2MTYxLjI4YzAsMTYuOTY2LDEzLjc1NCwzMC43MiwzMC43MiwzMC43MkgyMDBjOC44MzcsMCwxNi03LjE2MywxNi0xNlYxNjhoODB2MjU2ICAgYzAsOC44MzcsNy4xNjMsMTYsMTYsMTZoNzMuMjhjMTYuOTY2LDAsMzAuNzItMTMuNzU0LDMwLjcyLTMwLjcyVjI0OEgzMTJ2LTE2aDk2YzE3LjY3MywwLDMyLTE0LjMyNywzMi0zMnYtOCAgIEM0NDAsMTc0LjMyNyw0MjUuNjczLDE2MCw0MDgsMTYweiBNMjMyLDE1MnYtMjRjMC00LjQxLDMuNTg2LTgsOC04aDMyYzQuNDE0LDAsOCwzLjU5LDgsOHYyNEgyMzJ6Ii8+DQoNCjwvZz4NCg0KPGcgaWQ9IkxheWVyXzEiLz4NCg0KPC9zdmc+";
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
        //TODO fix this
        //assertEq(luckyDip.getLuckyDipNFT(0, 0), MOCK_LUCKY_DIP_IMAGE_URI1);
        // other fields
        assertEq(luckyDip.getLuckyDipStatus(0), false);
        assertEq(luckyDip.getNbOfLuckyDips(), MOCK_NB_OF_LUCKY_DIPS);
        assertEq(
            luckyDip.getLuckyDipDescription(0),
            MOCK_LUCKY_DIP_DESCRIPTION
        );
        //TODO fix these assertions
        //assertEq(luckyDip.getStartingBid(0), MOCK_LUCKY_DIP_STARTINGBID);
        //assertEq(
        //    luckyDip.getNextBiddingPriceInWei(0),
        //    (MOCK_LUCKY_DIP_STARTINGBID + (0 * MOCK_LUCKY_DIP_BIDSTEP))
        //);
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
