// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {BulkDealFactory} from "../src/BulkDealFactory.sol";

contract DeployBulkDealFactory is Script {
    function run() external returns (BulkDealFactory) {
        vm.startBroadcast();
        BulkDealFactory bulkDeal = new BulkDealFactory();
        vm.stopBroadcast();
        return bulkDeal;
    }
}
