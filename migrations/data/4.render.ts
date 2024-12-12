import { initConfig } from "../../index";
import { CryptoAIData } from "./cryptoAIData";

async function main() {
    if (process.env.NETWORK != "local") {
        console.log("wrong network");
        return;
    }

    let config = await initConfig();
    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    //ADD Element
    const address = config["dataContractAddress"];

    // Render SVG
    const fullSVG = await dataContract.cryptoAIImageSvg(address, 4);
    console.log("fullSVG", fullSVG);

    // const attr = await dataContract.getAttrData(address, 4);
    // console.log("fullSVG", attr);

    //Render Attributes
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});