# 🕸️ Drosera Dust Attack Detection System 🪤

A sophisticated, three-contract system engineered to detect and respond to dust attack patterns in real-time, fully compliant with the Drosera network.

## 🎯 Project Overview

This system monitors blockchain transactions for mass low-value transfers (dust attacks) that are commonly used to create transaction noise, manipulate airdrops, and compromise protocol security.

### 🔍 What Are Dust Attacks?

Dust attacks involve sending numerous tiny-value transactions to:
- **Transaction noise** that hides malicious activity
- **Sybil identities** for airdrop abuse
- **Governance manipulation** through multiple micro-interactions
- **Network congestion** as a denial-of-service vector

## ⚡ How It Works

The system uses a recorder-assisted detection mechanism.

### 1. **DustRecorder.sol** 📊
- A lightweight contract with a ring buffer that stores data about incoming transactions.
- Target contracts call the `record()` function on every transfer they want to monitor.

### 2. **DustAttackTrap.sol** 🪤 (Drosera-compliant)
- **`collect()`**: Periodically called by the Drosera network, this function reads the latest entries from the `DustRecorder`.
- **`shouldRespond()`**: A pure function that analyzes the collected data for dust attack patterns (e.g., high frequency of low-value transfers from multiple unique senders within a specific block window). It triggers an alert if the configured thresholds are met.

### 3. **DustAttackResponder.sol** 🚨
- A separate contract that receives alerts from the Drosera guardian.
- It emits a `DustAttackAlert` event and can be configured to take automated actions, like pausing a contract.

## 🏗️ Technical Architecture

### Smart Contract Stack
- `DustRecorder.sol`: Records transaction data.
- `DustAttackTrap.sol`: Analyzes data and detects attacks (Drosera-compliant).
- `DustAttackResponder.sol`: Responds to alerts.

### Deployment Details (Hoodi Testnet)
- **Chain ID**: `560048`
- **DustRecorder**: `0x9Ae18fAe2553ED33871c7B054Cc38f428302d5dd`
- **DustAttackTrap**: `0x7aF49C86CA5f796BAe77Ee7bEeB0D38d002776E6`
- **DustAttackResponder**: `0x4C832Bb03356aAA2eDB6eC50Fe62F3Fc2d74E48c`

## 🚀 Quick Start

### 1. Deploy Contracts
```bash
# The contracts are already deployed on Hoodi testnet.
# To redeploy, run:
forge create src/DustAttackTrap.sol:DustAttackTrap --rpc-url <your_rpc_url> --private-key <your_private_key> --broadcast
```

### 2. Configure Drosera
Create a `drosera-config.toml` file:
```toml
[trap]
trap_address = "0x7aF49C86CA5f796BAe77Ee7bEeB0D38d002776E6"
collect_function = "collect()"
should_respond_function = "shouldRespond(bytes[])"

[response]  
response_address = "0x4C832Bb03356aAA2eDB6eC50Fe62F3Fc2d74E48c"
response_function = "respondToDustAttack(bytes)"

[network]
chain_id = 560048
rpc_url = "<your_rpc_url>"

[guardian]
address = "<your_guardian_address>"
```

### 3. Run Drosera Operator
```bash
# Install Drosera CLI
curl -sSL https://install.drosera.network | sh

# Initialize and start
drosera init --config drosera-config.toml
drosera start
```

## 🔗 Integration Examples

Add this one line to any contract you want to monitor.

**Interface:**
```solidity
interface IDustRecorder {
    function record(address from, uint256 amount) external;
}
```

**Example:**
```solidity
contract MyToken is ERC20 {
    IDustRecorder constant DUST_RECORDER = IDustRecorder(0x9Ae18fAe2553ED33871c7B054Cc38f428302d5dd);
    
    function transfer(address to, uint256 amount) public override returns (bool) {
        DUST_RECORDER.record(msg.sender, amount); // Record the transfer
        return super.transfer(to, amount);
    }
}
```

## ⚠️ Security Considerations

- **Guardian Security**: Use a multisig for the guardian address in production.
- **RPC Security**: Use a private, dedicated RPC endpoint for the Drosera operator in production to avoid rate limiting.
- **Key Security**: Never commit private keys to Git.

---

🛡️ Protecting DeFi, One Dust Particle at a Time