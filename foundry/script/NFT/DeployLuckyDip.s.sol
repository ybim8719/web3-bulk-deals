// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {NFTLuckyDip} from "../../src/NFT/NFTLuckyDip.sol";
import {LuckyDip} from "../../src/NFT/structs/LuckyDip.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployNFTLuckyDip is Script {
    string constant SVG_PATH = "./img/";
    string[] s_tmpImageUris;

    function run() external returns (NFTLuckyDip luckyDip) {
        luckyDip = instantiateNftLuckyDip();
        populateLuckyDips(luckyDip);
        return luckyDip;
    }

    function runWithoutPopulating() public returns (NFTLuckyDip luckyDip) {
        return instantiateNftLuckyDip();
    }

    function instantiateNftLuckyDip() internal returns (NFTLuckyDip) {
        vm.startBroadcast();
        NFTLuckyDip luckyDip = new NFTLuckyDip();
        vm.stopBroadcast();
        return luckyDip;
    }

    function populateLuckyDips(NFTLuckyDip luckyDip) public {
        s_tmpImageUris = [
            svgToImageURI(
                vm.readFile(string(abi.encodePacked(SVG_PATH, "image1.svg")))
            ),
            svgToImageURI(
                vm.readFile(string(abi.encodePacked(SVG_PATH, "image2.svg")))
            )
        ];
        luckyDip.addLuckyDip(
            false,
            "a nice collection from JeanMichelJarre",
            "JMJ",
            "Jeanmi",
            1e16,
            1e15,
            s_tmpImageUris
        );
        s_tmpImageUris = [
            svgToImageURI(
                vm.readFile(string(abi.encodePacked(SVG_PATH, "image3.svg")))
            ),
            svgToImageURI(
                vm.readFile(string(abi.encodePacked(SVG_PATH, "image4.svg")))
            )
        ];
        luckyDip.addLuckyDip(
            false,
            "a nice colletion from Zidane",
            "ZZ",
            "Zizou",
            2e16,
            2e15,
            s_tmpImageUris
        );
    }

    function svgToImageURI(
        string memory svg
    ) public pure returns (string memory) {
        string memory baseURI = "data:image/svg+xml;base64,";
        string memory svgBase64Encoded = Base64.encode(
            bytes(string(abi.encodePacked(svg))) // Removing unnecessary type castings, this line can be resumed as follows : 'abi.encodePacked(svg)'
        );
        return string(abi.encodePacked(baseURI, svgBase64Encoded));
    }
}
