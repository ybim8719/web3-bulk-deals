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
        luckyDip = new NFTLuckyDip(s_luckyDips);
        vm.stopBroadcast();
    }

    function populateLuckyDips() internal {
        s_tmpPaths = ["imlage1", "image2"];
        populateLuckyDip("a nice colletion from JeanMichelJarre", "JMJ", "Jeanmi", 1e16, 1e15);  
        s_tmpPaths = ["imlage3", "image4"];
        populateLuckyDip("a nice colletion from Zidane", "ZZ", "Zizou", 2e16, 2e15);
    }

    function populateLuckyDip(
        string memory _description, 
        string memory _symbol, 
        string memory _name, 
        uint256 _startingBid,        
        uint256 _bidStep
    ) internal {
        NFTSet[] storage nftCollection = new NFTSet[](s_tmpPaths.length);
        for (uint256 i = 0; i < s_tmpPaths.length; i++) {
            nftCollection[i] = NFTSet({fileName: s_tmpPaths[i]});
        }
        // TODO ! https://ethereum.stackexchange.com/questions/85374/type-struct-mycontract-user-memory-is-not-implicitly-convertible-to-expected-typ
        LuckyDip storage lucky = LuckyDip({
            description: _description,
            symbol: _symbol,
            name: _name,
            startingBid: _startingBid,
            bidStep: _bidStep,
            nextBidStep: 0,
            bestBidder: address(0),
            deployed: address(0),
            nftCollection: nftCollection
        });

        s_luckyDips.push(lucky);
    }
}
