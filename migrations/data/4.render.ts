import {initConfig} from "../../index";
import {CryptoAIData} from "./cryptoAIData";
import {promises as fs} from "fs";

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
    let images = "";
    for (var i = 1; i < 5; i++) {
        const fullSVG = await dataContract.cryptoAIImageSvg(address, 4);
        images += "<img width=\"256\" src=\"" + fullSVG + "\"/>"
        console.log(i, "fullSVG", fullSVG);
    }
    await fs.writeFile('../../testimage.html', images);

    // const attr = await dataContract.getAttrData(address, 4);
    // console.log("fullSVG", attr);

    //Render Attributes
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});