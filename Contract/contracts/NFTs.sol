// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import '@openzeppelin/contracts/token/ERC721/ERC721.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Base64.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol';
import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract CharacterInfo is ERC721, ERC721URIStorage, Ownable, ERC721Burnable {
    uint16 public constant TOKEN_LIMIT = 256;

    mapping(address => bool) public addressMint;
    mapping(uint256 => bool) private tokenExists;
    uint256 newTokenId;

    uint256 private tokenIdCounter;

    struct PositionDetail {
        string x;
        string y; 
        string color;
    }

    struct ItemDetail {
        string name;
        string trait;
        PositionDetail[] positions;
    }

    // Mappings for each item type
    mapping(string => mapping(uint256 => ItemDetail)) private items;
    mapping(string => uint256) private itemCounts;
    mapping(uint256 => uint256) public seedTokenId;

    uint constant PIXEL_SIZE = 24;
    uint constant GRID_SIZE = 24;
    
    event SVGGenerated(address indexed creator, uint timestamp);
    event ItemAdded(string itemType, uint256 indexed itemId, string name, string trait);
    event TokenMinted(uint256 tokenId);

    string[] private VALID_ITEM_TYPES = ["glass", "head", "body", "hand", "footer", "hair", "eye"];

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

    function addItem(
        string memory _itemType,
        string memory _name,
        string memory _trait,
        string[] memory _xArray,
        string[] memory _yArray,
        string[] memory _colorArray
    ) public validItemType(_itemType) returns (uint256) {
        require(
            _xArray.length == _yArray.length && 
            _yArray.length == _colorArray.length,
            "Arrays must have same length"
        );

        uint256 itemId = itemCounts[_itemType]++;
        ItemDetail storage item = items[_itemType][itemId];
        
        item.name = _name;
        item.trait = _trait;

        for(uint i = 0; i < _xArray.length; i++) {
            item.positions.push(PositionDetail({
                x: _xArray[i],
                y: _yArray[i],
                color: _colorArray[i]
            }));
        }

        emit ItemAdded(_itemType, itemId, _name, _trait);
        return itemId;
    }

    function getItem(string memory _itemType, uint256 _itemId) public view validItemType(_itemType) returns (
        string memory name,
        string memory trait,
        PositionDetail[] memory positions
    ) {
        require(_itemId < itemCounts[_itemType], "Item does not exist");
        ItemDetail storage item = items[_itemType][_itemId];
        return (item.name, item.trait, item.positions);
    }

    function getDetailCount(string memory _itemType, uint256 _itemId) public view validItemType(_itemType) returns (uint256) {
        require(_itemId < itemCounts[_itemType], "Item does not exist");
        return items[_itemType][_itemId].positions.length;
    }

    function getItemDetail(string memory _itemType, uint256 _itemId, uint256 _detailIndex) public view validItemType(_itemType) returns (
        string memory x,
        string memory y,
        string memory color
    ) {
        require(_itemId < itemCounts[_itemType], "Item does not exist");
        ItemDetail storage item = items[_itemType][_itemId];
        require(_detailIndex < item.positions.length, "Detail index out of bounds");
        
        PositionDetail storage position = item.positions[_detailIndex];
        return (position.x, position.y, position.color);
    }

    function getItemCount(string memory _itemType) public view validItemType(_itemType) returns (uint256) {
        return itemCounts[_itemType];
    }

    function createRect(PositionDetail memory detail) public pure returns (string memory) {
        return string(
            abi.encodePacked(
                '<rect ',
                'x="', detail.x, '" ',
                'y="', detail.y, '" ',
                'width="', toString(PIXEL_SIZE), '" ',
                'height="', toString(PIXEL_SIZE), '" ',
                'fill="', detail.color, '" ',
                '/>'
            )
        );
    }

    function createMultipleRects(PositionDetail[] memory details) internal pure returns (string memory) {
        string memory rects = "";
        for(uint i = 0; i < details.length; i++) {
            rects = string(abi.encodePacked(rects, createRect(details[i])));
        }
        return rects;
    }

    function createFullSVGWithGrid(PositionDetail[] memory details) public returns (string memory) {
        string memory pixels = createMultipleRects(details);
        
        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" ',
                'viewBox="0 0 ', toString(GRID_SIZE * PIXEL_SIZE), ' ', toString(GRID_SIZE * PIXEL_SIZE), '">',
                '<style>',
                '.pixel { transition: all 0.3s; }',
                '.pixel:hover { filter: brightness(1.2); }',
                '</style>',
                '<g class="pixels">',
                pixels,
                '</g>',
                '</svg>'
            )
        );

        emit SVGGenerated(msg.sender, block.timestamp);
        return svg;
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

    // Handle shuffle element in Array
    function shuffleArray(uint256 tokenId, ItemDetail[] memory arrayToShuffle) public view returns (ItemDetail[] memory) {
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

    //=============== Core function ===============
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
    //=================================================


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
                        '}'
                    )
                )
            )
        );
    }
}