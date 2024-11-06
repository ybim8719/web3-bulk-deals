// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

struct LuckyDip {
    string description;
    string symbol;
    string name;
    uint256 startingBid;
    uint256 bidStep;
    uint256 nextBidStep;
    address bestBidder;
    address deployed;
    mapping(uint => NFTSet) nftCollection;
    uint nftCollectionSize;
}

struct NFTSet {
    string imageUri;
}
