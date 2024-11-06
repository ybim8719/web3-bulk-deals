// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {NFTLuckyDip} from "../../src/NFT/NFTLuckyDip.sol";
import {LuckyDip, NFTSet} from "../../src/NFT/structs/LuckyDip.sol";

contract DeployNFTLuckyDip is Script {
    string[] s_tmpPaths;
    LuckyDip[] s_luckyDips;

    function run() external returns (NFTLuckyDip luckyDip) {
        populateLuckyDips();
        vm.startBroadcast();
        luckyDip = new NFTLuckyDip();
        s_tmpPaths = ["image1", "image2"];
        luckyDip.addLuckyDip(
            "a nice colletion from JeanMichelJarre",
            "JMJ",
            "Jeanmi",
            1e16,
            1e15,
            0,
            s_tmpPaths
        );
        vm.stopBroadcast();
    }

    function populateLuckyDips() internal {
        populateLuckyDip(
            "a nice colletion from JeanMichelJarre",
            "JMJ",
            "Jeanmi",
            1e16,
            1e15,
            0
        );
        s_tmpPaths = ["imlage3", "image4"];
        populateLuckyDip(
            "a nice colletion from Zidane",
            "ZZ",
            "Zizou",
            2e16,
            2e15,
            1
        );
    }

    function populateLuckyDip(
        string memory _description,
        string memory _symbol,
        string memory _name,
        uint256 _startingBid,
        uint256 _bidStep,
        uint256 index
    ) internal {
        // TODO ! https://ethereum.stackexchange.com/questions/85374/type-struct-mycontract-user-memory-is-not-implicitly-convertible-to-expected-typ
    }
}
