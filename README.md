# Drosera Dust Attack Detection System 🪤

A three-contract system for detecting dust attacks, fully compliant with Drosera network monitoring.

## Architecture

### 1. **DustRecorder.sol** 📊
- Ring buffer storing transaction data
- Called by target contracts on each transfer
- Provides `getLast(k)` for the trap to analyze

### 2. **DustAttackTrap.sol** 🪤 (Drosera-compliant)
- **collect()**: Returns encoded analysis of recent transactions
- **shouldRespond()**: Pure function determining if alert needed
- No state mutations, only view/pure functions

### 3. **DustAttackResponder.sol** 🚨
- Receives alerts from Drosera guardian
- Emits events and takes automated actions
- Guardian-protected response functions

## Drosera Compliance ✅

- ✅ `collect() external view returns (bytes)`
- ✅ `shouldRespond(bytes[]) external pure returns (bool, bytes)`
- ✅ No mutable config (constants only)
- ✅ No stateful logic in trap
- ✅ Separate responder contract
- ✅ Exact function signatures for TOML

## Quick Start

1. **Deploy contracts:**
   ```bash
   forge script script/Deploy.s.sol:DeployDustAttackSystem --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
   ```

   Replace `<your_rpc_url>` and `<your_private_key>` with your actual RPC URL and private key.

2. **Configure Drosera TOML:**
   ```toml
   [trap]
   trap_address = "YOUR_TRAP_ADDRESS"
   collect_function = "collect()"
   should_respond_function = "shouldRespond(bytes[])"
   
   [response]
   response_address = "YOUR_RESPONDER_ADDRESS"
   response_function = "respondToDustAttack(bytes)"
   ```

3. **Integrate with your target contract:**
   ```solidity
   // In your contract's receive/transfer functions:
   recorder.record(msg.sender, msg.value);
   ```

4. **Monitor activity:**
   ```bash
   # Update addresses in monitor.js first
   node monitor.js
   ```

## How It Works

1. **Record**: Target contracts call `recorder.record()` on transfers
2. **Collect**: Drosera calls `trap.collect()` to get recent transaction analysis
3. **Analyze**: `trap.shouldRespond()` determines if dust threshold exceeded
4. **Respond**: Guardian calls `responder.respondToDustAttack()` to take action

## Settings

- **Dust Threshold**: 0.001 ETH
- **Count Threshold**: 15 transactions
- **Block Window**: 10 blocks
- **Sample Size**: 100 recent entries

## Integration Examples

### Faucet Integration
```solidity
contract MyFaucet {
    IDustRecorder recorder;
    
    function claim() external {
        recorder.record(msg.sender, 0.01 ether);
        // ... faucet logic
    }
}
```

### Token Contract Integration
```solidity
contract MyToken {
    IDustRecorder recorder;
    
    function transfer(address to, uint256 amount) public override {
        recorder.record(msg.sender, amount);
        return super.transfer(to, amount);
    }
}
```

## Security Features

- Guardian-protected responses
- Configurable thresholds via constants
- Ring buffer prevents storage bloat
- Unique sender tracking
- Block window filtering

## Monitoring Dashboard

The monitor script provides:
- Real-time transaction logging
- Dust attack alerts
- Emergency pause notifications
- Periodic status updates

## Next Steps

1. Customize thresholds for your use case
2. Add target contract integration
3. Set up Drosera monitoring
4. Configure automated responses
5. Test with simulated dust attacks

## Support

- Check Drosera docs for network setup
- Adjust gas limits for your network
- Monitor performance with high transaction volumes
