const hre = require('hardhat');
const Config = require('../index');

async function main() {
  await Config.initConfig();
  const [deployer] = await hre.ethers.getSigners();
  console.log('Deploying contracts with the account:', deployer.address);
  const mainContract = await hre.ethers.deployContract('GenArt');
  await mainContract.waitForDeployment();
  let contractAddress = await mainContract.getAddress();
  console.log('Contract address:', contractAddress);
  await Config.updateConfig(contractAddress);
  console.log('Deploy succesful');
}

main().catch(error => {
  console.error(error);
  process.exitCode = 1;
});
