// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDustRecorder {
    struct Entry {
        address from;
        uint64 blk;
        uint96 amount;
    }
    
    function getLast(uint256 k) external view returns (Entry[] memory);
    function getEntryCount() external view returns (uint256);
}

contract DustAttackTrap {
    // Constants only - no mutable config for Drosera compliance
    uint256 public constant DUST_THRESHOLD = 0.001 ether;
    uint256 public constant COUNT_THRESHOLD = 15;
    uint256 public constant BLOCK_WINDOW = 10;
    uint256 public constant SAMPLE_SIZE = 100;
    
    // Hardcode the recorder address (no constructor allowed)
    address public constant RECORDER = 0x9Ae18fAe2553ED33871c7B054Cc38f428302d5dd;
    
    function collect() external view returns (bytes memory) {
        IDustRecorder rec = IDustRecorder(RECORDER);
        
        uint256 totalEntries = rec.getEntryCount();
        uint256 sampleSize = totalEntries > SAMPLE_SIZE ? SAMPLE_SIZE : totalEntries;
        
        if (sampleSize == 0) {
            return abi.encode(uint256(0), uint256(0), block.number);
        }
        
        IDustRecorder.Entry[] memory entries = rec.getLast(sampleSize);
        uint256 currentBlock = block.number;
        
        uint256 dustCount = 0;
        address[] memory uniqueSenders = new address[](sampleSize);
        uint256 uniqueCount = 0;
        
        for (uint256 i = 0; i < entries.length; i++) {
            if (currentBlock - entries[i].blk <= BLOCK_WINDOW && 
                entries[i].amount <= DUST_THRESHOLD &&
                entries[i].amount > 0) {
                
                dustCount++;
                
                bool isUnique = true;
                for (uint256 j = 0; j < uniqueCount; j++) {
                    if (uniqueSenders[j] == entries[i].from) {
                        isUnique = false;
                        break;
                    }
                }
                
                if (isUnique && uniqueCount < sampleSize) {
                    uniqueSenders[uniqueCount] = entries[i].from;
                    uniqueCount++;
                }
            }
        }
        
        return abi.encode(dustCount, uniqueCount, currentBlock);
    }
    
    function shouldRespond(bytes[] calldata data) external pure returns (bool, bytes memory) {
        if (data.length == 0) {
            return (false, "");
        }
        
        (uint256 dustCount, uint256 uniqueCount, uint256 blockNum) = 
            abi.decode(data[0], (uint256, uint256, uint256));
        
        bool shouldTrigger = dustCount >= COUNT_THRESHOLD;
        
        if (shouldTrigger) {
            bytes memory alertData = abi.encode(
                dustCount,
                uniqueCount,
                blockNum,
                "DUST_ATTACK_DETECTED"
            );
            return (true, alertData);
        }
        
        return (false, "");
    }
    
    function getStatus() external view returns (
        uint256 recentDust,
        uint256 threshold,
        bool wouldTrigger
    ) {
        bytes memory collectedData = this.collect();
        if (collectedData.length == 0) {
            return (0, COUNT_THRESHOLD, false);
        }
        
        (uint256 dustCount,,) = abi.decode(collectedData, (uint256, uint256, uint256));
        return (dustCount, COUNT_THRESHOLD, dustCount >= COUNT_THRESHOLD);
    }
}
