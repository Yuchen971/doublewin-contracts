import { expect } from "chai";
import hre from "hardhat";

const { ethers } = await hre.network.connect();

describe("VRFConsumer", function () {
  it("should request and fulfill random word via mock", async function () {
    const [owner] = await ethers.getSigners();

    // Deploy mock VRF Coordinator using fully qualified name (Hardhat 3 requires this for node_modules contracts)
    const MockCoordinator = await ethers.getContractFactory(
      "contracts/test/VRFMockImports.sol:VRFCoordinatorV2_5Mock",
    );
    // Constructor: baseFee, gasPriceLink, weiPerUnitLink
    const mockCoordinator = await MockCoordinator.deploy(100000, 100000, 1e9);
    await mockCoordinator.waitForDeployment();
    const coordAddr = await mockCoordinator.getAddress();

    // Create subscription
    const tx = await mockCoordinator.createSubscription();
    const receipt = await tx.wait();
    // Get subscription ID from event
    const subCreatedEvent = receipt?.logs.find((log: any) => {
      try {
        return mockCoordinator.interface.parseLog(log)?.name === "SubscriptionCreated";
      } catch { return false; }
    });
    const subId = mockCoordinator.interface.parseLog(subCreatedEvent!)!.args.subId;

    // Fund subscription
    await mockCoordinator.fundSubscription(subId, ethers.parseEther("10"));

    // Deploy VRFConsumer
    const VRFConsumerFactory = await ethers.getContractFactory("VRFConsumer");
    const keyHash = "0x" + "00".repeat(32);
    const consumer = await VRFConsumerFactory.deploy(
      coordAddr, subId, keyHash, 200000, 3,
    );
    await consumer.waitForDeployment();
    const consumerAddr = await consumer.getAddress();

    // Add consumer to subscription
    await mockCoordinator.addConsumer(subId, consumerAddr);

    // Request random word
    const reqTx = await consumer.requestRandomWord();
    const reqReceipt = await reqTx.wait();
    expect(reqReceipt?.status).to.equal(1);

    // Fulfill via mock (simulates Chainlink oracle)
    await mockCoordinator.fulfillRandomWords(1, consumerAddr);

    // Check result
    const [randomWord, requestId, fulfilledAt] = await consumer.getLatestRandom();
    expect(randomWord).to.be.gt(0);
    expect(requestId).to.equal(1);
    expect(fulfilledAt).to.be.gt(0);
  });
});
