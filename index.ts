const fs = require('fs').promises;

type ConfigField = 'contractAddress' | 'dataContractAddress';
let config = {
    "contractAddress": "0xc3e53F4d16Ae77Db1c982e75a937B9f60FE63690",
    "dataContractAddress": "0xf5059a5D33d5853360D16C683c16e67980206f36"
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

export { initConfig, updateConfig };

