const { expect } = require("chai");
const { ethers, waffle } = require("hardhat");

describe("Revenue contract", function () {
  let revenue, killaz, ladyKillaz;

  before(async () => {
    const [owner] = await ethers.getSigners();

    const KILLAz = await ethers.getContractFactory("KILLAz");
    killaz = await KILLAz.deploy(owner.address);
    await killaz.deployed();
    await killaz.flipSaleState();

    const LadyKILLAz = await ethers.getContractFactory("LadyKILLAz");
    ladyKillaz = await LadyKILLAz.deploy(killaz.address);
    await ladyKillaz.deployed();
    await ladyKillaz.startSale();

    const Revenue = await ethers.getContractFactory("Revenue");
    revenue = await Revenue.deploy(owner.address, killaz.address, ladyKillaz.address);
    await revenue.deployed();
  });

  it("Buy NFTs", async() => {
    const [owner, ...addrs] = await ethers.getSigners();
    for (let i = 0; i < addrs.length; i++) {
      console.log(addrs[i].address);
      await killaz.connect(addrs[i]).mintKILLAz(3, {value: ethers.utils.parseEther("0.087")});
      await ladyKillaz.connect(addrs[i]).buy([i * 5, i * 5 + 1, i * 5 + 2, i * 5 + 3, i * 5 + 4], {value: ethers.utils.parseEther("0.29")});
    }
  });

  it("Test oracle", async() => {
    const [owner, ...addrs] = await ethers.getSigners();
    await revenue.startUpdate();

    await revenue.updateListing(killaz.address, [1,2,3,4,5]);
    await revenue.updateListing(killaz.address, [12,14,15,16,24]);

    await revenue.updateListing(ladyKillaz.address, [31, 18, 41, 33, 19]);

    await revenue.endUpdate(10, 5);

    console.log(await revenue.getPairsOf(killaz.address, addrs[3].address));
    console.log(await revenue.getPairsOf(ladyKillaz.address, addrs[3].address));
  })

  it("Test claimShare", async() => {
    const [owner, ...addrs] = await ethers.getSigners();
    
    await owner.sendTransaction({to: revenue.address, value: ethers.utils.parseEther("5")});
    console.log('Total Revenue', (await waffle.provider.getBalance(revenue.address)).toString());

    const tester = addrs[3];
    await revenue.connect(tester).claimShare();
    let result = await revenue.balanceOf(tester.address);
    console.log('Claimed Revenue', result.toString());

    await revenue.connect(tester).withrawShare(result);

    result = await revenue.balanceOf(tester.address);
    console.log('After Withrawn', result.toString());

    console.log('Total Revenue', (await waffle.provider.getBalance(revenue.address)).toString());
  });

  // it("Test Re-claimShare", async() => {
  //   const [owner, ...addrs] = await ethers.getSigners();

  //   await revenue.connect(addrs[0]).claimShare();
  // });

});

