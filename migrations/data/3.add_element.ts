import {CryptoAIData} from "./cryptoAIData";
import {initConfig} from "../../index";
import * as data from './datajson/data-compressed.json'
import {DATA_DNA, DNA, ELEMENT} from "./data";

async function main() {
    if (process.env.NETWORK != "local") {
        console.log("wrong network");
        return;
    }

    let configaaa = await initConfig();

    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);

    //ADD Element
    const address = configaaa["dataContractAddress"];

    await dataContract.addItem(address, 0,ELEMENT.MOUTH,  data.elements.Mouth.names,  data.elements.Mouth.traits,  data.elements.Mouth.positions);
    await dataContract.addItem(address, 0,ELEMENT.BODY,  data.elements.Body.names,  data.elements.Body.traits,  data.elements.Body.positions);
    await dataContract.addItem(address, 0,ELEMENT.EYE,  data.elements.Eyes.names,  data.elements.Eyes.traits,  data.elements.Eyes.positions);
    await dataContract.addItem(address, 0,ELEMENT.HEAD,  data.elements.Head.names,  data.elements.Head.traits,  data.elements.Head.positions);

    //ADD DNA
    for (const dna of DATA_DNA) {
        console.log('dna', dna)
        await dataContract.addDNA(address, 0, dna.key, Number(dna.trait));
    }

    //ADD DNA Variant
    await dataContract.addDNAVariant(address, 0, DNA.DOG, data.DNA.Dog.names, data.DNA.Dog.traits,  data.DNA.Dog.positions);
    await dataContract.addDNAVariant(address, 0, DNA.CAT, data.DNA.Cat.names, data.DNA.Cat.traits,  data.DNA.Cat.positions);
    await dataContract.addDNAVariant(address, 0, DNA.FROG, data.DNA.Frog.names, data.DNA.Frog.traits,  data.DNA.Frog.positions);
    await dataContract.addDNAVariant(address, 0, DNA.ROBOT, data.DNA.Robot.names, data.DNA.Robot.traits,  data.DNA.Robot.positions);
    await dataContract.addDNAVariant(address, 0, DNA.HUMAN, data.DNA.Human.names, data.DNA.Human.traits,  data.DNA.Human.positions);
    await dataContract.addDNAVariant(address, 0, DNA.MONKEY, data.DNA.Monkey.names, data.DNA.Monkey.traits,  data.DNA.Monkey.positions);



}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});