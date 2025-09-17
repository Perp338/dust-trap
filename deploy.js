// Simple deployment script for Drosera
const { ethers } = require("hardhat");

async function main() {
    console.log("Deploying Dust Attack Trap...");
    
    const DustAttackTrap = await ethers.getContractFactory("DustAttackTrap");
    const trap = await DustAttackTrap.deploy();
    
    await trap.deployed();
    
    console.log("Dust Attack Trap deployed to:", trap.address);
    console.log("Monitor this contract for dust attacks!");
    
    // Display current settings
    const threshold = await trap.DUST_THRESHOLD();
    const countThreshold = await trap.COUNT_THRESHOLD();
    const blockWindow = await trap.BLOCK_WINDOW();
    
    console.log("\nTrap Settings:");
    console.log("- Dust Threshold:", ethers.utils.formatEther(threshold), "ETH");
    console.log("- Count Threshold:", countThreshold.toString(), "transactions");
    console.log("- Block Window:", blockWindow.toString(), "blocks");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
