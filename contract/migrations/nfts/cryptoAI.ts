const {ethers, upgrades} = require("hardhat");
const hardhatConfig = require("../../hardhat.config");

class CryptoAI {
    network: string;
    senderPublicKey: string;
    senderPrivateKey: string;

    constructor(network: any, senderPrivateKey: any, senderPublicKey: any) {
        this.network = network;
        this.senderPrivateKey = senderPrivateKey;
        this.senderPublicKey = senderPublicKey;

        console.log("senderPrivateKey", senderPrivateKey);
        console.log("senderPublicKey", senderPublicKey);
    }

    async deployUpgradeable(name: string, symbol: string,
                            adminAddr: any,
                            deployerAddr: any,
                            paramsAddress: any,
                            random: any,
                            cryptoAiData: any,
    ) {
        // if (this.network == "local") {
        //     console.log("not run local");
        //     return;
        // }

        const contract = await ethers.getContractFactory("CryptoAI");
        console.log("CryptoAIData.deploying ...")
        const proxy = await upgrades.deployProxy(contract, [adminAddr, deployerAddr], {
            initializer: 'initialize(address, address)',
        });
        await proxy.waitForDeployment();
        const proxyAddr = await proxy.getAddress();
        console.log("CryptoAIData deployed at proxy:", proxyAddr);
        return proxyAddr;
    }
}

export {CryptoAI};