// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Base64.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract GenArt is ERC721, ERC721URIStorage, Ownable, ERC721Burnable {
  uint16 public constant TOKEN_LIMIT = 256;

  mapping(address => bool) public addressMint;
  mapping(uint256 => bool) private tokenExists;

  uint256 private tokenIdCounter;
  uint256 newTokenId;
  event TokenMinted(uint256 tokenId);

  mapping(uint256 => uint256) public seedTokenId;
  mapping(uint256 => Attr[]) public attributes;

  string internal constant SVG_HEADER =
  '<svg viewBox="0 0 1000 1000" fill="none" xmlns="http://www.w3.org/2000/svg">';
  string internal constant SVG_FOOTER = '</svg>';

  Element[] public background;
  Element[] public flower;
  Element[] public leaf;
  Element[] public insect;

  uint8[] public elementChoose = [1, 2];
  uint8[] public numberElement = [4, 5, 6];
  string[] public sizeElement = ["233", "333", "432", "500"];
  string[] public sizeElementLayoutFour = ["333", "432", "500"];

  struct Attr {
    string trait_type;
    string name;
    string value;
    string size;
  }

  struct Element {
    string name;
    string image;
    string ele_type;
    uint8 rate;
  }

  struct ElementSVG {
    string script;
    string size;
  }

  string[][][] public coordinate4Elements;
  string[][][] public coordinate5Elements;
  string[][][] public coordinate6Elements;

  constructor() ERC721('GenArt', 'NFTA') {
    tokenIdCounter = 0;

    coordinate4Elements.push([["324", "323"], ["674", "323"], ["324", "676"], ["674", "676"]]);
    coordinate4Elements.push([["417", "295"], ["478", "516"], ["299", "711"], ["682", "701"]]);
    coordinate4Elements.push([["355", "298"], ["641", "297"], ["381", "538"], ["641", "704"]]);
    coordinate4Elements.push([["334", "304"], ["411", "540"], ["668", "541"], ["529", "718"]]);
    coordinate4Elements.push([["666", "293"], ["333", "519"], ["259", "713"], ["666", "713"]]);
    coordinate4Elements.push([["679", "286"], ["275", "512"], ["422", "627"], ["708", "709"]]);

    coordinate5Elements.push([["296","303"], ["703","303"], ["503","506"], ["296","723"], ["703","723"]]);
    coordinate5Elements.push([["263","249"], ["716","303"], ["499","513"], ["263","636"], ["689","726"]]);
    coordinate5Elements.push([["349","306"], ["533","456"], ["266","722"], ["513","722"], ["763","669"]]);
    coordinate5Elements.push([["236","329"], ["469","376"], ["739","339"], ["333","663"], ["596","756"]]);
    coordinate5Elements.push([["259","407"], ["489","317"], ["306","715"], ["489","574"], ["739","644"]]);

    coordinate6Elements.push([["256","346"], ["499","346"], ["746","346"], ["256","679"], ["499","679"], ["746","679"]]);
    coordinate6Elements.push([["249","316"], ["499","316"], ["766","316"], ["506","533"], ["356","699"], ["606","699"]]);
    coordinate6Elements.push([["479","296"], ["749","379"], ["766","546"], ["499","729"], ["263","593"], ["249","379"]]);
    coordinate6Elements.push([["499","253"], ["293","419"], ["516","586"], ["746","513"], ["292","633"], ["559","719"]]);
    coordinate6Elements.push([["383","299"], ["689","299"], ["383","466"], ["249","646"], ["466","709"], ["769","649"]]);
  }

  function addAdressMint(address add) public  {
    addressMint[add] = true;
  }

  function removeAdressMint(address add) public  {
    addressMint[add] = false;
  }

  function addElements(Element memory obj)  public {
    if (keccak256(bytes(obj.ele_type)) == keccak256(bytes("Background")) ) {
      background.push(Element(obj.name, obj.image, obj.ele_type, obj.rate));
    }
    if (keccak256(bytes(obj.ele_type)) == keccak256(bytes("Flower")) ) {
      flower.push(Element(obj.name, obj.image, obj.ele_type, obj.rate));
    }
    if (keccak256(bytes(obj.ele_type)) == keccak256(bytes("Leaf")) ) {
      leaf.push(Element(obj.name, obj.image, obj.ele_type, obj.rate));
    }
    if (keccak256(bytes(obj.ele_type)) == keccak256(bytes("Insect")) ) {
      insect.push(Element(obj.name, obj.image, obj.ele_type, obj.rate));
    }
  }

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function transferNFT(uint256 tokenId, address to) public {
    require(ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT");
    _transfer(msg.sender, to, tokenId);
  }

  function checkPermissionAddress(address to) public view returns(string memory result) {
    if(addressMint[to]){
      result = "Have permission mint";
    }else{
      result = "Don't have permission mint";
    }
  }

  function mint(address to) public payable {
    require(addressMint[to] , "You don't have permission mint NFT");
    require(to != address(0));
    require(tokenIdCounter < TOKEN_LIMIT, 'Mints have exceeded the limit');
    newTokenId = tokenIdCounter;
    tokenExists[newTokenId] = true;
    _safeMint(to, newTokenId);
    uint256 seed = uint256(keccak256(abi.encodePacked(block.timestamp, to, newTokenId)));
    seedTokenId[newTokenId] = seed;
    emit TokenMinted(newTokenId);
    tokenIdCounter += 1;
  }

  function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory result) {
    require(_exists(tokenId), 'ERC721: Token does not exist');
    string memory name = '"name": "Cyanotype #';
    string memory tokenID = Strings.toString(tokenId);
    string memory desc = '"description": "Cyanotype NFT Art"';
    string memory getOwner = addressToString(_ownerOf(tokenId));

    result = string(
      abi.encodePacked(
        'data:application/json;base64,',
        Base64.encode(
          abi.encodePacked(
            '{',
            name,
            tokenID,
            '"',
            ',',
            desc,
            ',',
            '"owner": "',
            getOwner,
            '"',
            ',',
            '"edition": "',
            tokenID,
            '"',
            ',',
            '"image": "',
            this.svgToImageURI(getSvg(tokenId)),
            '"',
            ',',
            '"attributes": [',
            this.generateTraits(tokenId),
            ']',
            '}'
          )
        )
      )
    );
  }

  function svgToImageURI(string memory svg) public pure returns (string memory) {
    string memory baseURL = 'data:image/svg+xml;base64,';
    string memory svgBase64Encoded = Base64.encode(bytes(svg));
    return string(abi.encodePacked(baseURL, svgBase64Encoded));
  }

  function getSvg(uint256 tokenId) public view returns (string memory result ) {
    uint8 numElement = numberElement[randomIndex(uint8(numberElement.length), tokenId, 1)];
    Element memory objBackground = getTraitsBackground(tokenId, 2);

    ElementSVG[] memory newTraitElement = new ElementSVG[](numElement);

    string memory BASE = string(
      abi.encodePacked(
        SVG_HEADER,
        objBackground.image
      )
    );
    string memory temp = string(abi.encodePacked(BASE));

    string[][] memory mapLayout;

    if(numElement == 4){
      string memory sizeInsect = sizeElementLayoutFour[randomIndex(uint8(sizeElementLayoutFour.length) , tokenId, 3)];
      Element memory objInsect = getTraitsInsect(tokenId, 4);
      newTraitElement[0] = ElementSVG(objInsect.image, sizeInsect);
      string memory sizeFlower = sizeElementLayoutFour[randomIndex(uint8(sizeElementLayoutFour.length), tokenId, 5)];
      Element memory objFlower = getTraitsFlower(tokenId, 6);
      newTraitElement[1] =  ElementSVG(objFlower.image, sizeFlower);
      string memory sizeLeaf = sizeElementLayoutFour[randomIndex(uint8(sizeElementLayoutFour.length), tokenId, 7)];
      Element memory objLeaf = getTraitsLeaf(tokenId, 8);
      newTraitElement[2] = ElementSVG(objLeaf.image, sizeLeaf);
    }else {
      string memory sizeInsect = sizeElement[randomIndex(uint8(sizeElement.length) , tokenId, 9)];
      Element memory objInsect = getTraitsInsect(tokenId, 10);
      newTraitElement[0] = ElementSVG(objInsect.image, sizeInsect);
      string memory sizeFlower = sizeElement[randomIndex(uint8(sizeElement.length), tokenId, 11)];
      Element memory objFlower =  getTraitsFlower(tokenId, 12);
      newTraitElement[1] =  ElementSVG(objFlower.image, sizeFlower);
      string memory sizeLeaf = sizeElement[randomIndex(uint8(sizeElement.length), tokenId, 13)];
      Element memory objLeaf = getTraitsLeaf(tokenId, 14);
      newTraitElement[2] = ElementSVG(objLeaf.image, sizeLeaf);
    }

    if(numElement == 4) {
      uint256 indexLayout = randomIndex(uint8(coordinate4Elements.length), tokenId, 1);
      mapLayout = coordinate4Elements[indexLayout];
      getElementsSVG(tokenId ,numElement, newTraitElement);
    }else if(numElement == 5){
      uint256 indexLayout = randomIndex(uint8(coordinate5Elements.length), tokenId, 2);
      mapLayout = coordinate5Elements[indexLayout];
      getElementsSVG(tokenId ,numElement, newTraitElement);
    }else if(numElement == 6){
      uint256 indexLayout = randomIndex(uint8(coordinate6Elements.length), tokenId, 3);
      mapLayout = coordinate6Elements[indexLayout];
      getElementsSVG(tokenId ,numElement, newTraitElement);
    }
    newTraitElement =  shuffleArray(tokenId, newTraitElement);

    for (uint i = 0; i < mapLayout.length; i++) {
      string memory x = mapLayout[i][0];
      string memory y = mapLayout[i][1];
      string memory script = newTraitElement[i].script ;
      string memory size = newTraitElement[i].size ;

      uint16 xInt = centerScale(x , size);
      uint16 yInt = centerScale(y , size);
      string memory ele = string(abi.encodePacked('<svg viewBox="0 0 1000 1000" fill="none" xmlns="http://www.w3.org/2000/svg" x="',toString(xInt), '" y="',toString(yInt), '" width="', size, '" height="', size, '">', script, SVG_FOOTER));
      temp = string(abi.encodePacked(temp,ele));
    }

    result = string(
      abi.encodePacked(
        temp,
        SVG_FOOTER
      )
    );
  }

  function generateTraits(uint256 tokenId) external view returns(string memory){
    uint8 indexNumElement = numberElement[randomIndex(uint8(numberElement.length), tokenId, 1)];
    uint256 traitsLength = indexNumElement + 2;

    Element memory objBackground = getTraitsBackground(tokenId, 2);
    Attr[] memory traits = new Attr[](traitsLength);
    traits[0] = Attr("Background", objBackground.name, objBackground.image, "1000");

    if(indexNumElement == 4 ){
      //1
      string memory sizeInsect = sizeElementLayoutFour[randomIndex(uint8(sizeElementLayoutFour.length) , tokenId, 3)];
      Element memory objInsect = getTraitsInsect(tokenId, 4);
      traits[1] = Attr("Insect", objInsect.name,  objInsect.image, sizeInsect);
      //2
      string memory sizeFlower = sizeElementLayoutFour[randomIndex(uint8(sizeElementLayoutFour.length), tokenId, 5)];
      Element memory objFlower =  getTraitsFlower(tokenId, 6);
      traits[2] = Attr("Flower",objFlower.name, objFlower.image, sizeFlower);
      //3
      string memory sizeLeaf = sizeElementLayoutFour[randomIndex(uint8(sizeElementLayoutFour.length), tokenId, 7)];
      Element memory objLeaf = getTraitsLeaf(tokenId, 8);
      traits[3] = Attr("Leaf",objLeaf.name,  objLeaf.image, sizeLeaf);
    }else{
      //1
      string memory sizeInsect = sizeElement[randomIndex(uint8(sizeElement.length), tokenId, 9)];
      Element memory objInsect = getTraitsInsect(tokenId, 10);
      traits[1] = Attr("Insect", objInsect.name,  objInsect.image, sizeInsect);
      //2
      string memory sizeFlower = sizeElement[randomIndex(uint8(sizeElement.length), tokenId, 11)];
      Element memory objFlower =  getTraitsFlower(tokenId, 12);
      traits[2] = Attr("Flower",objFlower.name, objFlower.image, sizeFlower);
      //3
      string memory sizeLeaf = sizeElement[randomIndex(uint8(sizeElement.length), tokenId, 13)];
      Element memory objLeaf = getTraitsLeaf(tokenId, 14);
      traits[3] = Attr("Leaf", objLeaf.name,  objLeaf.image, sizeLeaf);
    }

    if(indexNumElement == 4){
      uint256 indexLayout = randomIndex(uint8(coordinate4Elements.length), tokenId, 1);
      string memory valueLayout = string(abi.encodePacked(toString(indexLayout),"-",toString(indexNumElement)));
      traits[4] = Attr("Layout", valueLayout , valueLayout, "1000");
      randomChooseElement(tokenId, indexNumElement, traits);
    }
    if(indexNumElement == 5){
      uint256 indexLayout = randomIndex(uint8(coordinate5Elements.length), tokenId, 2);
      string memory valueLayout = string(abi.encodePacked(toString(indexLayout),"-",toString(indexNumElement)));
      traits[4] = Attr("Layout", valueLayout , valueLayout, "1000");
      randomChooseElement(tokenId, indexNumElement, traits);
    }
    if(indexNumElement == 6){
      uint256 indexLayout = randomIndex(uint8(coordinate6Elements.length), tokenId, 3);
      string memory valueLayout = string(abi.encodePacked(toString(indexLayout),"-",toString(indexNumElement)));
      traits[4] = Attr("Layout", valueLayout , valueLayout, "1000");
      randomChooseElement(tokenId, indexNumElement, traits);
    }

    bytes memory byteString ;
    for (uint8 i = 0; i < traits.length; i++) {
      bytes memory objString = abi.encodePacked(
        '{"trait_type":"',
        traits[i].trait_type,
        '","Name":"',
        traits[i].name,
        '","size":"',
        traits[i].size,
        '"}'
      );
      if (i > 0) {
        byteString = abi.encodePacked(byteString, ",");
      }
      byteString = abi.encodePacked(byteString, objString);
    }
    return string(byteString);
  }

  function randomChooseElement(uint256 tokenId, uint8 indexNumElement, Attr[] memory trait) internal view {
    uint8 loop = 0;
    Element memory obj;
    if(indexNumElement == 4){
      loop = 1;
    }
    if(indexNumElement == 5){
      loop = 2;
    }
    if(indexNumElement == 6){
      loop = 3;
    }
    uint8 flag = 5;
    for(uint8 i = 1; i <= loop; i++){
      string memory sizeObj;
      if(indexNumElement == 4) {
        sizeObj = sizeElementLayoutFour[randomIndex(uint8(sizeElementLayoutFour.length),tokenId, 2 + i)];
      }else{
        sizeObj = sizeElement[randomIndex(uint8(sizeElement.length),tokenId, 4 + i)];
      }
      uint8 number = elementChoose[randomIndex(uint8(elementChoose.length),tokenId, 6 + i)];
      if(number == 1) {
        obj =  getTraitsFlower(tokenId, 8 + i);
      }else{
        obj = getTraitsLeaf(tokenId, 10 + i);
      }
      trait[flag] = Attr(obj.ele_type ,obj.name,  obj.image, sizeObj);
      flag+=1;
    }
  }

  function getElementsSVG(uint256 tokenId, uint8 indexNumElement, ElementSVG[] memory newTraitElement ) internal view{
    uint8 loop;
    Element memory obj;
    if(indexNumElement == 4){
      loop = 1;
    }
    if(indexNumElement == 5){
      loop = 2;
    }
    if(indexNumElement == 6){
      loop = 3;
    }
    uint8 flag = 3;
    for(uint8 i = 1; i <= loop; i++){
      string memory sizeObj;
      if(indexNumElement == 4) {
        sizeObj = sizeElementLayoutFour[randomIndex(uint8(sizeElementLayoutFour.length),tokenId, 2 + i)];
      }else{
        sizeObj = sizeElement[randomIndex(uint8(sizeElement.length),tokenId, 4 + i)];
      }
      uint8 number = elementChoose[randomIndex(uint8(elementChoose.length),tokenId , 6 + i)];
      if(number == 1) {
        obj =  getTraitsFlower(tokenId, 8 + i);
      }else{
        obj = getTraitsLeaf(tokenId, 10 + i);
      }
      newTraitElement[flag] = ElementSVG(obj.image, sizeObj);
      flag+=1;
    }
  }

  function randomIndex(uint256 maxLength, uint256 tokenId, uint16 i) internal view returns (uint) {
    uint256 seed = seedTokenId[tokenId];
    uint256 randomNumber = uint256(keccak256(abi.encodePacked(seed, i)));
    return randomNumber % maxLength;
  }

  function stringToInt(string memory _str) internal pure returns (uint256) {
    bytes memory b = bytes(_str);
    uint256 result = 0;

    for (uint256 i = 0; i < b.length; i++) {
      uint256 digit = uint256(uint8(b[i])) - 48;
      require(digit <= 9, "Invalid character in string");
      result = result * 10 + digit;
    }

    return result;
  }

  function toString(uint256 value) internal pure returns (string memory) {
    if (value == 0) {
      return "0";
    }
    uint256 temp = value;
    uint256 digits;
    while (temp != 0) {
      digits++;
      temp /= 10;
    }
    bytes memory buffer = new bytes(digits);
    while (value != 0) {
      digits -= 1;
      buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
      value /= 10;
    }
    return string(buffer);
  }

  function centerScale(string memory coor, string memory s) internal pure returns(uint16 result) {
    uint256 coordinate = uint256(stringToInt(coor)) ;
    uint256 sInt = uint256(stringToInt(s)) ;
    result = uint16(coordinate - (sInt / 2));
    return result;
  }

  function getNumbersLayoutFromString(string memory str) internal pure returns (uint256, uint256) {
    bytes memory strBytes = bytes(str);
    uint256 dashIndex = 0;
    for (uint256 i = 0; i < strBytes.length; i++) {
      if (strBytes[i] == '-') {
        dashIndex = i;
        break;
      }
    }

    // Convert the substrings into numbers
    uint256 num1 = 0;
    uint256 num2 = 0;
    for (uint256 i = 0; i < dashIndex; i++) {
      num1 = num1 * 10 + uint256(uint8(strBytes[i])) - 48;
    }
    for (uint256 i = dashIndex + 1; i < strBytes.length; i++) {
      num2 = num2 * 10 + uint256(uint8(strBytes[i])) - 48;
    }
    return (num1, num2);
  }

  function addressToString(address _address) public pure returns (string memory result) {
    bytes32 value = bytes32(uint256(uint160(_address)));

    bytes memory alphabet = "0123456789abcdef";
    bytes memory str = new bytes(42);
    str[0] = "0";
    str[1] = "x";
    for (uint256 i = 0; i < 20; i++) {
      str[2 + i * 2] = alphabet[uint8(value[i + 12] >> 4)];
      str[3 + i * 2] = alphabet[uint8(value[i + 12] & 0x0f)];
    }
    result = string(str);
  }

  function getTraitsBackground(uint256 tokenId, uint16 hardRan) internal view returns (Element memory){
    uint256[] memory indexs = new uint256[](background.length);
    uint256 totalTraitValue = 0;
    for(uint32 i=0;i<background.length; i++){
      totalTraitValue += background[i].rate;
      indexs[i] = totalTraitValue;
    }
    uint256 indexRandom = randomIndex(totalTraitValue, tokenId, hardRan);
    for(uint32 i=0;i<indexs.length; i++){
      if(indexRandom< indexs[i]){
        return background[i];
      }
    }
    return background[0];
  }

  function getTraitsFlower(uint256 tokenId, uint16 hardRan) internal view returns (Element memory){
    uint256[] memory indexs = new uint256[](flower.length);
    uint256 totalTraitValue = 0;
    for(uint8 i = 0;i < flower.length; i++){
      totalTraitValue += flower[i].rate;
      indexs[i] = totalTraitValue;
    }
    uint256 indexRandom = randomIndex(totalTraitValue, tokenId, hardRan);
    for(uint32 i=0;i<indexs.length; i++){
      if(indexRandom< indexs[i]){
        return flower[i];
      }
    }
    return flower[0];
  }

  function getTraitsInsect(uint256 tokenId, uint16 hardRan) internal view returns (Element memory){
    uint256[] memory indexs = new uint256[](insect.length);
    uint256 totalTraitValue = 0;
    for(uint8 i = 0;i < insect.length; i++){
      totalTraitValue += insect[i].rate;
      indexs[i] = totalTraitValue;
    }
    uint256 indexRandom = randomIndex(totalTraitValue, tokenId, hardRan);
    for(uint32 i=0; i < indexs.length ; i++){
      if(indexRandom< indexs[i]){
        return insect[i];
      }
    }
    return insect[0];
  }

  function getTraitsLeaf(uint256 tokenId, uint16 hardRan) internal view returns (Element memory){
    uint256[] memory indexs = new uint256[](leaf.length);
    uint256 totalTraitValue = 0;
    for(uint8 i = 0;i < leaf.length; i++){
      totalTraitValue += leaf[i].rate;
      indexs[i] = totalTraitValue;
    }
    uint256 indexRandom = randomIndex(totalTraitValue, tokenId, hardRan);
    for(uint32 i=0; i < indexs.length ; i++){
      if(indexRandom< indexs[i]){
        return leaf[i];
      }
    }
    return leaf[0];
  }

  function shuffleArray(uint256 tokenId, ElementSVG[] memory arrayToShuffle) public view returns (ElementSVG[] memory) {
    uint256 seed = seedTokenId[tokenId];
    ElementSVG[] memory shuffledArray = arrayToShuffle;
    uint256 n = shuffledArray.length;

    for (uint256 i = 0; i < n; i++) {
      uint256 j = i + uint256(keccak256(abi.encode(seed, i))) % (n - i);
      (shuffledArray[i], shuffledArray[j]) = (shuffledArray[j], shuffledArray[i]);
    }

    return shuffledArray;
  }
}