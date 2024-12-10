import {CryptoAIData} from "./cryptoAIData";
import {initConfig, updateConfig} from "../../index";

async function main() {
    if (process.env.NETWORK != "local") {
        console.log("wrong network");
        return;
    }

    await initConfig();

    // const [deployer] = await hre.ethers.getSigners();
    // console.log('Deploying contracts with the account:', deployer.address);
    // const mainContract = await hre.ethers.deployContract('CharacterInfo');
    // await mainContract.waitForDeployment();
    // let contractAddress = await mainContract.getAddress();

    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    const address = await dataContract.deployUpgradeable(process.env.PUBLIC_KEY, process.env.PUBLIC_KEY)
    console.log('CryptoAIData contract address:', address);
    await updateConfig("dataContract", address);
    console.log('Deploy succesful');
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});