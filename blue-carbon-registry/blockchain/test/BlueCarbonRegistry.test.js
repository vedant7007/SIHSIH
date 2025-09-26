const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("BlueCarbonRegistry", function () {
  let BlueCarbonRegistry;
  let contract;
  let owner;
  let ngo;
  let buyer;
  let admin;

  beforeEach(async function () {
    // Get signers
    [owner, ngo, buyer, admin] = await ethers.getSigners();

    // Deploy contract
    BlueCarbonRegistry = await ethers.getContractFactory("BlueCarbonRegistry");
    contract = await BlueCarbonRegistry.deploy(
      owner.address,
      "https://api.bluecarbonregistry.com/metadata/"
    );

    await contract.waitForDeployment();
  });

  describe("Deployment", function () {
    it("Should set the correct admin role", async function () {
      const adminRole = await contract.ADMIN_ROLE();
      expect(await contract.hasRole(adminRole, owner.address)).to.be.true;
    });

    it("Should set the correct minter role", async function () {
      const minterRole = await contract.MINTER_ROLE();
      expect(await contract.hasRole(minterRole, owner.address)).to.be.true;
    });

    it("Should start with token ID 1", async function () {
      expect(await contract.nextTokenId()).to.equal(1);
    });
  });

  describe("Credit Minting", function () {
    it("Should mint credits successfully", async function () {
      const projectId = "PROJECT_001";
      const amount = 1000;
      const projectData = "ipfs://QmHash123";

      await expect(
        contract.mintCredits(projectId, ngo.address, amount, projectData)
      )
        .to.emit(contract, "CreditsMinted")
        .withArgs(1, projectId, ngo.address, amount, projectData);

      // Check balance
      expect(await contract.balanceOf(ngo.address, 1)).to.equal(amount);

      // Check total minted
      expect(await contract.totalCreditsMinted()).to.equal(amount);

      // Check project info
      const projectInfo = await contract.getProjectInfo(1);
      expect(projectInfo.projectId).to.equal(projectId);
      expect(projectInfo.totalCredits).to.equal(amount);
      expect(projectInfo.projectOwner).to.equal(ngo.address);
    });

    it("Should fail if not minter role", async function () {
      await expect(
        contract.connect(buyer).mintCredits("PROJECT_001", ngo.address, 1000, "data")
      ).to.be.reverted;
    });

    it("Should fail with invalid parameters", async function () {
      await expect(
        contract.mintCredits("", ngo.address, 1000, "data")
      ).to.be.revertedWith("Project ID required");

      await expect(
        contract.mintCredits("PROJECT_001", ethers.ZeroAddress, 1000, "data")
      ).to.be.revertedWith("Invalid project owner");

      await expect(
        contract.mintCredits("PROJECT_001", ngo.address, 0, "data")
      ).to.be.revertedWith("Amount must be greater than 0");
    });
  });

  describe("Credit Retirement", function () {
    beforeEach(async function () {
      // Mint credits first
      await contract.mintCredits("PROJECT_001", ngo.address, 1000, "ipfs://QmHash123");

      // Transfer some credits to buyer
      await contract.connect(ngo).safeTransferFrom(ngo.address, buyer.address, 1, 500, "0x");
    });

    it("Should retire credits successfully", async function () {
      const retireAmount = 300;
      const certificateURI = "ipfs://certificate123";
      const purpose = "Carbon offset for company operations";

      await expect(
        contract.connect(buyer).retireCredits(1, retireAmount, certificateURI, purpose)
      )
        .to.emit(contract, "CreditsRetired")
        .withArgs(1, buyer.address, retireAmount, certificateURI, purpose);

      // Check balance reduced
      expect(await contract.balanceOf(buyer.address, 1)).to.equal(200);

      // Check total retired
      expect(await contract.totalCreditsRetired()).to.equal(retireAmount);

      // Check project retired credits
      const projectInfo = await contract.getProjectInfo(1);
      expect(projectInfo.retiredCredits).to.equal(retireAmount);

      // Check available credits
      expect(await contract.getAvailableCredits(1)).to.equal(700);

      // Check retirement history
      const retirements = await contract.getRetirementHistory(buyer.address);
      expect(retirements.length).to.equal(1);
      expect(retirements[0].amount).to.equal(retireAmount);
      expect(retirements[0].purpose).to.equal(purpose);
    });

    it("Should fail with insufficient balance", async function () {
      await expect(
        contract.connect(buyer).retireCredits(1, 600, "cert", "purpose")
      ).to.be.revertedWith("Insufficient balance");
    });

    it("Should fail with invalid amount", async function () {
      await expect(
        contract.connect(buyer).retireCredits(1, 0, "cert", "purpose")
      ).to.be.revertedWith("Amount must be greater than 0");
    });
  });

  describe("Token Transfers", function () {
    beforeEach(async function () {
      await contract.mintCredits("PROJECT_001", ngo.address, 1000, "ipfs://QmHash123");
    });

    it("Should transfer tokens successfully", async function () {
      await contract.connect(ngo).safeTransferFrom(ngo.address, buyer.address, 1, 300, "0x");

      expect(await contract.balanceOf(ngo.address, 1)).to.equal(700);
      expect(await contract.balanceOf(buyer.address, 1)).to.equal(300);
    });

    it("Should handle batch transfers", async function () {
      // Mint another project
      await contract.mintCredits("PROJECT_002", ngo.address, 500, "ipfs://QmHash456");

      const ids = [1, 2];
      const amounts = [200, 100];

      await contract.connect(ngo).safeBatchTransferFrom(
        ngo.address,
        buyer.address,
        ids,
        amounts,
        "0x"
      );

      expect(await contract.balanceOf(buyer.address, 1)).to.equal(200);
      expect(await contract.balanceOf(buyer.address, 2)).to.equal(100);
    });
  });

  describe("Admin Functions", function () {
    beforeEach(async function () {
      await contract.mintCredits("PROJECT_001", ngo.address, 1000, "ipfs://QmHash123");
    });

    it("Should update project data", async function () {
      const newData = "ipfs://QmNewHash456";

      await expect(
        contract.updateProjectData(1, newData)
      ).to.emit(contract, "ProjectUpdated").withArgs(1, newData);

      const projectInfo = await contract.getProjectInfo(1);
      expect(projectInfo.projectData).to.equal(newData);
    });

    it("Should deactivate batch", async function () {
      await contract.deactivateBatch(1);

      const projectInfo = await contract.getProjectInfo(1);
      expect(projectInfo.active).to.be.false;

      // Should fail to retire from inactive batch
      await expect(
        contract.connect(ngo).retireCredits(1, 100, "cert", "purpose")
      ).to.be.revertedWith("Token batch not active");
    });

    it("Should fail if not admin", async function () {
      await expect(
        contract.connect(buyer).updateProjectData(1, "newdata")
      ).to.be.reverted;

      await expect(
        contract.connect(buyer).deactivateBatch(1)
      ).to.be.reverted;
    });
  });

  describe("View Functions", function () {
    beforeEach(async function () {
      await contract.mintCredits("PROJECT_001", ngo.address, 1000, "ipfs://QmHash123");
      await contract.connect(ngo).safeTransferFrom(ngo.address, buyer.address, 1, 500, "0x");
      await contract.connect(buyer).retireCredits(1, 200, "cert", "purpose");
    });

    it("Should return correct token existence", async function () {
      expect(await contract.tokenExists(1)).to.be.true;
      expect(await contract.tokenExists(999)).to.be.false;
    });

    it("Should return retirement history", async function () {
      const retirements = await contract.getRetirementHistory(buyer.address);
      expect(retirements.length).to.equal(1);
      expect(retirements[0].amount).to.equal(200);
    });

    it("Should return token retirements", async function () {
      const retirements = await contract.getTokenRetirements(1);
      expect(retirements.length).to.equal(1);
      expect(retirements[0].retiree).to.equal(buyer.address);
    });

    it("Should return available credits", async function () {
      expect(await contract.getAvailableCredits(1)).to.equal(800);
    });

    it("Should return correct URI", async function () {
      const uri = await contract.uri(1);
      expect(uri).to.equal("https://api.bluecarbonregistry.com/metadata/1");
    });
  });
});