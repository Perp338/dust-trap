// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {DustAttackTrap} from "../src/DustAttackTrap.sol";

contract DeployDustAttackTrap is Script {
    function run() public returns (DustAttackTrap) {
        vm.startBroadcast();

        // Deploy the contract without constructor arguments
        DustAttackTrap dustAttackTrap = new DustAttackTrap();

        // Set the parameters via setter functions
        uint256 valueThreshold = 10000000000000; // 0.00001 ETH in wei
        uint256 blockWindow = 5;

        dustAttackTrap.setValueThreshold(valueThreshold);
        dustAttackTrap.setBlockWindow(blockWindow);

        vm.stopBroadcast();

        return dustAttackTrap;
    }
}