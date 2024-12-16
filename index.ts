const fs = require('fs').promises;

type ConfigField = 'contractAddress' | 'dataContractAddress';
let config = {
    "contractAddress": "0xc3e53F4d16Ae77Db1c982e75a937B9f60FE63690",
    "dataContractAddress": "0x0E801D84Fa97b50751Dbf25036d067dCf18858bF"
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

