const hre = require("hardhat");

async function main() {
  const accounts = [
    "0x8626f6940E2eb28930eFb4CeF49B2d1F2C9C1199",
    "0xdD2FD4581271e230360230F9337D5c0430Bf44C0",
    "0xbDA5747bFD65F08deb54cb465eB87D40e51B197E",
    "0x2546BcD3c84621e976D8185a91A922aE77ECEc30",
  ];

  const required = 3;

  //____________________________________________________________________________//
  const MultisignatureWallet = await hre.ethers.getContractFactory(
    "MultisignatureWallet"
  );
  const multisignaturewallet = await MultisignatureWallet.deploy(
    accounts,
    required
  );

  await multisignaturewallet.deployed();

  console.log(
    `Multisignature Wallet deployed at: ${multisignaturewallet.address}`
  );
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
