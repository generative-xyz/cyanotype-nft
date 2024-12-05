// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Base64.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';
import 'hardhat/console.sol';
contract CharacterInfo is ERC721, ERC721URIStorage, Ownable, ERC721Burnable {
    uint16 public constant TOKEN_LIMIT = 10000; // Changed to 10000

    mapping(address => bool) public addressMint;
    mapping(uint16 => bool) private tokenExists; // Changed to uint16 since max is 10000
    uint16 newTokenId; // Changed to uint16

    uint16 private tokenIdCounter; // Changed to uint16

    struct PositionDetail {
        uint8 x;      // 0-24
        uint8 y;      // 0-24
        uint8 colorId; // Index into colors array
    }

    struct ItemDetail {
        string name;
        uint8 trait;  // 0-200
        uint8[] positions; // x,y,r,g,b stored sequentially
    }

    // Mappings for each item type
    mapping(string => mapping(uint16 => ItemDetail)) private items;
    mapping(string => uint16) private itemCounts;
    mapping(uint16 => uint256) public seedTokenId;

    uint8 constant PIXEL_SIZE = 24;
    uint8 constant GRID_SIZE = 24;

    event SVGGenerated(address indexed creator, uint timestamp);
    event ItemAdded(string itemType, uint16 indexed itemId, string name, uint8 trait);
    event TokenMinted(uint16 tokenId);
    string[] private VALID_ITEM_TYPES = ["body", "mouth", "shirt", "eye"];

    modifier validItemType(string memory _itemType) {
        bool isValid;
        for(uint i = 0; i < VALID_ITEM_TYPES.length; i++) {
            if(keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked(VALID_ITEM_TYPES[i]))) {
                isValid = true;
                break;
            }
        }
        require(isValid, "Invalid item type");
        _;
    }

    constructor() ERC721('CharacterInfo', 'NFTs') {
        tokenIdCounter = 0;
    }

    // =============== Get, Add Traits function ===============
    function addItem(
        string memory _itemType,
        string memory _name,
        uint8 _trait,
        uint8[] memory _positions
    ) public validItemType(_itemType) returns (uint16) {
        require(_positions.length % 5 == 0, "Invalid positions array length");
        require(_trait <= 200, "Trait must be <= 200");

        uint16 numPixels = uint16(_positions.length / 5);
        for(uint i = 0; i < numPixels; i++) {
            uint index = i * 5;
            require(_positions[index] <= 24, "X coordinate must be <= 24");
            require(_positions[index + 1] <= 24, "Y coordinate must be <= 24");
        }

        uint16 itemId = uint16(itemCounts[_itemType]++);

        items[_itemType][itemId].name = _name;
        items[_itemType][itemId].trait = _trait;
        items[_itemType][itemId].positions = _positions;

        emit ItemAdded(_itemType, itemId, _name, _trait);
        return itemId;
    }

    function getItem(string memory _itemType, uint16 _itemId) public view validItemType(_itemType) returns (
        string memory name,
        uint8 trait,
        uint8[] memory positions
    ) {
        require(_itemId < itemCounts[_itemType], "Item does not exist");
        ItemDetail memory item = items[_itemType][_itemId];
        return (item.name, item.trait, item.positions);
    }

    function getDetailCount(string memory _itemType, uint16 _itemId) public view validItemType(_itemType) returns (uint16) {
        require(_itemId < itemCounts[_itemType], "Item does not exist");
        return uint16(items[_itemType][_itemId].positions.length / 5); // Divide by 5 since each detail has 5 values
    }

    function getItemDetail(string memory _itemType, uint16 _itemId, uint16 _detailIndex) public view validItemType(_itemType) returns (
        uint8 x,
        uint8 y,
        uint8 r,
        uint8 g,
        uint8 b
    ) {
        require(_itemId < itemCounts[_itemType], "Item does not exist");
        ItemDetail memory item = items[_itemType][_itemId];
        uint16 baseIndex = _detailIndex * 5;
        require(baseIndex + 4 < item.positions.length, "Detail index out of bounds");

        return (
            item.positions[baseIndex],
            item.positions[baseIndex + 1],
            item.positions[baseIndex + 2],
            item.positions[baseIndex + 3],
            item.positions[baseIndex + 4]
        );
    }

    function getItemCount(string memory _itemType) public view validItemType(_itemType) returns (uint16) {
        return itemCounts[_itemType];
    }

    // =============== Draw Art function ===============
    function createRect(uint8 x, uint8 y, uint8 r, uint8 g, uint8 b) public pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<rect ',
                'x="', toString(x), '" ',
                'y="', toString(y), '" ',
                'width="1" ',
                'height="1" ',
                'fill="rgb(', toString(r), ',', toString(g), ',', toString(b), ')" ',
                '/>'
            )
        );
    }

    function createMultipleRects(uint8[] memory positions) internal pure returns (bytes memory) {
        bytes memory pixels = new bytes(2304);

        for(uint i = 0; i < positions.length; i += 5) {
            uint8 x = positions[i];
            uint8 y = positions[i+1];
            uint8 r = positions[i+2];
            uint8 g = positions[i+3];
            uint8 b = positions[i+4];

            // Calculate pixel position in byte array (x,y coordinates to linear RGBA array)
            uint16 p = uint16((uint16(y) * 24 + uint16(x)) * 3);

            // Set RGBA values
            pixels[p] = bytes1(r);     // R
            pixels[p+1] = bytes1(g);   // G
            pixels[p+2] = bytes1(b);   // B
            pixels[p+3] = bytes1(0xFF); // A (fully opaque)
        }

        return pixels;
    }

    function createFullSVGWithGrid(uint8[] memory positions) public pure returns (string memory) {
        bytes memory pixelBytes = createMultipleRects(positions);
        // Convert bytes to string of rect elements
        string memory rects = '';
        for(uint i = 0; i < pixelBytes.length; i += 4) {
            if(pixelBytes[i+3] > 0) { // Only render if alpha > 0
                uint8 x = (uint8(i/4 % 24));
                uint8 y = (uint8(i/4 / 24));
                rects = string(abi.encodePacked(
                    rects,
                    createRect(
                        x,
                        y,
                        uint8(pixelBytes[i]),
                        uint8(pixelBytes[i+1]),
                        uint8(pixelBytes[i+2])
                    )
                ));
            }
        }

        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" ',
                'viewBox="0 0 24 24">',
                rects,
                '</svg>'
            )
        );

        return svg;
    }

    function renderSVG(string memory _itemType, uint16 _itemId) public view validItemType(_itemType) returns (string memory) {
/*        string memory svg = string(
            abi.encodePacked(
                '<svg width="24" height="24" viewBox="0 0 24 24" fill="none" xmlns="http://www.w3.org/2000/svg"><rect width="24" height="24" fill="#35D28E"/></svg> '
            )
        );*/
//        return svgToImageURI( createFullSVGWithGrid(items[_itemType][_itemId].positions));
        return createFullSVGWithGrid(items[_itemType][_itemId].positions);
    }

    // =============== Help function ===============
    function shuffleArray(uint16 tokenId, ItemDetail[] memory arrayToShuffle) public view returns (ItemDetail[] memory) { // Changed param to uint16
        uint256 seed = seedTokenId[tokenId];
        ItemDetail[] memory shuffledArray = arrayToShuffle;
        uint256 n = shuffledArray.length;

        for (uint256 i = 0; i < n; i++) {
            uint256 j = i + uint256(keccak256(abi.encode(seed, i))) % (n - i);
            (shuffledArray[i], shuffledArray[j]) = (shuffledArray[j], shuffledArray[i]);
        }

        return shuffledArray;
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

    function randomIndex(uint256 maxLength, uint16 tokenId, uint16 i) internal view returns (uint) {
        uint256 seed = seedTokenId[tokenId];
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(seed, i)));
        return randomNumber % maxLength;
    }

    function svgToImageURI(string memory svg) public pure returns (string memory) {
        string memory baseURL = 'data:image/svg+xml;base64,';
        string memory svgBase64Encoded = Base64.encode(bytes(svg));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    //=============== Core function ===============
    function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function transferNFT(uint16 tokenId, address to) public { // Changed param to uint16
        require(ownerOf(tokenId) == msg.sender, "You are not the owner of this NFT");
        _transfer(msg.sender, to, tokenId);
    }

    //=============== ERC721 function ===============
    function mint(address to) public payable {
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
        string memory name = '"name": "Robot #';
        string memory tokenID = Strings.toString(tokenId);
        string memory desc = '"description": "Robot NFT Art"';
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
                        renderSVG("body", 0),
                        '"',
                        '}'
                    )
                )
            )
        );
    }
}