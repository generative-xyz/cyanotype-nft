// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;


contract CharacterInfo  {

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

    function createMultipleRects(uint8[] memory positions) internal pure returns (string memory) {
        string memory rects = "";
        for(uint i = 0; i < positions.length; i += 5) {
            rects = string(abi.encodePacked(
                rects,
                createRect(
                    positions[i],
                    positions[i+1],
                    positions[i+2],
                    positions[i+3],
                    positions[i+4]
                )
            ));
        }
        return rects;
    }

    function createFullSVGWithGrid(uint8[] memory positions) public pure returns (string memory) {
        string memory pixels = createMultipleRects(positions);

        string memory svg = string(
            abi.encodePacked(
                '<svg xmlns="http://www.w3.org/2000/svg" ',
                'viewBox="0 0 24 24">',
                pixels,
                '</svg>'
            )
        );

        return svg;
    }

    function renderSVG(string memory _itemType, uint16 _itemId) public view validItemType(_itemType) returns (string memory) {
        return createFullSVGWithGrid(items[_itemType][_itemId].positions);
    }

    // =============== Help function ===============
    function shuffleArray(uint16 tokenId, ItemDetail[] memory arrayToShuffle) public view returns (ItemDetail[] memory) {
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
  
}