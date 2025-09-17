// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Test} from "forge-std/Test.sol";
import {Vm} from "forge-std/Vm.sol";
import {DustAttackTrap} from "../src/DustAttackTrap.sol";

contract DustAttackTrapTest is Test {
    DustAttackTrap public dustAttackTrap;

    uint256 public constant VALUE_THRESHOLD = 10000000000000; // 0.00001 ETH in wei
    uint224 public constant COUNT_THRESHOLD = 5;
    uint256 public constant BLOCK_WINDOW = 5;

    function setUp() public {
        dustAttackTrap = new DustAttackTrap();
        dustAttackTrap.setValueThreshold(VALUE_THRESHOLD);
        dustAttackTrap.setBlockWindow(BLOCK_WINDOW);
        vm.deal(address(0x123), 1 ether); // Give attacker some ETH
        vm.roll(100); // Start at a higher block number to avoid underflow issues
    }

    function testDeployment() public view {
        assertEq(dustAttackTrap.valueThreshold(), VALUE_THRESHOLD);
        assertEq(dustAttackTrap.blockWindow(), BLOCK_WINDOW);
    }

    function testShouldRespond_Trigger() public {
        // Manually construct the data for shouldRespond
        bytes[] memory data = new bytes[](2);
        data[0] = abi.encode(COUNT_THRESHOLD);
        data[1] = abi.encode(COUNT_THRESHOLD);

        // Call shouldRespond and check the result
        (bool shouldTrigger, string memory reason) = dustAttackTrap.shouldRespond(data);

        assertTrue(shouldTrigger, "shouldTrigger should be true");
        assertEq(reason, "Dust attack detected");
    }

    function testShouldRespond_NoTrigger() public {
        // Manually construct the data for shouldRespond
        bytes[] memory data = new bytes[](2);
        data[0] = abi.encode(COUNT_THRESHOLD - 1);
        data[1] = abi.encode(COUNT_THRESHOLD);

        // Call shouldRespond and check the result
        (bool shouldTrigger, string memory reason) = dustAttackTrap.shouldRespond(data);

        assertFalse(shouldTrigger, "shouldTrigger should be false");
        assertEq(reason, "No dust attack detected");
    }

    function testReceiveDust() public {
        address attacker = address(0x123);

        vm.recordLogs();

        // Simulate a dust transaction
        vm.startPrank(attacker);
        address(dustAttackTrap).call{value: VALUE_THRESHOLD, gas: 1000000}("");
        vm.stopPrank();

        Vm.Log[] memory logs = vm.getRecordedLogs();
        assertTrue(logs.length > 0, "No logs emitted");

        // Find the DustTransfer event
        bool eventFound = false;
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == keccak256("DustTransfer(address,uint256,uint256)")) {
                eventFound = true;
                (uint256 amount, uint256 blockNumber) = abi.decode(logs[i].data, (uint256, uint256));
                address from = address(uint160(uint256(logs[i].topics[1])));

                assertEq(from, attacker, "From address mismatch");
                assertEq(amount, VALUE_THRESHOLD, "Amount mismatch");
                assertEq(blockNumber, block.number, "Block number mismatch");
                break;
            }
        }
        assertTrue(eventFound, "DustTransfer event not found");
    }
}