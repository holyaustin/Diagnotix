const { ethers } = require("hardhat");

async function main() {
  const HealthDiagnosis = await ethers.getContractFactory("HealthDiagnosis");
  const healthDiag = await HealthDiagnosis.deploy();
  await healthDiag.waitForDeployment();

  console.log("✅ Deployed to:", await healthDiag.getAddress());
  console.log("📋 Contract address:", await healthDiag.getAddress());
  console.log("💡 Default fee: 0.01 ETH");
  console.log("🔐 Owner:", await healthDiag.owner());
}

main().catch(console.error);