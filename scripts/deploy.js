const { ethers, waffle } = require("hardhat");

async function main() {
  const [owner] = await ethers.getSigners();

  const Revenue = await ethers.getContractFactory("Revenue");
  const revenue = await Revenue.deploy(
    "", // Oracle's owner address
    "0x21850dcfe24874382b12d05c5b189f5a2acf0e5b", // Killaz contract's address
    "0xe4d0e33021476ca05ab22c8bf992d3b013752b80" // LadyKillaz contract's address
  );
  await revenue.deployed();

  console.log("Revenue deployed to:", revenue.address);
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});