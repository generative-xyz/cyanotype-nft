import {CryptoAIData} from "./cryptoAIData";
import {initConfig, updateConfig} from "../../index";

async function main() {
    if (process.env.NETWORK != "local") {
        console.log("wrong network");
        return;
    }

    await initConfig();

    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    const address = await dataContract.deployUpgradeable(process.env.PUBLIC_KEY, process.env.PUBLIC_KEY)
    console.log('CryptoAIData contract address:', address);
    await updateConfig("dataContractAddress", address);
    console.log('Deploy succesful');

    const deployer = await dataContract.getDeployer(address)
    console.log("deployer", deployer);

    await dataContract.addItem(address, 0)
    const item = await dataContract.getItem(address, 0)
    console.log('item', item);
    await dataContract.addDNA(address, 0, 'monkey');
    const dataDNA = await dataContract.getDNA(address, 0);
    await dataContract.addDNAVariant(address, 0);
    const getDNAVariant = await dataContract.getDNAVariant(address, 0);

    console.log("dataDNA", dataDNA);
    console.log("getDNAVariant", getDNAVariant);

}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});