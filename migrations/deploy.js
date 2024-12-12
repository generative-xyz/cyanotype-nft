const hre = require('hardhat');
const Config = require('../index.bk');

async function main() {
    await Config.initConfig();
    const [deployer] = await hre.ethers.getSigners();
    console.log('Deploying contracts with the account:', deployer.address);
    const mainContract = await hre.ethers.deployContract('CharacterInfo');
    await mainContract.waitForDeployment();
    let contractAddress = await mainContract.getAddress();
    console.log('contract address:', contractAddress);
    await Config.updateConfig(contractAddress);
    console.log('Deploy succesful');
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});