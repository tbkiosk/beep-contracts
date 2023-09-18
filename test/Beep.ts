import {
  time,
  loadFixture,
} from "@nomicfoundation/hardhat-toolbox/network-helpers";
import { anyValue } from "@nomicfoundation/hardhat-chai-matchers/withArgs";
import { expect } from "chai";
import { ethers } from "hardhat";
import { Contract } from "ethers";

describe("Beep", function () {
  let owner;
  let botWallet;
  let _user1;
  let token: { getAddress: () => any; ownerMint: (arg0: string, arg1: number) => any; };
  let _implementation : { getAddress: () => any; }
  let registry: { getAddress: () => any; createAccount: (arg0: string, arg1: number, arg2: any, arg3: number, arg4: number, arg5: never[]) => any; account: (arg0: Promise<string>, arg1: number, arg2: any, arg3: number, arg4: number) => any; };


  beforeEach(async function () {
    [
      owner,
        botWallet,
        _user1,
        _user1
      ] = await ethers.getSigners();
      console.log("starting")
      const [deployer] = await ethers.getSigners();
      token = await ethers.deployContract("BeepNFT", ["BeepNFT", "BEEP", 'https://unitba-249bfef801d8.herokuapp.com/api/meta/', '0x4d2996e95Cc316B174c0a14B590387a86521E981']);
      const nftAddress = await token.getAddress()
      await token.ownerMint(deployer.address, 1)
      console.log('nftAddress', nftAddress)
      _implementation = await ethers.deployContract("ERC6551Account");
      const implementation = await _implementation.getAddress()
      console.log('implementation', implementation)
      registry = await ethers.deployContract('ERC6551Registry');
  });

  it("Should display TBA", async function() {

    const getBeepAddres = await registry.account(_implementation.getAddress(), 5, token.getAddress(), 1, 0)
    console.log('getBeepAddres', getBeepAddres)
    await registry.createAccount(_implementation.getAddress(), 5, token.getAddress(), 1, 0, "0x")
  });

});
