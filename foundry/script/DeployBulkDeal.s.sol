// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;

import {Script} from "forge-std/Script.sol";
import {BulkDeal} from "../src/BulkDeal.sol";

contract DeployBulkDeal is Script {
    function run() external returns (BulkDeal) {
        vm.startBroadcast();
        BulkDeal bulkDeal = new BulkDeal();
        vm.stopBroadcast();
        return bulkDeal;
    }
}