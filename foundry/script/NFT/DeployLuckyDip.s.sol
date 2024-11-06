// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {NFTLuckyDip} from "../../src/NFT/NFTLuckyDip.sol";
import {LuckyDip, NFTSet} from "../../src/NFT/structs/LuckyDip.sol";

contract DeployNFTLuckyDip is Script {
    function run() external returns (NFTLuckyDip luckyDip) {
        vm.startBroadcast();
        luckyDip = new NFTLuckyDip();
        vm.stopBroadcast();
    }

    function populateLuckyDips() internal returns(LuckyDip[] memory) {
        LuckyDip[] memory luckyDips = new LuckyDip[](2);
        luckyDips[0] = populateLuckyDip("a nice colletion from JeanMichelJarre", "JMJ", "Jeanmi", 1e16, 1e15);        
        luckyDips[1] = populateLuckyDip("a nice colletion from Zidane", "ZZ", "Zizou", 2e16, 2e15);

        return luckyDips;
    }

    function populateLuckyDip(
        string memory _description, 
        string memory _symbol, 
        string memory _name, 
        uint256 _startingBid, 
        uint256 _bidStep
    ) internal returns(LuckyDip memory){

        LuckyDip[] memory luckyDips = new LuckyDip[](2);

        NFTSet[] memory collection = new NFTSet[](2);
        collection[0] = NFTSet({
                            name: "ddede",
                            fileName: "prout"
                        });

        collection[1] = NFTSet({
                            name: "ddede2",
                            fileName: "prout2"
                        });

        LuckyDip memory lucky = LuckyDip({
            description: _description,
            symbol: _symbol,
            name: _name,
            startingBid: _startingBid,
            bidStep: _bidStep,
            nextBidStep: 0,
            bestBidder: address(0),
            deployed: address(0),
            nftCollection: collection
        });

        return lucky;
    }
}
