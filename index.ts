const fs = require('fs').promises;

type ConfigField = 'contractAddress' | 'dataContractAddress';
let config = {
    "contractAddress": "0xa513E6E4b8f2a923D98304ec87F64353C4D5C853",
    "dataContractAddress": "0x0165878A594ca255338adfa4d48449f69242Eb8F"
};

async function initConfig() {
    config = JSON.parse((await fs.readFile('./config.json')).toString());
    console.log("initConfig", config)
    return config;
}

async function updateConfig(key: ConfigField, value: string) {
    if (key in config) {
        config[key] = value;
        console.log("config ------ ", config);
        return fs.writeFile('./config.json', JSON.stringify(config, null, 2));
    }
}

export {initConfig, updateConfig}
