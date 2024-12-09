```javascript
const connectWallet = async () => {
await window.ethereum.enable();
const account = await web3.eth.requestAccounts();
setAcc(account);
console.log('Wallet current: ', account[0]);
};

  /*async function addInsect(info) {
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
  }*/