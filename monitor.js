// Simple monitoring script for the trap
const { ethers } = require("ethers");

// Replace with your deployed contract address
const TRAP_ADDRESS = "YOUR_DEPLOYED_CONTRACT_ADDRESS";

// Replace with your RPC URL (don't include private keys in code!)
const RPC_URL = "YOUR_RPC_URL_HERE";

const TRAP_ABI = [
    "function isDustAttackDetected() view returns (bool)",
    "function getCurrentDustCount() view returns (uint256)",
    "function getStatus() view returns (uint256, uint256, bool)",
    "event DustAttackDetected(uint256 totalDust, uint256 blockNumber, string message)",
    "event DustLogged(address sender, uint256 value, uint256 block)"
];

async function monitor() {
    const provider = new ethers.providers.JsonRpcProvider(RPC_URL);
    const contract = new ethers.Contract(TRAP_ADDRESS, TRAP_ABI, provider);
    
    console.log("🔍 Monitoring for dust attacks...");
    
    // Listen for dust attack events
    contract.on("DustAttackDetected", (totalDust, blockNumber, message) => {
        console.log("\n🚨 ALERT: DUST ATTACK DETECTED!");
        console.log("Total dust transactions:", totalDust.toString());
        console.log("Block number:", blockNumber.toString());
        console.log("Message:", message);
        console.log("Take immediate action!\n");
    });
    
    // Listen for dust transactions
    contract.on("DustLogged", (sender, value, block) => {
        console.log(`💧 Dust logged: ${sender} sent ${ethers.utils.formatEther(value)} ETH at block ${block}`);
    });
    
    // Periodic status check
    setInterval(async () => {
        try {
            const [currentDust, threshold, isUnderAttack] = await contract.getStatus();
            console.log(`Status: ${currentDust}/${threshold} dust transactions | Under attack: ${isUnderAttack}`);
        } catch (error) {
            console.log("Error checking status:", error.message);
        }
    }, 30000); // Check every 30 seconds
}

monitor().catch(console.error);
