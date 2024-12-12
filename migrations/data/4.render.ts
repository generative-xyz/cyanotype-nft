import {CryptoAIData} from "./cryptoAIData";
import {initConfig} from "../../index";

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
    const fullSVG = await dataContract.renderFullSVGWithGrid(address, 2);
    console.log("fullSVG", fullSVG);
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});