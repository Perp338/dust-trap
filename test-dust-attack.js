const { ethers } = require("ethers");

const CONFIG = {
    RPC_URL: "https://rpc.ankr.com/eth_hoodi/6852445d1ba0cde4f6506223f888d4a756889df7254b65674820c4324ab7eeba",
    RECORDER_ADDRESS: "0x9Ae18fAe2553ED33871c7B054Cc38f428302d5dd",
    PRIVATE_KEY: "0x133bf0940d73f65c4459480473d9a7b66e40559282738be79fba422be9130d9a" // For testing only
};

async function simulateDustAttack() {
    console.log("🧪 Simulating dust attack for testing...");
    
    const provider = new ethers.providers.JsonRpcProvider(CONFIG.RPC_URL);
    const wallet = new ethers.Wallet(CONFIG.PRIVATE_KEY, provider);
    
    const recorderABI = ["function record(address from, uint256 amount) external"];
    const recorder = new ethers.Contract(CONFIG.RECORDER_ADDRESS, recorderABI, wallet);
    
    console.log("📤 Sending 20 dust transactions...");
    
    // Send 20 dust transactions to trigger the alert
    for (let i = 0; i < 20; i++) {
        try {
            const tx = await recorder.record(wallet.address, ethers.utils.parseEther("0.0001"), {
                gasLimit: 100000
            });
            console.log(`✅ Dust tx ${i + 1}/20: ${tx.hash}`);
            await tx.wait();
        } catch (error) {
            console.log(`❌ Tx ${i + 1} failed:`, error.message);
        }
    }
    
    console.log("🎯 Test complete! Check your monitoring dashboard for alerts.");
}

simulateDustAttack().catch(console.error);
