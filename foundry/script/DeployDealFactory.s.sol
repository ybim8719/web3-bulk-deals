// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {DealFactory} from "../src/DealFactory.sol";

contract DeployDealFactory is Script {
    function run() external returns (DealFactory) {
        vm.startBroadcast();
        DealFactory factory = new DealFactory();
        vm.stopBroadcast();
        
        return factory;
    }
}
