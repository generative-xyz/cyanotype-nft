import {useEffect, useState} from 'react';
import ABI from '../../../Contract/artifacts/contracts/NFTs.sol/CharacterInfo.json';
import Web3 from 'web3';
import {Button, Card, Col, Row, Space, Typography} from 'antd';
import {DATA_INPUT} from "./data";
import {contractAddress, PRIVATE_KEY} from "../../constant/config";

const { Meta } = Card;
const { Title } = Typography;


function Home() {
  const [loadings, setLoadings] = useState(false);
  const [loadingArt, setLoadingArt] = useState(false);
  const [walletBalance, setWalletBalance] = useState('');
  const [acc, setAcc] = useState('');
  const [tokenIdCurrent, setTokenIdCurrent] = useState(0);
  const [dataJsonArray, setDataJsonArray] = useState([]);

  var web3 = new Web3(window.ethereum);
  var contractABI = new web3.eth.Contract(ABI.abi, contractAddress);

    useEffect(() => {
        web3.eth.accounts.wallet.add(PRIVATE_KEY)
        const account = web3.eth.accounts.wallet[0].address
        setAcc(account)
    }, []);

  const mint = async () => {
    await contractABI.methods
        .mint(acc)
        .send({
          from: acc,
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
  };



  const showArt = async (tokenIdCurrent) => {
/*    if (tokenIdCurrent == 0 || tokenIdCurrent) {
      const tokenURI = await contractABI.methods
          .tokenURI(tokenIdCurrent)
          .call()
          .then(result => {
            var cutString = result.substring(29);
              console.log(cutString)
            console.log(JSON.parse(atob(cutString)));
            setDataJsonArray([...dataJsonArray, JSON.parse(atob(cutString))]);
          })
          .catch(err => console.log(err));
      setLoadingArt(false);
    } else {
      console.log("Don't have tokenId");
    }*/

      await contractABI.methods
          .tokenURI(tokenIdCurrent)
          .call()
          .then(result => {
              // var cutString = result.substring(29);
              console.log(result)
              // console.log(JSON.parse(atob(cutString)));
              // setDataJsonArray([...dataJsonArray, JSON.parse(atob(cutString))]);
          })
          .catch(err => console.log(err));
      setLoadingArt(false);
  };

  const getBalance = async () => {
    if (acc) {
      const balance = await web3.eth.getBalance(acc);
      const balanceInEther = web3.utils.fromWei(balance, 'ether');
      setWalletBalance(balanceInEther);
    } else {
      console.log('No account');
    }
  };

  async function renderSVG() {
    await contractABI.methods
        .renderFullSVGWithGrid(0)
        .call().then(result => {
            // var cutString = result.substring(0);
            console.log(result);
            // console.log(JSON.parse(atob(cutString)));
        })
        .catch(err => {
          console.log(err);
        });
  }

    async function getItem() {
        await contractABI.methods
            .getItem('body', 0)
            .call().then(result => {
                // var cutString = result.substring(0);
                console.log(result);
                // console.log(JSON.parse(atob(cutString)));
            })
            .catch(err => {
                console.log(err);
            });
    }

  async function addItem() {
      /*await web3.eth.accounts.signTransaction({
          from: acc,
          gasPrice: "20000000000",
          gas: "21000",
          value: "1000000000000000000",
            gasLimit: "53000",
      }, PRIVATE_KEY).then(async () => {

      });*/

      for (let i = 0; i < DATA_INPUT.length; i++) {
          await contractABI.methods
              .addItem(DATA_INPUT[i].key,  DATA_INPUT[i].name,  DATA_INPUT[i].rate, DATA_INPUT[i].position)
              .send({ from: acc }).then(result => {
                  console.log('success', result);
              })
              .catch(err => {
                  console.log(err);
              });
      }

  }

  return (
      <div>
        <div className="">
          <Space size="middle">
            <Button size="large" type="primary" onClick={addItem}>
              Add Item
            </Button>
              <Button size="large" type="primary" onClick={getItem}>
              Get Item
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
          <Button size="large" onClick={() => getBalance()}>
            Show My Balance
          </Button>
        </Space>
        <div style={{ marginTop: '2%' }}>
          <Space size="middle">
            <Button
                size="large"
                loading={loadingArt}
                onClick={async () => {
                  setLoadingArt(true);
                  await showArt(0);
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
                    {/*{key.attributes.map((item, index2) => {*/}
                    {/*  return (*/}
                    {/*      <p key={index2}>*/}
                    {/*        <b>Name:</b> {item.Name}*/}
                    {/*        <br />*/}
                    {/*        <b>Size:</b> {item.size}*/}
                    {/*      </p>*/}
                    {/*  );*/}
                    {/*})}*/}
                  </Card>
                </Col>
            );
          })}
        </Row>
      </div>
  );
}

export default Home;
