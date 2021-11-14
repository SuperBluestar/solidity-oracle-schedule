const { ethers, waffle } = require("hardhat");

async function main() {
  const [owner] = await ethers.getSigners();

  // We get the contract to deploy
  // const KILLAz = await ethers.getContractFactory("KILLAz");
  // killaz = await KILLAz.deploy(owner.address);
  // await killaz.deployed();
  // await killaz.reserveKILLAz();
  // await killaz.flipSaleState();
  
  // console.log("KILLAz deployed to:", killaz.address);
  
  // const LadyKILLAz = await ethers.getContractFactory("LadyKILLAz");
  // const ladyKillaz = await LadyKILLAz.deploy("0x17b39d1493DB0E485EF97BA0a05d4e57e91aAa47");
  // await ladyKillaz.deployed();
  // await ladyKillaz.startSale();
  // await ladyKillaz.buy([1,2,3]);
  
  // console.log("LadyKILLAz deployed to:", ladyKillaz.address);

  const Revenue = await ethers.getContractFactory("Revenue");
  const revenue = await Revenue.deploy("0xB8ce7702f6d579a8af1F0B6806B46Bd57d7E2811", "0x17b39d1493DB0E485EF97BA0a05d4e57e91aAa47", "0x3203B31Ef385634763D18dC6B71bC51ba1BCac39");
  await revenue.deployed();

  console.log("Revenue deployed to:", revenue.address);
}

main()
.then(() => process.exit(0))
.catch((error) => {
    console.error(error);
    process.exit(1);
});