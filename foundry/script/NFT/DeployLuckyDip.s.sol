// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {NFTLuckyDip} from "../../src/NFT/NFTLuckyDip.sol";
import {LuckyDip} from "../../src/NFT/structs/LuckyDip.sol";
import {ConvertSvg} from "./ConvertSvg.sol";

/**
 * @title
 * @author
 * @notice WARNING, hardcoded json files represent the luckydips dedicated to the future bids. For any customization of these data, please stricty respect
 * the alphabetical order of the keys inside the json since it's a particularity of vm.parsejson()
 * https://book.getfoundry.sh/cheatcodes/parse-json
 */
contract DeployNFTLuckyDip is Script {
    using ConvertSvg for string;
    string constant SVG_FOLDER_PATH = "./feed/img/";
    string[] s_tmpImageUris;

    // Will feed the contract
    string[] luckyDipsFeed = [
        "./feed/lucky-dip1.json",
        "./feed/lucky-dip2.json",
        "./feed/lucky-dip3.json",
        "./feed/lucky-dip4.json"
    ];
    string[] mockedLuckyDipsFeed = ["./feed/mocked-luckydip1.json"];

    error NftCollectionEmpty();
    struct LuckyDipJson {
        uint256 bidStep;
        string description;
        string name;
        string[] nftCollection;
        uint256 startingBid;
        string symbol;
    }

    function run() external returns (NFTLuckyDip luckyDip) {
        console.log("in script msg.sender is ", msg.sender);
        console.log("in script address (this) is ", address(this));
        luckyDip = instantiateNftLuckyDip();
        populateLuckyDips(luckyDip);
        return luckyDip;
    }

    function runMocked(address caller) external returns (NFTLuckyDip luckyDip) {
        luckyDip = instantiateNftLuckyDip();
        console.log("initial caller is", caller);
        populateWithMockedLuckyDips(luckyDip, caller);
        return luckyDip;
    }

    function instantiateNftLuckyDip() internal returns (NFTLuckyDip) {
        vm.startBroadcast();
        NFTLuckyDip luckyDip = new NFTLuckyDip();
        vm.stopBroadcast();
        console.log(luckyDip.getOwner(), " onwer is !!!! ");
        return luckyDip;
    }

    function populateLuckyDips(NFTLuckyDip luckyDip) public {
        for (uint256 i = 0; i < luckyDipsFeed.length; i++) {
            string memory json = vm.readFile(luckyDipsFeed[i]);
            bytes memory data = vm.parseJson(json);
            LuckyDipJson memory luckyDipToAdd = abi.decode(
                data,
                (LuckyDipJson)
            );
            if (luckyDipToAdd.nftCollection.length == 0) {
                revert NftCollectionEmpty();
            }
            s_tmpImageUris = new string[](0);
            for (uint256 j = 0; j < luckyDipToAdd.nftCollection.length; j++) {
                // set encoded svg and store temporaly
                s_tmpImageUris.push(
                    ConvertSvg.svgToImageURI(
                        vm.readFile(
                            string(
                                abi.encodePacked(
                                    SVG_FOLDER_PATH,
                                    luckyDipToAdd.nftCollection[j]
                                )
                            )
                        )
                    )
                );
            }
            vm.prank(msg.sender);
            luckyDip.addLuckyDip(
                luckyDipToAdd.description,
                luckyDipToAdd.symbol,
                luckyDipToAdd.name,
                luckyDipToAdd.startingBid,
                luckyDipToAdd.bidStep,
                s_tmpImageUris
            );
        }
    }

    function populateWithMockedLuckyDips(
        NFTLuckyDip luckyDip,
        address caller
    ) public {
        for (uint256 i = 0; i < mockedLuckyDipsFeed.length; i++) {
            string memory json = vm.readFile(mockedLuckyDipsFeed[i]);
            bytes memory data = vm.parseJson(json);
            LuckyDipJson memory luckyDipToAdd = abi.decode(
                data,
                (LuckyDipJson)
            );
            if (luckyDipToAdd.nftCollection.length == 0) {
                revert NftCollectionEmpty();
            }
            s_tmpImageUris = new string[](0);
            for (uint256 j = 0; j < luckyDipToAdd.nftCollection.length; j++) {
                // set encoded svg
                s_tmpImageUris.push(
                    ConvertSvg.svgToImageURI(
                        vm.readFile(
                            string(
                                abi.encodePacked(
                                    SVG_FOLDER_PATH,
                                    luckyDipToAdd.nftCollection[j]
                                )
                            )
                        )
                    )
                );
            }
            vm.prank(caller);
            luckyDip.addLuckyDip(
                luckyDipToAdd.description,
                luckyDipToAdd.symbol,
                luckyDipToAdd.name,
                luckyDipToAdd.startingBid,
                luckyDipToAdd.bidStep,
                s_tmpImageUris
            );
        }
    }
}
