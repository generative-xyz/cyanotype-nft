const fs = require('fs').promises;

var config;

async function initConfig() {
  config = JSON.parse((await fs.readFile('./config.json')).toString());
  return config;
}

function getConfig() {
  return config;
}

async function updateConfig(contractAddress) {
  config.contractAddress = `${contractAddress}`;
  return fs.writeFile('./config.json', JSON.stringify(config, null, 2));
}

module.exports = {
  initConfig,
  getConfig,
  updateConfig,
};
