
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;


struct LuckyDip {
    string description;
    uint256 totalPrice;
    bool available;
    address buyer;
    NFTCollection[] collection;
}

struct NFTCollection {  
    string name;
    string fileName;
}



