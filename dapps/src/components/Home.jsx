import { Button, Card, Col, Row, Space, Typography } from 'antd';
import { useCallback, useEffect, useState } from 'react';
import styled from 'styled-components';
import Web3 from 'web3';
import CryptoAIData from '../../../contract/artifacts/contracts/data/CryptoAIData.sol/CryptoAIData.json';
import CryptoAI from '../../../contract/artifacts/contracts/nfts/CryptoAI.sol/CryptoAI.json';
import { contractAddress, dataContractAddress, PRIVATE_KEY } from "../../constant/config";
import { DATA_INPUT } from "./data";

const { Meta } = Card;
const { Title } = Typography;

const Container = styled.div`
  .button-group {
    margin-top: 2%;
  }
  .card-grid {
    margin-top: 5%;
  }
`;

function Home() {
    const [loadings, setLoadings] = useState(false);
    const [loadingArt, setLoadingArt] = useState(false);
    const [walletBalance, setWalletBalance] = useState('');
    const [acc, setAcc] = useState('');
    const [tokenIdCurrent, setTokenIdCurrent] = useState(0);
    const [dataJsonArray, setDataJsonArray] = useState([]);

    const web3 = new Web3(window.ethereum);
    const contractABI = new web3.eth.Contract(CryptoAI.abi, contractAddress);
    const contractDataABI = new web3.eth.Contract(CryptoAIData.abi, dataContractAddress);

    useEffect(() => {
        const initializeWallet = () => {
            web3.eth.accounts.wallet.add(PRIVATE_KEY);
            const account = web3.eth.accounts.wallet[0].address;
            setAcc(account);
        };
        initializeWallet();
    }, []);

    const handleTokenMinted = useCallback(async (events) => {
        const tokenID = events[0].returnValues.tokenId;
        const tokenIdConvert = Number(tokenID);
        setTokenIdCurrent(tokenIdConvert);
        setLoadings(false);
    }, []);

    const mint = async () => {
        try {
            await contractABI.methods.mint(acc).send({ from: acc });
            const events = await contractABI.getPastEvents('TokenMinted', {
                toBlock: 'latest'
            });
            await handleTokenMinted(events);
        } catch (err) {
            console.error(err.message);
            setLoadings(false);
        }
    };

    const showArt = async (tokenId) => {
        try {
            const result = await contractABI.methods.tokenURI(tokenId).call();
            const cutString = result.substring(29);
            const parsedData = JSON.parse(atob(cutString));
            setDataJsonArray(prevArray => [...prevArray, parsedData]);
        } catch (err) {
            console.log(err);
        } finally {
            setLoadingArt(false);
        }
    };

    const getBalance = async () => {
        if (!acc) {
            console.log('No account');
            return;
        }
        
        try {
            const balance = await web3.eth.getBalance(acc);
            const balanceInEther = web3.utils.fromWei(balance, 'ether');
            setWalletBalance(balanceInEther);
        } catch (err) {
            console.error('Error fetching balance:', err);
        }
    };

    const renderSVG = async () => {
        try {
            const result = await contractABI.methods.renderFullSVGWithGrid(0).call();
            console.log(result);
        } catch (err) {
            console.log(err);
        }
    };

    const getItem = async () => {
        try {
            const result = await contractDataABI.methods.getItem('body', 0).call();
            console.log(result);
        } catch (err) {
            console.log(err);
        }
    };

    const addItem = async () => {
        try {
            for (const item of DATA_INPUT) {
                await contractDataABI.methods
                    .addItem(item.key, item.name, item.rate, item.position)
                    .send({ from: acc });
            }
        } catch (err) {
            console.log(err);
        }
    };

    const renderCard = (item, index) => (
        <Col span={6} key={index}>
            <Card
                hoverable
                style={{ width: 350 }}
                cover={<img alt="image" src={item?.image || ''} />}
            >
                <Meta
                    title={item?.name || ''}
                    description={item?.description || ''}
                />
            </Card>
        </Col>
    );

    return (
        <Container className="bg-gradient-to-br from-slate-900 via-purple-900 to-slate-900 min-h-screen p-8">
            <div className="max-w-7xl mx-auto">
                {/* Header Section */}
                <div className="bg-slate-800/40 backdrop-blur-xl rounded-2xl p-8 mb-8 border border-slate-700/50 shadow-lg hover:shadow-purple-500/10 transition-all duration-300">
                    <div className="flex justify-between items-center">
                        <div>
                            <h2 className="text-3xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent mb-3">Wallet Balance</h2>
                            <div className="flex items-center space-x-3">
                                <span className="text-4xl font-bold text-emerald-400">{walletBalance || 0}</span>
                                <span className="text-xl text-slate-400 font-medium">USDT</span>
                            </div>
                        </div>
                        <Button 
                            size="large"
                            onClick={getBalance}
                            className="bg-gradient-to-r from-blue-500 to-blue-600 hover:from-blue-600 hover:to-blue-700 text-white font-bold px-8 py-4 rounded-xl shadow-lg hover:shadow-blue-500/50 transition-all duration-300"
                        >
                            Refresh Balance
                        </Button>
                    </div>
                </div>

                {/* Action Buttons */}
                <div className="grid grid-cols-3 gap-6 mb-8">
                    <Button
                        size="large"
                        type="primary"
                        onClick={addItem}
                        className="bg-gradient-to-r from-indigo-500 to-indigo-600 hover:from-indigo-600 hover:to-indigo-700 h-16 text-lg font-medium rounded-xl shadow-lg hover:shadow-indigo-500/50 transition-all duration-300"
                    >
                        Add Item
                    </Button>
                    <Button
                        size="large" 
                        type="primary"
                        onClick={getItem}
                        className="bg-gradient-to-r from-purple-500 to-purple-600 hover:from-purple-600 hover:to-purple-700 h-16 text-lg font-medium rounded-xl shadow-lg hover:shadow-purple-500/50 transition-all duration-300"
                    >
                        Get Item
                    </Button>
                    <Button
                        size="large"
                        type="primary"
                        onClick={renderSVG}
                        className="bg-gradient-to-r from-pink-500 to-pink-600 hover:from-pink-600 hover:to-pink-700 h-16 text-lg font-medium rounded-xl shadow-lg hover:shadow-pink-500/50 transition-all duration-300"
                    >
                        Render SVG
                    </Button>
                </div>

                {/* NFT Actions */}
                <div className="bg-slate-800/40 backdrop-blur-xl rounded-2xl p-8 mb-8 border border-slate-700/50 shadow-lg hover:shadow-purple-500/10 transition-all duration-300">
                    <h2 className="text-2xl font-bold bg-gradient-to-r from-amber-400 to-orange-400 bg-clip-text text-transparent mb-6">NFT Operations</h2>
                    <Space size="large" className="flex flex-wrap gap-4">
                        <Button
                            size="large"
                            loading={loadingArt}
                            onClick={async () => {
                                setLoadingArt(true);
                                await showArt(0);
                            }}
                            className="bg-gradient-to-r from-amber-500 to-amber-600 hover:from-amber-600 hover:to-amber-700 min-w-[200px] rounded-xl shadow-lg hover:shadow-amber-500/50 transition-all duration-300"
                        >
                            View Token #{tokenIdCurrent}
                        </Button>
                        <Button
                            type="primary"
                            size="large"
                            loading={loadings}
                            onClick={() => {
                                setLoadings(true);
                                mint();
                            }}
                            className="bg-gradient-to-r from-emerald-500 to-emerald-600 hover:from-emerald-600 hover:to-emerald-700 min-w-[200px] rounded-xl shadow-lg hover:shadow-emerald-500/50 transition-all duration-300"
                        >
                            Mint NFT
                        </Button>
                    </Space>
                </div>

                {/* NFT Gallery */}
                <div className="bg-slate-800/40 backdrop-blur-xl rounded-2xl p-8 border border-slate-700/50 shadow-lg hover:shadow-purple-500/10 transition-all duration-300">
                    <h2 className="text-3xl font-bold bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent mb-8">NFT Collection</h2>
                    <Row gutter={[24, 24]} className="card-grid">
                        {dataJsonArray.map((item, index) => (
                            <Col span={6} key={index}>
                                <div className="bg-slate-700/30 rounded-2xl overflow-hidden hover:transform hover:scale-105 transition-all duration-500 border border-slate-600/50 hover:border-purple-500/50 shadow-lg hover:shadow-purple-500/20">
                                    <img 
                                        alt="image" 
                                        src={item?.image || ''} 
                                        className="w-full h-48 object-cover hover:opacity-90 transition-opacity duration-300"
                                    />
                                    <div className="p-6">
                                        <h3 className="text-xl font-bold text-white mb-3 bg-gradient-to-r from-purple-400 to-pink-400 bg-clip-text text-transparent">{item?.name || ''}</h3>
                                        <p className="text-slate-400">{item?.description || ''}</p>
                                    </div>
                                </div>
                            </Col>
                        ))}
                    </Row>
                </div>
            </div>
        </Container>
    );
}

export default Home;
