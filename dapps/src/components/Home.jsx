import { useState } from 'react';
import ABI from '../../../Contract/artifacts/contracts/Cyanotype.sol/GenArt.json';
import Web3 from 'web3';
import { Button, Typography, Space, Col, Row, Card, Upload } from 'antd';
import config from '../../../Contract/config.json';
const { Meta } = Card;
const { Title } = Typography;

const contractAddress = config.contractAddress;

function Home() {
  const [loadings, setLoadings] = useState(false);
  const [walletBalance, setWalletBalance] = useState('');
  const [acc, setAcc] = useState();
  const [dataJsonArray, setDataJsonArray] = useState([]);
  const [tokenIdCurrent, setTokenIdCurrent] = useState();
  const gasPrice = '50000000000';

  var web3 = new Web3(window.ethereum);
  var contractABI = new web3.eth.Contract(ABI.abi, contractAddress);

  const connectWallet = async () => {
    await window.ethereum.enable();
    const account = await web3.eth.requestAccounts();
    setAcc(account);
    console.log('Wallet current: ', account[0]);
  };

  const mint = async () => {
    await contractABI.methods.mint(acc[0]).send({ from: acc[0], gasPrice });
    await contractABI
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
        console.log(events);
        let tokenID = events[0].returnValues.tokenId;
        const tokenIdConvert = Number(tokenID);
        console.log('tokenID', tokenIdConvert);
        setTokenIdCurrent(tokenIdConvert);
        setLoadings(false);
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

  const showArt = async () => {
    if (tokenIdCurrent == 0 || tokenIdCurrent) {
      const tokenURI = await contractABI.methods
        .tokenURI(tokenIdCurrent)
        .call();
      console.log(tokenURI);
      setDataJsonArray([...dataJsonArray, JSON.parse(atob(tokenURI))]);
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
      reader.onload = async e => {
        image = e.target.result;
        let obj = {
          name,
          image,
        };
        await contractABI.methods
          .addBackground(obj)
          .send({ from: acc[0], gasPrice });
      };
      reader.readAsText(info.file.originFileObj);
    }
  }

  async function getBackground() {
    await contractABI.methods
      .getBackground()
      .call()
      .then(result => {
        console.log(result);
      });
  }

  async function addFlower(info) {
    let name, image;
    if (info.file.status === 'done') {
      const reader = new FileReader();
      name = info.file.name;
      name = name.slice(0, name.lastIndexOf('.'));
      reader.onload = async e => {
        image = e.target.result;
        let obj = {
          name,
          image,
        };
        await contractABI.methods
          .addFlower(obj)
          .send({ from: acc[0], gasPrice });
      };
      reader.readAsText(info.file.originFileObj);
    }
  }

  async function getFlower() {
    await contractABI.methods
      .getFlower()
      .call()
      .then(result => {
        console.log(result);
      });
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
        </Space>
      </div>
      <div style={{ marginTop: '3%' }}>
        <Space size="middle">
          <Button size="large" type="primary" onClick={() => getBackground()}>
            Get Background
          </Button>
          <Button size="large" type="primary" onClick={() => getFlower()}>
            Get Flower
          </Button>
        </Space>
      </div>
      <Title level={4}>
        Your Balance: {walletBalance ? walletBalance : 0} TC
      </Title>
      <Space size="middle">
        <Button size="large" onClick={() => connectWallet()}>
          Connet wallet
        </Button>
        <Button size="large" onClick={() => getBalance()}>
          Show My Balance
        </Button>
        <Button size="large" onClick={() => showArt()}>
          show art tokenId {tokenIdCurrent}
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
