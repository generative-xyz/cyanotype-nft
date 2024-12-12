const fs = require('fs').promises;

type ConfigField = 'contractAddress' | 'dataContractAddress';
let config = {
    "contractAddress": "0xCf7Ed3AccA5a467e9e704C703E8D87F634fB0Fc9",
    "dataContractAddress": "0xe7f1725E7734CE288F8367e1Bb143E90bb3F0512"
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
