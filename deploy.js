const hre = require("hardhat");

async function main() {
  const [deployer] = await hre.ethers.getSigners();
  const biddingTime = 3600; // 1 hour
  const revealTime = 1800;  // 30 mins

  const SealedBidAuction = await hre.ethers.getContractFactory("SealedBidAuction");
  const auction = await SealedBidAuction.deploy(biddingTime, revealTime, deployer.address);

  await auction.waitForDeployment();
  console.log(`Sealed Bid Auction deployed to: ${await auction.getAddress()}`);
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
