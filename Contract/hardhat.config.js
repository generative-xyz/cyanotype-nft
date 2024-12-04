// require('@nomicfoundation/hardhat-toolbox');

// /** @type import('hardhat/config').HardhatUserConfig */
// module.exports = {
//   networks: {
//     // hardhat: {
//     //   allowUnlimitedContractSize: true,
//     // },
//     nos: {
//       url: 'https://tc-node-manual.regtest.trustless.computer/',
//       // chainId: 22215,
//       accounts: [
//         '8166f546bab6da521a8369cab06c5d2b9e46670292d85c875ee9ec20e84ffb61',
//       ],
//     },
//   },
//   solidity: '0.8.18',
//   settings: {
//     optimizer: {
//       enabled: true,
//       runs: 200,
//     },
//   },
//   paths: {
//     sources: './contracts',
//     tests: './test',
//     cache: './cache',
//     artifacts: './artifacts',
//   },
// };

require('@nomicfoundation/hardhat-toolbox');
require('dotenv').config();
module.exports = {
  solidity: '0.8.9',
  networks: {
    polygon: {
      url: 'https://polygon-mainnet.infura.io',
      accounts: [`${process.env.PRIVATE_KEY}`],
      chainId: 137,
    },
    testChain: {
      url: 'http://127.0.0.1:8545/',
      accounts: [`0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80`],
      chainId: 31337,
    },
    hardhat: {
      allowUnlimitedContractSize: true,
    },
  },
  settings: {
    optimizer: {
      enabled: true,
      runs: 1,
    },
    "viaIR": true,
  },
  contractSizer: {
    alphaSort: true,
    disambiguatePaths: false,
    runOnCompile: true,
    strict: true,
    only: [':ERC20$'],
  },
  paths: {
    sources: './contracts',
    tests: './test',
    cache: './cache',
    artifacts: './artifacts',
  },
};
