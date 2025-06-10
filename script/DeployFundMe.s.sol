// SPDX-License-Identifier: MIT
pragma solidity ^0.8.28;

import {Script} from "forge-std/Script.sol";
import {FundMe} from "../src/FundMe.sol";

contract DeployFundMe is Script {
    function run() private returns (FundMe) {
        vm.startBroadcast();
        FundMe fundMe = new FundMe();
        vm.stopBroadcast();
        return fundMe;
    }
}
