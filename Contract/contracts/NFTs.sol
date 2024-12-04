// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CharacterInfo {
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

    uint constant PIXEL_SIZE = 24;
    uint constant GRID_SIZE = 24;
    
    event SVGGenerated(address indexed creator, uint timestamp);
    event ItemAdded(string itemType, uint256 indexed itemId, string name, string trait);

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
}