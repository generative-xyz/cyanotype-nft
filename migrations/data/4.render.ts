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
    // const args = process.argv.slice(2);
    // if (args.length == 0) {
    //     console.log("missing number")
    //     return;
    // }
    // let images = "";
    // const num = parseInt(args[0]);
    // for (var i = 1; i <= num; i++) {
    //     try {
    //         const fullSVG = await dataContract.cryptoAIImageSvg(address, i);
    //         images += "<img width=\"64\" src=\"" + fullSVG + "\" title='" + i + "' />"
    //         console.log(i, " processed");
    //     } catch (ex) {
    //         console.log(i, " failed");
    //     }
    // }
    // const path = "./migrations/testimage.html";
    // console.log("path", path);
    // await fs.writeFile(path, images);

    // const fullSVG = await dataContract.cryptoAIImageSvg(address, 4);
    // console.log("fullSVG", fullSVG);
    const attr = await dataContract.getAttrData(address, 4);
    console.log("fullSVG", attr);

    //Render Attributes
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});

