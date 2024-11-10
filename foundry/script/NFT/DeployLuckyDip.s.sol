// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {NFTLuckyDip} from "../../src/NFT/NFTLuckyDip.sol";
import {LuckyDip} from "../../src/NFT/structs/LuckyDip.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract DeployNFTLuckyDip is Script {
    string constant SVG_PATH = "./img/";
    string constant FEED_PATH = "./seed/luckyDipsFeed.json";
    string[] s_tmpImageUris;
    struct LyckyDipJson {
        uint256 bidStep;
        string description;
        string name;
        string[] nftCollection;
        uint256 startingBid;
        string symbol;
    }
  
    function run() external returns (NFTLuckyDip luckyDip) {
        string memory json = vm.readFile("./feed/test1.json");
        bytes memory data = vm.parseJson(json);
        LyckyDipJson memory luckyDips = abi.decode(data, (LyckyDipJson));

        // for (uint256 i = 0; i < luckyDips.data.length; i++) {
        //     LyckyDipJson memory truc = luckyDips.data[i];
        //     console.log(
        //         "description: %s, symbol: %d, name: %d",
        //         truc.description,
        //         truc.symbol,
        //         truc.name
        //     );
        // }

        // Logs: Welcome to Fresh Fruit
        console.log(luckyDips.nftCollection[0]);

        // for (uint256 i = 0; i < fruitstall.apples.length; i++) {
        //     Apple memory apple = fruitstall.apples[i];

        //     // Logs:
        //     // Color: Red, Sourness: 3, Sweetness: 7
        //     // Color: Green, Sourness: 5, Sweetness: 5
        //     // Color: Yellow, Sourness: 1, Sweetness: 9
        //     console.log(
        //         "Color: %s, Sourness: %d, Sweetness: %d",
        //         apple.color,
        //         apple.sourness,
        //         apple.sweetness
        //     );
        // }
        luckyDip = instantiateNftLuckyDip();
        //populateLuckyDips(luckyDip);
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
