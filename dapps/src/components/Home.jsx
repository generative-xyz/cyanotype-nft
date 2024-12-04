import { useEffect, useRef } from 'react';
import { decodeBinary, encodeToBinary, renderSVG, varCont } from '../../encode';
// import ABI from '../../../Contract/artifacts/contracts/NFTs.sol/CharacterInfo.json';
// // import ABI from '../contracts/ABI.json';
// import { Button, Card, Col, Input, Row, Space, Typography, Upload } from 'antd';
// import Web3 from 'web3';
// import config from '../../../Contract/config.json';
// const { Meta } = Card;
// const { Title } = Typography;

// const contractAddress = config.contractAddress;
// // const contractAddress = '0x663E587e4988AF5798Fcb2eE13aDaBc5b39e8818';

function Home() {
  // const [loadings, setLoadings] = useState(false);
  // const [loadingArt, setLoadingArt] = useState(false);
  // const [inputAddress, setInputAddress] = useState('');
  // const [removeAddress, setRemoveAddress] = useState('');
  // const [checkAddress, setCheckAddress] = useState('');
  // const [walletBalance, setWalletBalance] = useState('');
  // const [acc, setAcc] = useState('');
  // const [dataJsonArray, setDataJsonArray] = useState([]);
  // const [tokenIdCurrent, setTokenIdCurrent] = useState(0);
  // const gasPrice = '50000000000';

  const reftContent= useRef();


  useEffect(() => {

    console.log('____varCont', varCont.length);
    const binary = encodeToBinary(varCont);
    console.log(binary);
    const svg = renderSVG(decodeBinary(binary));
    console.log();
    reftContent.current.innerHTML = svg;
  }, [])

  

  // var web3 = new Web3(window.ethereum);
  // var contractABI = new web3.eth.Contract(ABI.abi, contractAddress);

  // const connectWallet = async () => {
  //   await window.ethereum.enable();
  //   const account = await web3.eth.requestAccounts();
  //   setAcc(account);
  //   console.log('Wallet current: ', account[0]);
  // };

  // const mint = async () => {
  //   await contractABI.methods
  //       .mint(acc[0])
  //       .send({
  //         from: acc[0],
  //         gasPrice,
  //       })
  //       .then(() => {
  //         contractABI
  //             .getPastEvents(
  //                 'TokenMinted',
  //                 {
  //                   // fromBlock: 0,
  //                   toBlock: 'latest',
  //                 },
  //                 function (error, events) {
  //                   console.log(events);
  //                 }
  //             )
  //             .then(async function (events) {
  //               let tokenID = events[0].returnValues.tokenId;
  //               const tokenIdConvert = Number(tokenID);
  //               setTokenIdCurrent(tokenIdConvert);
  //               setLoadings(false);
  //             });
  //       })
  //       .catch(err => {
  //         console.error(err.message);
  //       });

  //   // if (result) {
  //   //   console.log('tokenIdConvert', tokenIdConvert);
  //   //   setLoadings(false);
  //   //   const tokenURI = await contractABI.methods
  //   //     .tokenURI(tokenIdConvert)
  //   //     .call();
  //   //   setDataJsonArray([...dataJsonArray, JSON.parse(atob(tokenURI))]);
  //   // }
  // };

  // async function addAdressMint(add) {
  //   await contractABI.methods.addAdressMint(add).send({
  //     from: acc[0],
  //     gasPrice,
  //   });
  //   setInputAddress('');
  // }

  // async function removeAdressMint(add) {
  //   await contractABI.methods.removeAdressMint(add).send({
  //     from: acc[0],
  //     gasPrice,
  //   });
  //   setRemoveAddress('');
  // }

  // async function checkAdressMint(add) {
  //   await contractABI.methods
  //       .checkPermissionAddress(add)
  //       .call()
  //       .then(result => console.log(result));
  //   setCheckAddress('');
  // }

  // function cutString(str) {
  //   const getName = str.match(/[a-zA-Z]+/g).join('');
  //   const getRate = str.match(/\d+/g).join('');
  //   return { getName, getRate };
  // }

  // const showArt = async () => {
  //   if (tokenIdCurrent == 0 || tokenIdCurrent) {
  //     const tokenURI = await contractABI.methods
  //         .tokenURI(tokenIdCurrent)
  //         .call()
  //         .then(result => {
  //           var cutString = result.substring(29);
  //           console.log(cutString);
  //           setDataJsonArray([...dataJsonArray, JSON.parse(atob(cutString))]);
  //         })
  //         .catch(err => console.log(err));
  //     console.log(tokenURI);
  //     setLoadingArt(false);
  //   } else {
  //     console.log("Don't have tokenId");
  //   }
  // };

  // function base64ToJson(base64String) {
  //   const json = Buffer.from(base64String, 'base64').toString();
  //   return JSON.parse(json);
  // }

  // const getBalance = async () => {
  //   if (acc) {
  //     const balance = await web3.eth.getBalance(acc[0]);
  //     const balanceInEther = web3.utils.fromWei(balance, 'ether');
  //     setWalletBalance(balanceInEther);
  //   } else {
  //     console.log('No account');
  //   }
  // };

  // async function addBackground(info) {
  //   let name, image;
  //   if (info.file.status === 'done') {
  //     const reader = new FileReader();
  //     name = info.file.name;
  //     name = name.slice(0, name.lastIndexOf('.'));
  //     let formatString = cutString(name);
  //     reader.onload = async e => {
  //       image = e.target.result;
  //       let obj = {
  //         name: formatString.getName,
  //         image,
  //         ele_type: 'Background',
  //         rate: formatString.getRate,
  //       };
  //       await contractABI.methods
  //           .addElements(obj)
  //           .send({ from: acc[0], gasPrice });
  //     };
  //     reader.readAsText(info.file.originFileObj);
  //   }
  // }

  // async function addFlower(info) {
  //   let name, image;
  //   if (info.file.status === 'done') {
  //     const reader = new FileReader();
  //     name = info.file.name;
  //     name = name.slice(0, name.lastIndexOf('.'));
  //     let formatString = cutString(name);
  //     reader.onload = async e => {
  //       image = e.target.result;
  //       let obj = {
  //         name: formatString.getName,
  //         image,
  //         ele_type: 'Flower',
  //         rate: formatString.getRate,
  //       };
  //       await contractABI.methods
  //           .addElements(obj)
  //           .send({ from: acc[0], gasPrice });
  //     };
  //     reader.readAsText(info.file.originFileObj);
  //   }
  // }

  // async function addLeaf(info) {
  //   let name, image;
  //   if (info.file.status === 'done') {
  //     const reader = new FileReader();
  //     name = info.file.name;
  //     name = name.slice(0, name.lastIndexOf('.'));
  //     let formatString = cutString(name);
  //     reader.onload = async e => {
  //       image = e.target.result;
  //       let obj = {
  //         name: formatString.getName,
  //         image,
  //         ele_type: 'Leaf',
  //         rate: formatString.getRate,
  //       };
  //       await contractABI.methods
  //           .addElements(obj)
  //           .send({ from: acc[0], gasPrice });
  //     };
  //     reader.readAsText(info.file.originFileObj);
  //   }
  // }

  // async function addInsect(info) {
  //   let name, image;
  //   if (info.file.status === 'done') {
  //     const reader = new FileReader();
  //     name = info.file.name;
  //     name = name.slice(0, name.lastIndexOf('.'));
  //     let formatString = cutString(name);
  //     reader.onload = async e => {
  //       image = e.target.result;
  //       let obj = {
  //         name: formatString.getName,
  //         image,
  //         ele_type: 'Insect',
  //         rate: formatString.getRate,
  //       };
  //       await contractABI.methods
  //           .addElements(obj)
  //           .send({ from: acc[0], gasPrice });
  //     };
  //     reader.readAsText(info.file.originFileObj);
  //   }
  // }

  return (
      <div ref={reftContent}>
        
      </div>
  );
}

export default Home;
