import {CryptoAIData} from "./cryptoAIData";
import {initConfig, updateConfig} from "../../index";
import {
    DATA_BODY,
    DATA_CAT_VARIANT,
    DATA_DNA, DATA_DOG_VARIANT,
    DATA_EYE,
    DATA_FROG_VARIANT,
    DATA_HEAD, DATA_HUMAN_VARIANT,
    DATA_MONKEY_VARIANT,
    DATA_MOUTH, DATA_ROBOT_VARIANT,
    DNA,
    ELEMENT
} from "./data";

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

    //ADD Element
    for (const ele of DATA_MOUTH) {
        await dataContract.addItem(address, 0, ELEMENT.MOUTH, ele);
    }
    for (const ele of DATA_BODY) {
        await dataContract.addItem(address, 0, ELEMENT.BODY, ele);
    }
    for (const ele of DATA_HEAD) {
        await dataContract.addItem(address, 0, ELEMENT.HEAD, ele);
    }
    for (const ele of DATA_EYE) {
        await dataContract.addItem(address, 0, ELEMENT.EYE, ele);
    }

    // await dataContract.getItem(address, 0)

    //ADD DNA
    for (const dna of DATA_DNA) {
        await dataContract.addDNA(address, 0, dna);
    }
    await dataContract.getDNA(address, 0);

    //ADD DNA Variant
    for (const dna_variant of DATA_FROG_VARIANT) {
        await dataContract.addDNAVariant(address, 0, DNA.FROG, dna_variant);
    }
    for (const dna_variant of DATA_HUMAN_VARIANT) {
        await dataContract.addDNAVariant(address, 0, DNA.HUMAN, dna_variant);
    }
    for (const dna_variant of DATA_CAT_VARIANT) {
        await dataContract.addDNAVariant(address, 0, DNA.CAT, dna_variant);
    }
    for (const dna_variant of DATA_DOG_VARIANT) {
        await dataContract.addDNAVariant(address, 0, DNA.DOG, dna_variant);
    }
    for (const dna_variant of DATA_ROBOT_VARIANT) {
        await dataContract.addDNAVariant(address, 0, DNA.ROBOT, dna_variant);
    }
    for (const dna_variant of DATA_MONKEY_VARIANT) {
        await dataContract.addDNAVariant(address, 0, DNA.MONKEY, dna_variant);
    }

    for (const dna_variant of DATA_CAT_VARIANT) {
        await dataContract.addDNAVariant(address, 0, DNA.CAT, dna_variant);
    }

    for (const dna of DATA_DNA) {
        const getDNAVariant = await dataContract.getDNAVariant(address, 0, dna);
        // console.log("getDNAVariant", getDNAVariant);
    }

    // Render SVG
    const fullSVG = await dataContract.renderFullSVGWithGrid(address, 5);
    console.log("fullSVG", fullSVG);

/*    const ele = await dataContract.getArrayItemsType(address, ELEMENT.HEAD);
    console.log("ele", ele);*/

}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});