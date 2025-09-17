// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DustAttackTrap {
    // Simplified parameters - beginner friendly
    uint256 public constant DUST_THRESHOLD = 0.001 ether; // Very low value threshold
    uint256 public constant COUNT_THRESHOLD = 20; // Trigger after 20 dust txs
    uint256 public constant BLOCK_WINDOW = 5; // Check last 5 blocks only
    
    // Simple tracking
    mapping(uint256 => uint256) public dustCountPerBlock;
    mapping(address => uint256) public lastDustBlock;
    
    event DustAttackDetected(
        uint256 totalDust,
        uint256 blockNumber,
        string message
    );
    
    event DustLogged(
        address sender,
        uint256 value,
        uint256 block
    );
    
    // Main Drosera monitoring function - simplified
    function isDustAttackDetected() external view returns (bool) {
        uint256 currentBlock = block.number;
        uint256 totalDustInWindow = 0;
        
        // Count dust in recent blocks
        for (uint256 i = 0; i < BLOCK_WINDOW; i++) {
            if (currentBlock > i) {
                totalDustInWindow += dustCountPerBlock[currentBlock - i];
            }
        }
        
        return totalDustInWindow >= COUNT_THRESHOLD;
    }
    
    // Log dust transaction - simple version
    function logDust() external payable {
        if (msg.value <= DUST_THRESHOLD && msg.value > 0) {
            dustCountPerBlock[block.number]++;
            lastDustBlock[msg.sender] = block.number;
            
            emit DustLogged(msg.sender, msg.value, block.number);
            
            // Check for attack
            if (isDustAttackDetected()) {
                uint256 totalDust = 0;
                for (uint256 i = 0; i < BLOCK_WINDOW; i++) {
                    if (block.number > i) {
                        totalDust += dustCountPerBlock[block.number - i];
                    }
                }
                
                emit DustAttackDetected(
                    totalDust,
                    block.number,
                    "DUST ATTACK DETECTED - Take action!"
                );
            }
        }
    }
    
    // Auto-receive ETH and check for dust
    receive() external payable {
        if (msg.value <= DUST_THRESHOLD) {
            logDust();
        }
    }
    
    // Get current dust count for monitoring
    function getCurrentDustCount() external view returns (uint256) {
        uint256 currentBlock = block.number;
        uint256 totalDust = 0;
        
        for (uint256 i = 0; i < BLOCK_WINDOW; i++) {
            if (currentBlock > i) {
                totalDust += dustCountPerBlock[currentBlock - i];
            }
        }
        
        return totalDust;
    }
    
    // Simple status check
    function getStatus() external view returns (
        uint256 currentDust,
        uint256 threshold,
        bool isUnderAttack
    ) {
        uint256 dust = getCurrentDustCount();
        return (dust, COUNT_THRESHOLD, dust >= COUNT_THRESHOLD);
    }
}
