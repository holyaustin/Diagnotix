const { expect } = require("chai");
const { ethers } = require("hardhat");

describe("HealthDiagnosis", function () {
  let healthDiag, owner, user, otherUser;

  beforeEach(async function () {
    [owner, user, otherUser] = await ethers.getSigners();
    const HealthDiagnosis = await ethers.getContractFactory("HealthDiagnosis");
    healthDiag = await HealthDiagnosis.deploy();
    await healthDiag.waitForDeployment();
  });

  it("Should deploy with default fee of 0.01 ETH", async function () {
    expect(await healthDiag.fee()).to.equal(ethers.parseEther("0.01"));
  });

  it("Should allow diagnosis submission with correct fee", async function () {
    await expect(
      healthDiag.connect(user).submitDiagnosis(
        "fever,cough",
        "Likely: Flu",
        { value: ethers.parseEther("0.01") }
      )
    ).to.emit(healthDiag, "Diagnosed");

    const records = await healthDiag.getRecords(user.address);
    expect(records.length).to.equal(1);
    expect(records[0].symptoms).to.equal("fever,cough");
  });

  it("Should reject insufficient payment", async function () {
    await expect(
      healthDiag.connect(user).submitDiagnosis("headache", "Rest", { value: 0 })
    ).to.be.revertedWith("HealthDiagnosis: insufficient payment");
  });

  it("Should allow owner to update fee", async function () {
    await expect(healthDiag.connect(owner).setFee(ethers.parseEther("0.02")))
      .to.emit(healthDiag, "FeeUpdated")
      .withArgs(ethers.parseEther("0.01"), ethers.parseEther("0.02"));

    expect(await healthDiag.fee()).to.equal(ethers.parseEther("0.02"));
  });

  it("Should prevent non-owner from updating fee", async function () {
    await expect(
      healthDiag.connect(user).setFee(ethers.parseEther("0.02"))
    ).to.be.revertedWith("HealthDiagnosis: not owner");
  });

  it("Should allow owner to withdraw", async function () {
    const payment = ethers.parseEther("0.01");
    await healthDiag.connect(user).submitDiagnosis("test", "result", { value: payment });

    await expect(() => healthDiag.connect(owner).withdraw())
      .to.changeEtherBalance(owner, payment);
  });
});