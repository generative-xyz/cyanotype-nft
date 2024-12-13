import {initConfig} from "../../index";
import {CryptoAIData} from "./cryptoAIData";

async function main() {
    if (process.env.NETWORK != "local") {
        console.log("wrong network");
        return;
    }

    let config = await initConfig();

    const dataContract = new CryptoAIData(process.env.NETWORK, process.env.PRIVATE_KEY, process.env.PUBLIC_KEY);
    await dataContract.changePlaceHolder(config.dataContractAddress, 0, "<script>alert(TokenID)</script>");
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});