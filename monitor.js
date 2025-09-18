const { ethers } = require("ethers");

// Your deployed contract addresses
const CONFIG = {
    RPC_URL: "https://rpc.ankr.com/eth_hoodi/6852445d1ba0cde4f6506223f888d4a756889df7254b65674820c4324ab7eeba",
    RECORDER_ADDRESS: "0x9Ae18fAe2553ED33871c7B054Cc38f428302d5dd",
    TRAP_ADDRESS: "0x203a658Dda3a4cf44C12c18bCfde0F7F15693F32",
    RESPONDER_ADDRESS: "0x4C832Bb03356aAA2eDB6eC50Fe62F3Fc2d74E48c"
};

const RECORDER_ABI = [
    "function getLast(uint256 k) view returns (tuple(address from, uint64 blk, uint96 amount)[])",
    "function getEntryCount() view returns (uint256)",
    "event TransactionRecorded(address from, uint256 amount, uint256 block)"
];

const TRAP_ABI = [
    "function collect() view returns (bytes)",
    "function getStatus() view returns (uint256, uint256, bool)"
];

const RESPONDER_ABI = [
    "event DustAttackAlert(uint256 dustCount, uint256 uniqueSenders, uint256 blockNumber, string alertType, uint256 timestamp)",
    "event EmergencyPause(string reason, uint256 timestamp)"
];

async function monitor() {
    console.log("🔍 Starting Dust Attack Monitoring Dashboard...");
    console.log("Chain: 560048");
    console.log("Recorder:", CONFIG.RECORDER_ADDRESS);
    console.log("Trap:", CONFIG.TRAP_ADDRESS);
    console.log("Responder:", CONFIG.RESPONDER_ADDRESS);
    console.log("=".repeat(60));

    const provider = new ethers.providers.JsonRpcProvider(CONFIG.RPC_URL);
    
    const recorder = new ethers.Contract(CONFIG.RECORDER_ADDRESS, RECORDER_ABI, provider);
    const trap = new ethers.Contract(CONFIG.TRAP_ADDRESS, TRAP_ABI, provider);
    const responder = new ethers.Contract(CONFIG.RESPONDER_ADDRESS, RESPONDER_ABI, provider);

    // Listen for new transactions
    recorder.on("TransactionRecorded", (from, amount, block) => {
        const ethAmount = ethers.utils.formatEther(amount);
        const timestamp = new Date().toLocaleTimeString();
        console.log(`📝 [${timestamp}] Transaction: ${from} -> ${ethAmount} ETH (Block ${block})`);
    });

    // Listen for dust attack alerts
    responder.on("DustAttackAlert", (dustCount, uniqueSenders, blockNumber, alertType, timestamp) => {
        console.log("\n🚨🚨🚨 DUST ATTACK DETECTED! 🚨🚨🚨");
        console.log(`Dust Transactions: ${dustCount}`);
        console.log(`Unique Senders: ${uniqueSenders}`);
        console.log(`Block Number: ${blockNumber}`);
        console.log(`Alert Type: ${alertType}`);
        console.log(`Time: ${new Date(timestamp * 1000).toISOString()}`);
        console.log("🚨 TAKE IMMEDIATE ACTION! 🚨\n");
        console.log("=".repeat(60));
    });

    // Listen for emergency pauses
    responder.on("EmergencyPause", (reason, timestamp) => {
        console.log("\n⏸️EMERGENCY PAUSE ACTIVATED!");
        console.log(`Reason: ${reason}`);
        console.log(`Time: ${new Date(timestamp * 1000).toISOString()}\n`);
    });

    // Periodic status updates
    console.log("📊 Starting periodic status checks...\n");
    setInterval(async () => {
        try {
            const [dustCount, threshold, wouldTrigger] = await trap.getStatus();
            const entryCount = await recorder.getEntryCount();
            const blockNumber = await provider.getBlockNumber();
            
            const status = wouldTrigger ? "🚨 ALERT" : "✅ OK";
            const timestamp = new Date().toLocaleTimeString();
            
            console.log(`[${timestamp}] ${status} | Dust: ${dustCount}/${threshold} | Entries: ${entryCount} | Block: ${blockNumber}`);
            
        } catch (error) {
            console.log("❌ Error checking status:", error.message);
        }
    }, 30000); // Every 30 seconds
}

// Handle graceful shutdown
process.on('SIGINT', () => {
    console.log('\n👋 Shutting down monitoring dashboard...');
    process.exit(0);
});

monitor().catch(console.error);
