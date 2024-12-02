// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

// Uncomment this line to use console.log
// import "hardhat/console.sol";
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Base64.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import '@openzeppelin/contracts/utils/Strings.sol';

contract GenArt is ERC721, ERC721URIStorage, Ownable, ERC721Burnable {
  uint public constant TOKEN_LIMIT = 20;

  //Token increase
  uint256 private tokenIdCounter;
  uint256 newTokenId;
  event TokenMinted(uint256 tokenId);

  mapping(uint256 => Attr) public attributes;

  Background[] public background;
  Flower[] public flower;
  Grass[] public grass;
  Insect[] public insect;

  modifier CheckToken(uint256 tokenId) {
    require(_exists(tokenId), 'ERC721: Token does not exist');
    // require(!_exists(tokenId), 'ERC721: token already minted');
    _;
  }

  struct Attr {
    string trait_type;
    string value;
  }

  struct Background {
    string name;
    string image;
  }

  struct Flower {
    string name;
    string image;
  }

  struct Grass {
    string name;
    string image;
  }

  struct Insect {
    string name;
    string image;
  }

  constructor() ERC721('GenArt', 'NFTA') {
    tokenIdCounter = 0;
  }

  function addBackground(Background memory obj) public {
    background.push(Background(obj.name, obj.image));
  }

  function getBackground() public view returns (Background[] memory) {
    return background;
  }

  function addFlower(Flower memory obj) public {
    flower.push(Flower(obj.name, obj.image));
  }

  function getFlower() public view returns (Flower[] memory) {
    return flower;
  }

  function addGrass(Grass memory obj) public {
    grass.push(Grass(obj.name, obj.image));
  }

  function getGrass() public view returns (Grass[] memory) {
    return grass;
  }

  function addInsect(Insect memory obj) public {
    insect.push(Insect(obj.name, obj.image));
  }

  function getInsect() public view returns (Insect[] memory) {
    return insect;
  }

  function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
    super._burn(tokenId);
  }

  function supportsInterface(
    bytes4 interfaceId
  ) public view override(ERC721, ERC721URIStorage) returns (bool) {
    return super.supportsInterface(interfaceId);
  }

  function mint(address to) public payable {
    require(to != address(0));
    require(tokenIdCounter < TOKEN_LIMIT);
    require(msg.value <= 0.05 ether, 'Need to pay up!');
    newTokenId = tokenIdCounter;
    _safeMint(to, newTokenId);
    emit TokenMinted(newTokenId);
    tokenIdCounter += 1;
  }

  // Return về Metadata
  function tokenURI(
    uint256 tokenId
  )
    public
    view
    override(ERC721, ERC721URIStorage)
    CheckToken(tokenId)
    returns (string memory result)
  {
    string memory name = '"name": "Cyanotype#';
    string memory tokenID = Strings.toString(tokenId);
    string memory desc = '"description": "Generative"';

    result = string(
      abi.encodePacked(
        // 'data:application/json;base64,',
        Base64.encode(
          abi.encodePacked(
            '{',
            name,
            tokenID,
            '"',
            ',',
            desc,
            ',',
            '"image": "',
            this.svgToImageURI(getSvg(uint256(tokenId))),
            '"',
            ',',
            '"attributes": "',
            // this.getAttributes(uint256(tokenId)),
            '"',
            '}'
          )
        )
      )
    );
  }

  // Format SVG to Base64
  function svgToImageURI(
    string memory svg
  ) public pure returns (string memory) {
    string memory baseURL = 'data:image/svg+xml;base64,';
    string memory svgBase64Encoded = Base64.encode(bytes(svg));
    return string(abi.encodePacked(baseURL, svgBase64Encoded));
  }

  //Trả về File SVG HTML
  function getSvg(uint256 tokenId) public view returns (string memory) {
    string
      memory SVG_HEADER = '<svg viewBox="0 0 954.18 946.29" fill="none" xmlns="http://www.w3.org/2000/svg">';
    string
      memory SVG_HEADER_FLOWER = '<svg viewBox="0 0 954.18 946.29" fill="none" xmlns="http://www.w3.org/2000/svg">';
    string memory SVG_FOOTER = '</svg>';
    // setAttributes(tokenId);

    // Background memory objBackground = background[0];
    // Flower memory objFlower = flower[0];
    Background memory objBackground = background[
      generateRandomIndex(background.length)
    ];
    Flower memory objFlower = flower[generateRandomIndex(flower.length)];
    // Grass memory objGrass = grass[generateRandomIndex(grass.length)];
    // Insect memory objInsect = insect[generateRandomIndex(insect.length)];

    // uint randomIndex = generateRandomIndex(background.length, bytes32(0x1234567890abcdef) );
    // Background memory objBackground = background[randomIndex];

    return
      string(
        abi.encodePacked(
          SVG_HEADER,
          objBackground.image,
          SVG_HEADER_FLOWER,
          objFlower.image,
          SVG_FOOTER,
          // SVG_HEADER,
          // objFlower.image,
          // SVG_FOOTER,
          SVG_FOOTER
        )
      );
  }

  function setAttributes(uint256 tokenId) public {
    Attr storage myStruct = attributes[tokenId];
    myStruct.trait_type = 'Flower';
    myStruct.value = 'Rose';
    // attributes[tokenId] = Attr("name", "desc", "flower", "grass", "insect");
  }

  function getAttributes(uint256 tokenId) public view returns (Attr memory) {
    // attributes[msg.sender] = attributes[tokenId];
    return attributes[tokenId];
  }

  function generateRandomIndex(uint number) public view returns (uint) {
    return
      uint(
        keccak256(
          abi.encodePacked(block.timestamp, block.difficulty, msg.sender)
        )
      ) % number;
  }
  //   function generateRandomIndex(uint number, bytes32 seed) public pure returns (uint) {
  //     bytes32 hash = sha256(abi.encodePacked(seed));
  //     return uint(hash) % number;
  // }
}
