const fs = require('fs').promises;

let config: any;

async function initConfig() {
    config = JSON.parse((await fs.readFile('./config.json')).toString());
    console.log("initConfig", config)
    return config;
}

async function updateConfig(key: string | number, value: any) {
    config[key] = value;
    console.log("config ------ ", config);
    return fs.writeFile('./config.json', JSON.stringify(config, null, 2));
}

export {initConfig, updateConfig}
