import { promises as fs } from "fs";
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
    const args = process.argv.slice(2);
    if (args.length == 0) {
        console.log("missing number")
        return;
    }
    let images = "";
    const num = parseInt(args[0]);
    
    const attrsChecked = [];
    const attrsDuplicated = [];

    for (var i = 1; i <= num; i++) {
        try {
           
            console.log(i, " checked");
            const attr = await dataContract.getAttrData(address, i);
            const attrStr = JSON.stringify(attr);
            
            if (attrsChecked.includes(attrStr)) {
                const duplicateIndex = attrsChecked.indexOf(attrStr);
                const duplicateId = duplicateIndex + 1;
                attrsDuplicated.push({
                    id: i,
                    attr,
                    duplicateOf: {
                        id: duplicateId,
                        attr: JSON.parse(attrsChecked[duplicateIndex])
                    }
                });
                console.log(`Found duplicate attr for ID ${i}:`, attr);
                console.log(`Duplicate of ID ${duplicateId}:`, JSON.parse(attrsChecked[duplicateIndex]));
            }
            attrsChecked.push(attrStr);
        } catch (ex) {
            console.log(i, " failed");
            break;
        }
    }
    const path = "./migrations/duplicates.json";
    console.log("path", path);
    console.log("Total items checked:", attrsChecked.length);
    console.log("Total duplicates found:", attrsDuplicated.length);
    await fs.writeFile(path, JSON.stringify(attrsDuplicated, null, 2));
}

main().catch(error => {
    console.error(error);
    process.exitCode = 1;
});

