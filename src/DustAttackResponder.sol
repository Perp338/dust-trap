// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DustAttackResponder {
    address public immutable GUARDIAN;
    
    event DustAttackAlert(
        uint256 dustCount,
        uint256 uniqueSenders,
        uint256 blockNumber,
        string alertType,
        uint256 timestamp
    );
    
    event EmergencyPause(
        string reason,
        uint256 timestamp
    );
    
    modifier onlyGuardian() {
        require(msg.sender == GUARDIAN, "Only guardian can respond");
        _;
    }
    
    constructor(address _guardian) {
        GUARDIAN = _guardian;
    }
    
    // Exact signature for Drosera TOML config
    function respondToDustAttack(bytes calldata alertData) external onlyGuardian {
        // Decode alert data from the trap
        (uint256 dustCount, uint256 uniqueCount, uint256 blockNum, string memory alertType) = 
            abi.decode(alertData, (uint256, uint256, uint256, string));
        
        // Emit alert event
        emit DustAttackAlert(
            dustCount,
            uniqueCount,
            blockNum,
            alertType,
            block.timestamp
        );
        
        // Take automated response based on severity
        if (dustCount > COUNT_THRESHOLD * 2) {
            // High severity - could trigger pause
            emit EmergencyPause("High dust attack detected", block.timestamp);
            // In real implementation: call target contract's pause function
        }
    }
    
    // Alternative response function with different signature
    function emergencyResponse(bytes calldata alertData) external onlyGuardian {
        this.respondToDustAttack(alertData);
    }
    
    // Constants for reference
    uint256 public constant COUNT_THRESHOLD = 15;
}