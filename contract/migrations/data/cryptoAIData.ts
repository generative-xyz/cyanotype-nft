import {createAlchemyWeb3} from "@alch/alchemy-web3";
import * as path from "path";
import {Bytes32Ty} from "hardhat/internal/hardhat-network/stack-traces/logger";
import {ethers as eth1} from "ethers";

const {ethers, upgrades} = require("hardhat");
const hardhatConfig = require("../../hardhat.config");

class CryptoAIData {
    network: string;
    senderPublicKey: string;
    senderPrivateKey: string;

    constructor(network: any, senderPrivateKey: any, senderPublicKey: any) {
        this.network = network;
        this.senderPrivateKey = senderPrivateKey;
        this.senderPublicKey = senderPublicKey;
    }

    async deployUpgradeable(adminAddr: any,
                            deployerAddr: any
    ) {
        // if (this.network == "local") {
        //     console.log("not run local");
        //     return;
        // }

        const contract = await ethers.getContractFactory("CryptoAIData");
        console.log("CryptoAIData.deploying ...")
        const proxy = await upgrades.deployProxy(contract, [adminAddr, deployerAddr], {
            initializer: 'initialize(address, address)',
        });
        await proxy.deployed();
        console.log("CryptoAIData deployed at proxy:", proxy.address);
        return proxy.address;
    }
}

export {CryptoAIData};