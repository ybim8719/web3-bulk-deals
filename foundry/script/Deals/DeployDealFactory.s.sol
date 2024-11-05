// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {DealFactory} from "../../src/Deals/DealFactory.sol";
import {HelperConfig} from "../HelperConfig.s.sol";

contract DeployDealFactory is Script {
    function run() external returns (DealFactory factory) {
        // The next line runs before the vm.startBroadcast() is called
        // This will not be deployed because the `real` signed txs are happening
        // between the start and stop Broadcast lines.
        HelperConfig helperConfig = new HelperConfig();
        address ethUsdPriceFeed = helperConfig.activeNetworkConfig();
        vm.startBroadcast();
        factory = new DealFactory(ethUsdPriceFeed);
        vm.stopBroadcast();
    }
}
