import {initConfig} from "../../index";
import {CryptoAIData} from "./cryptoAIData";

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
    const img = await dataContract.cryptoAIImage(address, parseInt(args[0]));
    console.log("img", img)
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});

