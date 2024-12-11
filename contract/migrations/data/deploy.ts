import {CryptoAIData} from "./cryptoAIData";
import {initConfig, updateConfig} from "../../index";

async function main() {
    if (process.env.NETWORK != "local") {
        console.log("wrong network");
        return;
    }

    let configaaa = await initConfig();

    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    const address = await dataContract.deployUpgradeable(process.env.PUBLIC_KEY, process.env.PUBLIC_KEY)
    console.log('CryptoAIData contract address:', address);
    await updateConfig("dataContractAddress", address);
    console.log('Deploy succesful');

    await dataContract.upgradeContract(configaaa['dataContractAddress'])

    // const deployer = await dataContract.getDeployer(address)
    // console.log("deployer", deployer);
    //
    // await dataContract.addItem(address, 0)
    // const item = await dataContract.getItem(address, 0)
    // console.log("item", item)
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});