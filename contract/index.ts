const fs = require('fs').promises;

var config;

async function initConfig() {
    config = JSON.parse((await fs.readFile('./config.json')).toString());
    return config;
}

async function updateConfig(key: string | number, value: any) {
    config[key] = value;
    return fs.writeFile('./config.json', JSON.stringify(config, null, 2));
}

export {initConfig, updateConfig}
