import {CryptoAIData} from "./cryptoAIData";
import {initConfig} from "../../index";
import * as data from './datajson/data-compressed.json'

import {
    DATA_BODY,
    DATA_CAT_VARIANT,
    DATA_DNA,
    DATA_DOG_VARIANT,
    DATA_EYE,
    DATA_FROG_VARIANT,
    DATA_HEAD,
    DATA_HUMAN_VARIANT,
    DATA_MONKEY_VARIANT,
    DATA_MOUTH,
    DATA_ROBOT_VARIANT,
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

    //ADD Element
    const address = configaaa["dataContractAddress"];

    const ele = await dataContract.getItem(address, 0)
    console.log('ele', ele);

    const dna = await dataContract.getDNA(address, 0);
    console.log('dna', dna);

    for (const dna of DATA_DNA) {
        const getDNAVariant = await dataContract.getDNAVariant(address, 0, dna.key);
        console.log("getDNAVariant", getDNAVariant);
    }

}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});