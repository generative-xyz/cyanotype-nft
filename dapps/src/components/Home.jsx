import {useEffect, useState} from 'react';
import ABI from '../../../Contract/artifacts/contracts/Cyanotype.sol/GenArt.json';
import Web3 from 'web3';
import { Button, Typography, Space, Col, Row, Card, Upload, Input } from 'antd';
import { useSDK } from "@metamask/sdk-react";
import config from '../../../Contract/config.json';

const { Meta } = Card;
const { Title } = Typography;

const contractAddress = config.contractAddress;

function Home() {
  const [loadings, setLoadings] = useState(false);
  const [loadingArt, setLoadingArt] = useState(false);
  const [inputAddress, setInputAddress] = useState('');
  const [removeAddress, setRemoveAddress] = useState('');
  const [checkAddress, setCheckAddress] = useState('');
  const [walletBalance, setWalletBalance] = useState('');
  const [acc, setAcc] = useState();
  const [dataJsonArray, setDataJsonArray] = useState([]);
  const [tokenIdCurrent, setTokenIdCurrent] = useState(0);
  const gasPrice = '50000000000';


  var web3 = new Web3(window.ethereum);
  var contractABI = new web3.eth.Contract(ABI.abi, contractAddress);


  const connectWallet = async () => {
    await window.ethereum.enable();
    const account = await web3.eth.requestAccounts();
    console.log('account', account)
    setAcc(account);
    console.log('Wallet current: ', account[0]);
  };

  // Attempt to connect to MetaMask
  useEffect(() => {
    const connectWallet = async () => {

      // setIsConnecting(true);
      try {
        // await window.ethereum.enable();
        const account = await web3.eth.requestAccounts();
        console.log('account', account)
        setAcc(account);
        console.log('Wallet current: ', account[0]);
      } catch (error) {
        console.error("Failed to connect to MetaMask:", error);
        // Handle errors here
      } finally {
        // setIsConnecting(false);
      }
    };

    connectWallet();
  }, []);




  const mint = async () => {
    await contractABI.methods
        .mint(acc[0])
        .send({
          from: acc[0],
          gasPrice,
        })
        .then(() => {
          contractABI
              .getPastEvents(
                  'TokenMinted',
                  {
                    // fromBlock: 0,
                    toBlock: 'latest',
                  },
                  function (error, events) {
                    console.log(events);
                  }
              )
              .then(async function (events) {
                let tokenID = events[0].returnValues.tokenId;
                const tokenIdConvert = Number(tokenID);
                setTokenIdCurrent(tokenIdConvert);
                setLoadings(false);
              });
        })
        .catch(err => {
          console.error(err.message);
        });

    // if (result) {
    //   console.log('tokenIdConvert', tokenIdConvert);
    //   setLoadings(false);
    //   const tokenURI = await contractABI.methods
    //     .tokenURI(tokenIdConvert)
    //     .call();
    //   setDataJsonArray([...dataJsonArray, JSON.parse(atob(tokenURI))]);
    // }
  };

  async function addAdressMint(add) {
    await contractABI.methods.addAdressMint(add).send({
      from: acc[0],
      gasPrice,
    });
    setInputAddress('');
  }

  async function removeAdressMint(add) {
    await contractABI.methods.removeAdressMint(add).send({
      from: acc[0],
      gasPrice,
    });
    setRemoveAddress('');
  }

  async function checkAdressMint(add) {
    await contractABI.methods
        .checkPermissionAddress(add)
        .call()
        .then(result => console.log(result));
    setCheckAddress('');
  }

  function cutString(str) {
    const getName = str.match(/[a-zA-Z]+/g).join('');
    const getRate = str.match(/\d+/g).join('');
    return { getName, getRate };
  }

  const showArt = async () => {
    if (tokenIdCurrent == 0 || tokenIdCurrent) {
      const tokenURI = await contractABI.methods
          .tokenURI(tokenIdCurrent)
          .call()
          .then(result => console.log(result))
          .catch(err => console.log(err));
      // setDataJsonArray([...dataJsonArray, JSON.parse(atob(tokenURI))]);
      setLoadingArt(false);
    } else {
      console.log("Don't have tokenId");
    }
  };

  const getBalance = async () => {
    if (acc) {
      const balance = await web3.eth.getBalance(acc[0]);
      const balanceInEther = web3.utils.fromWei(balance, 'ether');
      setWalletBalance(balanceInEther);
    } else {
      console.log('No account');
    }
  };

  async function addBackground(info) {
    let name, image;
    if (info.file.status === 'done') {
      const reader = new FileReader();
      name = info.file.name;
      name = name.slice(0, name.lastIndexOf('.'));
      let formatString = cutString(name);
      reader.onload = async e => {
        image = e.target.result;
        let obj = {
          name: formatString.getName,
          image,
          ele_type: 'Background',
          rate: formatString.getRate,
        };
        await contractABI.methods
            .addElements(obj)
            .send({ from: acc[0], gasPrice });
      };
      reader.readAsText(info.file.originFileObj);
    }
  }

  async function addFlower(info) {
    let name, image;
    if (info.file.status === 'done') {
      const reader = new FileReader();
      name = info.file.name;
      name = name.slice(0, name.lastIndexOf('.'));
      let formatString = cutString(name);
      reader.onload = async e => {
        image = e.target.result;
        let obj = {
          name: formatString.getName,
          image,
          ele_type: 'Flower',
          rate: formatString.getRate,
        };
        await contractABI.methods
            .addElements(obj)
            .send({ from: acc[0], gasPrice });
      };
      reader.readAsText(info.file.originFileObj);
    }
  }

  async function addLeaf(info) {
    let name, image;
    if (info.file.status === 'done') {
      const reader = new FileReader();
      name = info.file.name;
      name = name.slice(0, name.lastIndexOf('.'));
      let formatString = cutString(name);
      reader.onload = async e => {
        image = e.target.result;
        let obj = {
          name: formatString.getName,
          image,
          ele_type: 'Leaf',
          rate: formatString.getRate,
        };
        await contractABI.methods
            .addElements(obj)
            .send({ from: acc[0], gasPrice });
      };
      reader.readAsText(info.file.originFileObj);
    }
  }

  async function addInsect(info) {
    let name, image;
    if (info.file.status === 'done') {
      const reader = new FileReader();
      name = info.file.name;
      name = name.slice(0, name.lastIndexOf('.'));
      let formatString = cutString(name);
      reader.onload = async e => {
        image = e.target.result;
        let obj = {
          name: formatString.getName,
          image,
          ele_type: 'Insect',
          rate: formatString.getRate,
        };
        await contractABI.methods
            .addElements(obj)
            .send({ from: acc[0], gasPrice });
      };
      reader.readAsText(info.file.originFileObj);
    }
  }

  return (
      <div>
        <div className="">
          <Space size="middle">
            <Upload onChange={addBackground}>
              <Button size="large" type="primary">
                Add Background
              </Button>
            </Upload>
            <Upload onChange={addFlower}>
              <Button size="large" type="primary">
                Add Flower
              </Button>
            </Upload>
            <Upload onChange={addLeaf}>
              <Button size="large" type="primary">
                Add Leaf
              </Button>
            </Upload>
            <Upload onChange={addInsect}>
              <Button size="large" type="primary">
                Add Insect
              </Button>
            </Upload>
          </Space>
        </div>
        <div style={{ marginTop: '3%' }}>
          <Space.Compact style={{ width: '50%' }}>
            <Input
                size="large"
                placeholder="Input address"
                value={inputAddress}
                onChange={e => setInputAddress(e.target.value)}
            />
            <Button
                size="large"
                type="primary"
                onClick={() => addAdressMint(inputAddress)}
            >
              Add address
            </Button>
          </Space.Compact>
        </div>
        <div style={{ marginTop: '3%' }}>
          <Space.Compact style={{ width: '50%' }}>
            <Input
                size="large"
                value={removeAddress}
                placeholder="Remove address"
                onChange={e => setRemoveAddress(e.target.value)}
            />
            <Button
                size="large"
                type="primary"
                onClick={() => removeAdressMint(removeAddress)}
            >
              Remove address
            </Button>
          </Space.Compact>
        </div>
        <div style={{ marginTop: '3%' }}>
          <Space.Compact style={{ width: '50%' }}>
            <Input
                size="large"
                value={checkAddress}
                placeholder="Check address have permission mint"
                onChange={e => setCheckAddress(e.target.value)}
            />
            <Button
                size="large"
                type="primary"
                onClick={() => checkAdressMint(checkAddress)}
            >
              Check address
            </Button>
          </Space.Compact>
        </div>
        <Title level={4}>
          Your Balance: {walletBalance ? walletBalance : 0} TC
        </Title>
        <Space size="middle">
          <Button size="large" onClick={() => connectV2()}>
            Connet wallet
          </Button>
          <Button size="large" onClick={() => getBalance()}>
            Show My Balance
          </Button>
        </Space>
        <div style={{ marginTop: '2%' }}>
          <Space size="middle">
            <Button
                size="large"
                loading={loadingArt}
                onClick={() => {
                  setLoadingArt(true);
                  showArt();
                }}
            >
              TokenURI({tokenIdCurrent})
            </Button>
            <Button
                type="primary"
                size="large"
                loading={loadings}
                onClick={() => {
                  setLoadings(true);
                  mint();
                }}
            >
              Mint
            </Button>
          </Space>
        </div>
        <Row gutter={16} style={{ marginTop: '5%' }}>
          {dataJsonArray.map((key, index) => {
            return (
                <Col span={6} key={index}>
                  <Card
                      hoverable
                      style={{ width: 350 }}
                      cover={<img alt="image" src={key ? key.image : ''} />}
                  >
                    <Meta
                        title={key ? key.name : ''}
                        description={key ? key.description : ''}
                    />
                  </Card>
                </Col>
            );
          })}
        </Row>
      </div>
  );
}

export default Home;