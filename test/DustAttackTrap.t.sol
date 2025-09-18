// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {DustAttackTrap} from "../src/DustAttackTrap.sol";
import {DustRecorder} from "../src/DustRecorder.sol";

contract DustAttackTrapTest is Test {
    DustAttackTrap public trap;
    DustRecorder public recorder;

    function setUp() public {
        recorder = new DustRecorder();
        trap = new DustAttackTrap();
    }

    function testCollect_NoEntries() public view {
        bytes memory collectedData = trap.collect();
        (uint256 dustCount, uint256 uniqueCount, ) = abi.decode(collectedData, (uint256, uint256, uint256));

        assertEq(dustCount, 0);
        assertEq(uniqueCount, 0);
    }

    function testCollect_WithEntries() public {
        address sender = address(0x1);
        vm.prank(sender);
        recorder.record(sender, 0.0005 ether);

        bytes memory collectedData = trap.collect();
        (uint256 dustCount, uint256 uniqueCount, uint256 currentBlock) = abi.decode(collectedData, (uint256, uint256, uint256));

        assertEq(dustCount, 1);
        assertEq(uniqueCount, 1);
        assertEq(currentBlock, block.number);
    }

    function testShouldRespond_NoTrigger() public view {
        bytes memory collectedData = abi.encode(14, 10, 12345);
        bytes[] memory data = new bytes[](1);
        data[0] = collectedData;

        (bool shouldTrigger, bytes memory response) = trap.shouldRespond(data);

        assertFalse(shouldTrigger);
        assertEq(response.length, 0);
    }

    function testShouldRespond_Trigger() public view {
        bytes memory collectedData = abi.encode(15, 10, 12345);
        bytes[] memory data = new bytes[](1);
        data[0] = collectedData;

        (bool shouldTrigger, bytes memory response) = trap.shouldRespond(data);

        assertTrue(shouldTrigger);
        (uint256 dustCount, uint256 uniqueCount, uint256 blockNum, string memory alertType) = abi.decode(response, (uint256, uint256, uint256, string));
        assertEq(dustCount, 15);
        assertEq(uniqueCount, 10);
        assertEq(blockNum, 12345);
        assertEq(alertType, "DUST_ATTACK_DETECTED");
    }
}