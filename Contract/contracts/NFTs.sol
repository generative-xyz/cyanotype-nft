// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract CharacterInfo {
    struct PositionDetail {
        string x;      // độ cầu
        string y;      // độ loạn
        string color;  // màu sắc
    }

    struct ItemDetail {
        string name;           // tên mẫu
        string trait;          // đặc điểm
        PositionDetail[] positions;   // mảng chứa thông tin chi tiết
    }

    // Mapping để lưu trữ thông tin các bộ phận theo ID
    mapping(uint256 => ItemDetail) public glasses;
    mapping(uint256 => ItemDetail) public heads;
    mapping(uint256 => ItemDetail) public bodies;
    mapping(uint256 => ItemDetail) public hands;
    mapping(uint256 => ItemDetail) public footers;
    mapping(uint256 => ItemDetail) public hairs;
    mapping(uint256 => ItemDetail) public eyes;

    uint256 public glassCount;
    uint256 public headCount;
    uint256 public bodyCount;
    uint256 public handCount;
    uint256 public footerCount;
    uint256 public hairCount;
    uint256 public eyeCount;

    // Constant values
    uint constant PIXEL_SIZE = 24;
    uint constant GRID_SIZE = 24;
    
    // Events
    event SVGGenerated(address indexed creator, uint timestamp);

    // Events
    event ItemAdded(
        string itemType,
        uint256 indexed itemId,
        string name,
        string trait
    );

    // Hàm helper để thêm mới thông tin
    function addItem(
        string memory _itemType,
        string memory _name,
        string memory _trait,
        string[] memory _xArray,
        string[] memory _yArray,
        string[] memory _colorArray
    ) internal returns (uint256) {
        require(
            _xArray.length == _yArray.length && 
            _yArray.length == _colorArray.length,
            "Arrays must have same length"
        );

        uint256 itemId;
        ItemDetail storage item;

        if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("glass"))) {
            itemId = glassCount++;
            item = glasses[itemId];
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("head"))) {
            itemId = headCount++;
            item = heads[itemId];
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("body"))) {
            itemId = bodyCount++;
            item = bodies[itemId];
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("hand"))) {
            itemId = handCount++;
            item = hands[itemId];
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("footer"))) {
            itemId = footerCount++;
            item = footers[itemId];
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("hair"))) {
            itemId = hairCount++;
            item = hairs[itemId];
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("eye"))) {
            itemId = eyeCount++;
            item = eyes[itemId];
        } else {
            revert("Invalid item type");
        }
        
        item.name = _name;
        item.trait = _trait;

        // Thêm thông tin chi tiết
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

    // Các hàm thêm mới cho từng loại
    function addGlass(string memory _name, string memory _trait, string[] memory _xArray, string[] memory _yArray, string[] memory _colorArray) public returns (uint256) {
        return addItem("glass", _name, _trait, _xArray, _yArray, _colorArray);
    }

    function addHead(string memory _name, string memory _trait, string[] memory _xArray, string[] memory _yArray, string[] memory _colorArray) public returns (uint256) {
        return addItem("head", _name, _trait, _xArray, _yArray, _colorArray);
    }

    function addBody(string memory _name, string memory _trait, string[] memory _xArray, string[] memory _yArray, string[] memory _colorArray) public returns (uint256) {
        return addItem("body", _name, _trait, _xArray, _yArray, _colorArray);
    }

    function addHand(string memory _name, string memory _trait, string[] memory _xArray, string[] memory _yArray, string[] memory _colorArray) public returns (uint256) {
        return addItem("hand", _name, _trait, _xArray, _yArray, _colorArray);
    }

    function addFooter(string memory _name, string memory _trait, string[] memory _xArray, string[] memory _yArray, string[] memory _colorArray) public returns (uint256) {
        return addItem("footer", _name, _trait, _xArray, _yArray, _colorArray);
    }

    function addHair(string memory _name, string memory _trait, string[] memory _xArray, string[] memory _yArray, string[] memory _colorArray) public returns (uint256) {
        return addItem("hair", _name, _trait, _xArray, _yArray, _colorArray);
    }

    function addEye(string memory _name, string memory _trait, string[] memory _xArray, string[] memory _yArray, string[] memory _colorArray) public returns (uint256) {
        return addItem("eye", _name, _trait, _xArray, _yArray, _colorArray);
    }

    // Hàm helper để lấy thông tin
    function getItem(string memory _itemType, uint256 _itemId) internal view returns (
        string memory name,
        string memory trait,
        PositionDetail[] memory positions
    ) {
        ItemDetail storage item;
        uint256 count;

        if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("glass"))) {
            item = glasses[_itemId];
            count = glassCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("head"))) {
            item = heads[_itemId];
            count = headCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("body"))) {
            item = bodies[_itemId];
            count = bodyCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("hand"))) {
            item = hands[_itemId];
            count = handCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("footer"))) {
            item = footers[_itemId];
            count = footerCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("hair"))) {
            item = hairs[_itemId];
            count = hairCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("eye"))) {
            item = eyes[_itemId];
            count = eyeCount;
        } else {
            revert("Invalid item type");
        }

        require(_itemId < count, "Item does not exist");
        return (item.name, item.trait, item.positions);
    }

    // Các hàm lấy thông tin cho từng loại
    function getGlass(uint256 _glassId) public view returns (string memory name, string memory trait, PositionDetail[] memory positions) {
        return getItem("glass", _glassId);
    }

    function getHead(uint256 _headId) public view returns (string memory name, string memory trait, PositionDetail[] memory positions) {
        return getItem("head", _headId);
    }

    function getBody(uint256 _bodyId) public view returns (string memory name, string memory trait, PositionDetail[] memory positions) {
        return getItem("body", _bodyId);
    }

    function getHand(uint256 _handId) public view returns (string memory name, string memory trait, PositionDetail[] memory positions) {
        return getItem("hand", _handId);
    }

    function getFooter(uint256 _footerId) public view returns (string memory name, string memory trait, PositionDetail[] memory positions) {
        return getItem("footer", _footerId);
    }

    function getHair(uint256 _hairId) public view returns (string memory name, string memory trait, PositionDetail[] memory positions) {
        return getItem("hair", _hairId);
    }

    function getEye(uint256 _eyeId) public view returns (string memory name, string memory trait, PositionDetail[] memory positions) {
        return getItem("eye", _eyeId);
    }

    // Hàm helper để lấy số lượng chi tiết
    function getDetailCount(string memory _itemType, uint256 _itemId) internal view returns (uint256) {
        ItemDetail storage item;
        uint256 count;

        if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("glass"))) {
            item = glasses[_itemId];
            count = glassCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("head"))) {
            item = heads[_itemId];
            count = headCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("body"))) {
            item = bodies[_itemId];
            count = bodyCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("hand"))) {
            item = hands[_itemId];
            count = handCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("footer"))) {
            item = footers[_itemId];
            count = footerCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("hair"))) {
            item = hairs[_itemId];
            count = hairCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("eye"))) {
            item = eyes[_itemId];
            count = eyeCount;
        } else {
            revert("Invalid item type");
        }

        require(_itemId < count, "Item does not exist");
        return item.positions.length;
    }

    // Các hàm lấy số lượng chi tiết cho từng loại
    function getGlassDetailCount(uint256 _glassId) public view returns (uint256) {
        return getDetailCount("glass", _glassId);
    }

    function getHeadDetailCount(uint256 _headId) public view returns (uint256) {
        return getDetailCount("head", _headId);
    }

    function getBodyDetailCount(uint256 _bodyId) public view returns (uint256) {
        return getDetailCount("body", _bodyId);
    }

    function getHandDetailCount(uint256 _handId) public view returns (uint256) {
        return getDetailCount("hand", _handId);
    }

    function getFooterDetailCount(uint256 _footerId) public view returns (uint256) {
        return getDetailCount("footer", _footerId);
    }

    function getHairDetailCount(uint256 _hairId) public view returns (uint256) {
        return getDetailCount("hair", _hairId);
    }

    function getEyeDetailCount(uint256 _eyeId) public view returns (uint256) {
        return getDetailCount("eye", _eyeId);
    }

    // Hàm helper để lấy thông tin chi tiết cụ thể
    function getItemDetail(string memory _itemType, uint256 _itemId, uint256 _detailIndex) internal view returns (
        string memory x,
        string memory y,
        string memory color
    ) {
        ItemDetail storage item;
        uint256 count;

        if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("glass"))) {
            item = glasses[_itemId];
            count = glassCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("head"))) {
            item = heads[_itemId];
            count = headCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("body"))) {
            item = bodies[_itemId];
            count = bodyCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("hand"))) {
            item = hands[_itemId];
            count = handCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("footer"))) {
            item = footers[_itemId];
            count = footerCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("hair"))) {
            item = hairs[_itemId];
            count = hairCount;
        } else if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked("eye"))) {
            item = eyes[_itemId];
            count = eyeCount;
        } else {
            revert("Invalid item type");
        }

        require(_itemId < count, "Item does not exist");
        require(_detailIndex < item.positions.length, "Detail index out of bounds");
        
        PositionDetail storage position = item.positions[_detailIndex];
        return (position.x, position.y, position.color);
    }

    // Các hàm lấy thông tin chi tiết cụ thể cho từng loại
    function getGlassDetail(uint256 _glassId, uint256 _detailIndex) public view returns (string memory x, string memory y, string memory color) {
        return getItemDetail("glass", _glassId, _detailIndex);
    }

    function getHeadDetail(uint256 _headId, uint256 _detailIndex) public view returns (string memory x, string memory y, string memory color) {
        return getItemDetail("head", _headId, _detailIndex);
    }

    function getBodyDetail(uint256 _bodyId, uint256 _detailIndex) public view returns (string memory x, string memory y, string memory color) {
        return getItemDetail("body", _bodyId, _detailIndex);
    }

    function getHandDetail(uint256 _handId, uint256 _detailIndex) public view returns (string memory x, string memory y, string memory color) {
        return getItemDetail("hand", _handId, _detailIndex);
    }

    function getFooterDetail(uint256 _footerId, uint256 _detailIndex) public view returns (string memory x, string memory y, string memory color) {
        return getItemDetail("footer", _footerId, _detailIndex);
    }

    function getHairDetail(uint256 _hairId, uint256 _detailIndex) public view returns (string memory x, string memory y, string memory color) {
        return getItemDetail("hair", _hairId, _detailIndex);
    }

    function getEyeDetail(uint256 _eyeId, uint256 _detailIndex) public view returns (string memory x, string memory y, string memory color) {
        return getItemDetail("eye", _eyeId, _detailIndex);
    }

    // Function to get the length of eyes
    function getEyesLength() public view returns (uint256) {
        return eyeCount;
    }

    function getBodiesLength() public view returns (uint256) {
        return bodyCount;
    }

    function getHeadsLength() public view returns (uint256) {
        return headCount;
    }
    function getHandsLength() public view returns (uint256) {
        return handCount;
    }

    function getFootersLength() public view returns (uint256) {
        return footerCount;
    }

    function getHairsLength() public view returns (uint256) {
        return hairCount;
    }

    function getGlassesLength() public view returns (uint256) {
        return glassCount;
    }

    // Function to create multiple rectangles from position details
    function createMultipleRects(PositionDetail[] memory details) internal pure returns (string memory) {
        string memory rects = "";
        for(uint i = 0; i < details.length; i++) {
            rects = string(abi.encodePacked(rects, createRect(details[i])));
        }
        return rects;
    }

    // Hàm tạo rect với nhiều thuộc tính hơn
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

    // Tạo SVG với grid background
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

    // Helper functions...
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