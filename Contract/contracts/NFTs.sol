// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CharacterInfo {
    struct PositionDetail {
        uint8 x;      // 0-24
        uint8 y;      // 0-24
        uint8 colorId; // Index into colors array
    }

    struct ItemDetail {
        string name;
        uint8 trait;  // 0-200
        PositionDetail[] positions;
    }

    // Mappings for each item type
    mapping(string => mapping(uint256 => ItemDetail)) private items;
    mapping(string => uint256) private itemCounts;

    // Color palette storage
    string[] private colors;
    
    uint constant PIXEL_SIZE = 24;
    uint constant GRID_SIZE = 24;
    
    event SVGGenerated(address indexed creator, uint timestamp);
    event ItemAdded(string itemType, uint256 indexed itemId, string name, uint8 trait);
    event ColorAdded(uint256 indexed colorId, string color);

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

    function addColor(string memory _color) public returns (uint256) {
        colors.push(_color);
        uint256 colorId = colors.length - 1;
        emit ColorAdded(colorId, _color);
        return colorId;
    }

    function getColor(uint8 _colorId) public view returns (string memory) {
        require(_colorId < colors.length, "Color does not exist");
        return colors[_colorId];
    }

    function addItem(
        string memory _itemType,
        string memory _name,
        uint8 _trait,
        uint8[] memory _xArray,
        uint8[] memory _yArray,
        uint8[] memory _colorIdArray
    ) public validItemType(_itemType) returns (uint256) {
        require(
            _xArray.length == _yArray.length && 
            _yArray.length == _colorIdArray.length,
            "Arrays must have same length"
        );
        require(_trait <= 200, "Trait must be <= 200");

        for(uint i = 0; i < _xArray.length; i++) {
            require(_xArray[i] <= 24, "X coordinate must be <= 24");
            require(_yArray[i] <= 24, "Y coordinate must be <= 24");
            require(_colorIdArray[i] < colors.length, "Invalid color ID");
        }

        uint256 itemId = itemCounts[_itemType]++;
        ItemDetail storage item = items[_itemType][itemId];
        
        item.name = _name;
        item.trait = _trait;

        for(uint i = 0; i < _xArray.length; i++) {
            item.positions.push(PositionDetail({
                x: _xArray[i],
                y: _yArray[i],
                colorId: _colorIdArray[i]
            }));
        }

        emit ItemAdded(_itemType, itemId, _name, _trait);
        return itemId;
    }

    function getItem(string memory _itemType, uint256 _itemId) public view validItemType(_itemType) returns (
        string memory name,
        uint8 trait,
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
        uint8 x,
        uint8 y,
        uint8 colorId
    ) {
        require(_itemId < itemCounts[_itemType], "Item does not exist");
        ItemDetail storage item = items[_itemType][_itemId];
        require(_detailIndex < item.positions.length, "Detail index out of bounds");
        
        PositionDetail storage position = item.positions[_detailIndex];
        return (position.x, position.y, position.colorId);
    }

    function getItemCount(string memory _itemType) public view validItemType(_itemType) returns (uint256) {
        return itemCounts[_itemType];
    }

    function createRect(PositionDetail memory detail) public view returns (string memory) {
        return string(
            abi.encodePacked(
                '<rect ',
                'x="', toString(detail.x), '" ',
                'y="', toString(detail.y), '" ',
                'width="', toString(PIXEL_SIZE), '" ',
                'height="', toString(PIXEL_SIZE), '" ',
                'fill="', colors[detail.colorId], '" ',
                '/>'
            )
        );
    }

    function createMultipleRects(PositionDetail[] memory details) internal view returns (string memory) {
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
}