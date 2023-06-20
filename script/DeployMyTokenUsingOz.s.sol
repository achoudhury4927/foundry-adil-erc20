// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MyTokenUsingOZ} from "../src/MyTokenUsingOZ.sol";

contract DeployMyTokenUsingOz is Script {
    uint256 public constant INITIAL_SUPPLY = 1000 ether;

    function run() external {
        vm.startBroadcast();
        new MyTokenUsingOZ(INITIAL_SUPPLY);
        vm.stopBroadcast();
    }
}
