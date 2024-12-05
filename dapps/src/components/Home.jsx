import {useState} from 'react';
import ABI from '../../../Contract/artifacts/contracts/NFTs.sol/CharacterInfo.json';
// import ABI from '../contracts/ABI.json';
import Web3 from 'web3';
import {Button, Card, Col, Row, Space, Typography} from 'antd';
import config from '../../../Contract/config.json';
import {DATA_INPUT} from "./data";

const { Meta } = Card;
const { Title } = Typography;

const contractAddress = config.contractAddress;
// const contractAddress = '0x663E587e4988AF5798Fcb2eE13aDaBc5b39e8818';

function Home() {
  const [loadings, setLoadings] = useState(false);
  const [loadingArt, setLoadingArt] = useState(false);
  const [inputAddress, setInputAddress] = useState('');
  const [removeAddress, setRemoveAddress] = useState('');
  const [checkAddress, setCheckAddress] = useState('');
  const [walletBalance, setWalletBalance] = useState('');
  const [acc, setAcc] = useState('');
  const [dataJsonArray, setDataJsonArray] = useState([]);
  const [tokenIdCurrent, setTokenIdCurrent] = useState(0);
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
          .then(result => {
            var cutString = result.substring(29);
            console.log(cutString);
            setDataJsonArray([...dataJsonArray, JSON.parse(atob(cutString))]);
          })
          .catch(err => console.log(err));
      console.log(tokenURI);
      setLoadingArt(false);
    } else {
      console.log("Don't have tokenId");
    }
  };

  function base64ToJson(base64String) {
    const json = Buffer.from(base64String, 'base64').toString();
    return JSON.parse(json);
  }

  const getBalance = async () => {
    if (acc) {
      const balance = await web3.eth.getBalance(acc[0]);
      const balanceInEther = web3.utils.fromWei(balance, 'ether');
      setWalletBalance(balanceInEther);
    } else {
      console.log('No account');
    }
  };

  async function addColorsArray() {
    await contractABI.methods
        .addColorArray(DATA_INPUT.colors)
        .send({ from: acc[0], gasPrice }).then(result => {
          console.log('success', result);
        })
        .catch(err => {
          console.log(err);
        });
  }

  async function renderSVG() {
    await contractABI.methods
        .renderSVG('body', 0)
        .call().then(result => {
            // var cutString = result.substring(29);
            // console.log(cutString);
            console.log(JSON.parse(atob(result)));
        })
        .catch(err => {
          console.log(err);
        });
  }

  async function addItem() {

    await contractABI.methods
        .addItem('body','body01', 20, DATA_INPUT)
        .send({ from: acc[0], gasPrice }).then(result => {
          console.log('success', result);
        })
        .catch(err => {
          console.log(err);
        });
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
            <Button size="large" type="primary" onClick={addItem}>
              Add Item
            </Button>

              <Button size="large" type="primary" onClick={renderSVG}>
                  Render SVG
            </Button>
          </Space>
        </div>
        <Title level={4}>
          Your Balance: {walletBalance ? walletBalance : 0} USDT
        </Title>
        <Space size="middle">
          <Button size="large" onClick={() => connectWallet()}>
            Connect wallet
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
                    {key.attributes.map((item, index2) => {
                      return (
                          <p key={index2}>
                            <b>Trait-type:</b> {item.trait_type}
                            <br />
                            <b>Name:</b> {item.Name}
                            <br />
                            <b>Size:</b> {item.size}
                          </p>
                      );
                    })}
                  </Card>
                </Col>
            );
          })}
        </Row>
      </div>
  );
}

export default Home;
