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
    const args = process.argv.slice(2);
    if (args.length == 0) {
        console.log("missing number")
        return;
    }
    let images = "";
    const num = parseInt(args[0]);
    for (var i = 1; i <= num; i++) {
        const fullSVG = await dataContract.cryptoAIImageSvg(address, i);
        images += "<img width=\"256\" src=\"" + fullSVG + "\"/>"
        // console.log(i, "fullSVG", fullSVG);
    }
    console.log("images", images);
    await fs.writeFile('./migrations/testimage.html', images);

    // const attr = await dataContract.getAttrData(address, 4);
    // console.log("fullSVG", attr);

    //Render Attributes
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});