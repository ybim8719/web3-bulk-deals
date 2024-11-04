// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;


import {LuckyDip} from "./structs/LuckyDip.sol";

contract NFTLuckyDip {
    /** * ERRORS */
    /** * Events */
    /** * Const */
    /** * States */

    address private i_owner;
    mapping(address member => bool isRegistered) private s_members;
    mapping(address vendor => LuckyDip[] pending) private s_luckyDips;
    //mapping(address vendor => LuckyDip[] deployed) private s_deployedNftColletions;

    /** * modifiers */

    constructor() {
        i_owner = msg.sender;
        // Owner is added to member lists since he can also propose deals
        // s_members[msg.sender] = true;
        // i_priceFeed = AggregatorV3Interface(priceFeed);
    }

}
