const hre = require("hardhat");

async function main() {
  console.log("Deploying Blue Carbon Registry contract...");

  // Get the contract factory
  const BlueCarbonRegistry = await hre.ethers.getContractFactory("BlueCarbonRegistry");

  // Get deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying with account:", deployer.address);

  // Check balance
  const balance = await hre.ethers.provider.getBalance(deployer.address);
  console.log("Account balance:", hre.ethers.formatEther(balance), "ETH");

  // Deploy contract
  const baseURI = "https://api.bluecarbonregistry.com/metadata/";
  const contract = await BlueCarbonRegistry.deploy(
    deployer.address, // admin address
    baseURI
  );

  await contract.waitForDeployment();

  const contractAddress = await contract.getAddress();
  console.log("BlueCarbonRegistry deployed to:", contractAddress);

  // Save deployment info
  const deploymentInfo = {
    network: hre.network.name,
    contractAddress: contractAddress,
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    baseURI: baseURI
  };

  console.log("Deployment info:", deploymentInfo);

  // Verify contract on Polygonscan (if not local network)
  if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
    console.log("Waiting for block confirmations...");
    await contract.deploymentTransaction().wait(6);

    console.log("Verifying contract on Polygonscan...");
    try {
      await hre.run("verify:verify", {
        address: contractAddress,
        constructorArguments: [deployer.address, baseURI],
      });
      console.log("Contract verified successfully!");
    } catch (error) {
      console.log("Verification failed:", error.message);
    }
  }

  // Test basic functionality
  console.log("Testing basic contract functionality...");

  try {
    const adminRole = await contract.ADMIN_ROLE();
    const minterRole = await contract.MINTER_ROLE();

    console.log("Admin role:", adminRole);
    console.log("Minter role:", minterRole);

    const hasAdminRole = await contract.hasRole(adminRole, deployer.address);
    const hasMinterRole = await contract.hasRole(minterRole, deployer.address);

    console.log("Deployer has admin role:", hasAdminRole);
    console.log("Deployer has minter role:", hasMinterRole);

    console.log("Contract deployment and verification completed successfully!");

  } catch (error) {
    console.error("Error testing contract:", error.message);
  }

  // Return deployment info for use in other scripts
  return {
    contractAddress,
    deployer: deployer.address,
    network: hre.network.name
  };
}

// Execute deployment
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error("Deployment failed:", error);
    process.exit(1);
  });