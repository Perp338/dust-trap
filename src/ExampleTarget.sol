// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IDustRecorder {
    function record(address from, uint256 amount) external;
}

contract ExampleTarget {
    IDustRecorder public recorder;
    
    constructor(address _recorder) {
        recorder = IDustRecorder(_recorder);
    }
    
    // Example function that records all incoming transfers
    function transfer(address to, uint256 amount) external payable {
        // Record this transaction for dust analysis
        recorder.record(msg.sender, msg.value);
        
        // Your actual transfer logic here
        // ...
        
        emit Transfer(msg.sender, to, amount);
    }
    
    // Auto-record on ETH receives
    receive() external payable {
        recorder.record(msg.sender, msg.value);
    }
    
    event Transfer(address from, address to, uint256 amount);
}
