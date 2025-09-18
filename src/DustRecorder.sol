// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DustRecorder {
    struct Entry {
        address from;
        uint64 blk;
        uint96 amount;
    }
    
    Entry[] public entries;
    uint256 public constant MAX_ENTRIES = 1000; // Ring buffer size
    uint256 public nextIndex = 0;
    
    event TransactionRecorded(address from, uint256 amount, uint256 block);
    
    // Record a transaction (called by target contract or relayer)
    function record(address from, uint256 amount) external {
        entries.push(Entry({
            from: from,
            blk: uint64(block.number),
            amount: uint96(amount)
        }));
        
        // Keep ring buffer size manageable
        if (entries.length > MAX_ENTRIES) {
            // Shift array (gas-expensive but simple for demo)
            for (uint256 i = 0; i < MAX_ENTRIES - 1; i++) {
                entries[i] = entries[i + 1];
            }
            entries.pop();
        }
        
        emit TransactionRecorded(from, amount, block.number);
    }
    
    // Get last K entries for the trap to analyze
    function getLast(uint256 k) external view returns (Entry[] memory) {
        uint256 length = entries.length;
        if (k > length) k = length;
        if (k == 0) return new Entry[](0);
        
        Entry[] memory result = new Entry[](k);
        for (uint256 i = 0; i < k; i++) {
            result[i] = entries[length - k + i];
        }
        return result;
    }
    
    // Get total entry count
    function getEntryCount() external view returns (uint256) {
        return entries.length;
    }
}
