
import { ethers } from "hardhat";

async function main() {
  const [deployer] = await ethers.getSigners();
  const token = await ethers.deployContract("BeepNFT", ["BeepNFT", "BEEP", 'https://unitba-249bfef801d8.herokuapp.com/api/meta/', '0x4d2996e95Cc316B174c0a14B590387a86521E981']);
  const nftAddress = await token.getAddress()
  await token.ownerMint(deployer.address, 1)
  console.log('nftAddress', nftAddress)
  const _implementation = await ethers.deployContract("ERC6511Account");
  const implementation = await _implementation.getAddress()
  console.log('implementation', implementation)
  const _registry = await ethers.getContractFactory('ERC6551Registry');
  const registry = _registry.attach('0x02101dfB77FDE026414827Fdc604ddAF224F0921');

  const beepAddress = await registry.createAccount(implementation, 5, nftAddress, 1, 0, [])
  console.log('beepAddress', beepAddress)

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});


