const fs = require('fs').promises;

type ConfigField = 'contractAddress' | 'dataContractAddress';
let config = {
    contractAddress: '0x8A791620dd6260079BF849Dc5567aDC3F2FdC318',
    dataContractAddress: '0x2279B7A0a67DB372996a5FaB50D91eAA73d2eBe6'
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
