
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


struct LuckyDip {
    string deckDescription;
    string symbol;
    string name;
    uint256 startingBid;
    uint256 bidStep;
    address bestBidder;
    address deployed;
    NFTSet[] nftCollection;
}

struct NFTSet {  
    string name;
    string fileName;
}
