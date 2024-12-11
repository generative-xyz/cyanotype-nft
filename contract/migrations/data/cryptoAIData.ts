import {createAlchemyWeb3} from "@alch/alchemy-web3";
import * as path from "path";
import {DATA_INPUT, DATA_VARIANT} from "./data";

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

        console.log("senderPrivateKey", senderPrivateKey);
        console.log("senderPublicKey", senderPublicKey);
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
        await proxy.waitForDeployment();
        const proxyAddr = await proxy.getAddress();
        console.log("CryptoAIData deployed at proxy:", proxyAddr);
        return proxyAddr;
    }

    getContract(contractAddress: any, contractName: any = "./artifacts/contracts/data/CryptoAIData.sol/CryptoAIData.json") {
        console.log("Network run", this.network, hardhatConfig.networks[this.network].url);
        // if (this.network == "local") {
        //     console.log("not run local");
        //     return;
        // }
        let API_URL: any;
        API_URL = hardhatConfig.networks[hardhatConfig.defaultNetwork].url;

        // load contract
        let contract = require(path.resolve(contractName));
        const web3 = createAlchemyWeb3(API_URL)
        const nftContract = new web3.eth.Contract(contract.abi, contractAddress)
        return {web3, nftContract};
    }

    async signedAndSendTx(web3: any, tx: any) {
        const signedTx = await web3.eth.accounts.signTransaction(tx, this.senderPrivateKey)
        if (signedTx.rawTransaction != null) {
            let sentTx = await web3.eth.sendSignedTransaction(
                signedTx.rawTransaction,
                function (err: any, hash: any) {
                    if (!err) {
                        console.log(
                            "The hash of your transaction is: ",
                            hash,
                            "\nCheck Alchemy's Mempool to view the status of your transaction!"
                        )
                    } else {
                        console.log(
                            "Something went wrong when submitting your transaction:",
                            err
                        )
                    }
                }
            )
            return sentTx;
        }
        return null;
    }

    async addItem(contractAddress: any, gas: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce
        const fun = temp?.nftContract.methods.addItem(DATA_INPUT[0].key, DATA_INPUT[0].name, DATA_INPUT[0].rate, DATA_INPUT[0].position)
        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
            gas: gas,
            data: fun.encodeABI(),
        }

        if (tx.gas == 0) {
            tx.gas = await fun.estimateGas(tx);
        }

        return await this.signedAndSendTx(temp?.web3, tx);
    }

    async getDeployer(contractAddress: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods._deployer().call(tx);
        return val;
    }

    async getItem(contractAddress: any, index: number) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.getItem("mouth", index).call(tx);
        return val;
    }

    async addDNA(contractAddress: any, gas: any, dna: string) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce


        const fun = temp?.nftContract.methods.addDNA(dna)
        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
            gas: gas,
            data: fun.encodeABI(),
        }

        if (tx.gas == 0) {
            tx.gas = await fun.estimateGas(tx);
        }

        return await this.signedAndSendTx(temp?.web3, tx);
    }

    async getDNA(contractAddress: any, index: number) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.getDNA(index).call(tx);
        return val;
    }

    async addDNAVariant(contractAddress: any, gas: any) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce


        const fun = temp?.nftContract.methods.addDNAVariant(DATA_VARIANT[0].key, DATA_VARIANT[0].name, DATA_VARIANT[0].rate, DATA_VARIANT[0].position);
        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
            gas: gas,
            data: fun.encodeABI(),
        }

        if (tx.gas == 0) {
            tx.gas = await fun.estimateGas(tx);
        }

        return await this.signedAndSendTx(temp?.web3, tx);
    }

    async getDNAVariant(contractAddress: any, index: number) {
        let temp = this.getContract(contractAddress);
        const nonce = await temp?.web3.eth.getTransactionCount(this.senderPublicKey, "latest") //get latest nonce

        //the transaction
        const tx = {
            from: this.senderPublicKey,
            to: contractAddress,
            nonce: nonce,
        }

        const val: any = await temp?.nftContract.methods.getDNAVariant('monkey', index).call(tx);
        return val;
    }

}

export {CryptoAIData};