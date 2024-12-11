// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import '@openzeppelin/contracts/utils/Base64.sol';
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "../interfaces/ICryptoAIData.sol";
import "../interfaces/IAgentNFT.sol";
import "../libs/structs/CryptoAIStructsLibs.sol";
import "../libs/helpers/Errors.sol";
import "hardhat/console.sol";
contract CryptoAIData is OwnableUpgradeable, ICryptoAIData {
    // super admin
    address public _admin;
    // deployer
    address public _deployer;
    // crypto ai agent address
    address public _cryptoAIAgentAddr;

    string private constant baseURL = 'data:image/svg+xml;base64,';
    string[] private VALID_ITEM_TYPES;
    uint8 internal constant GRID_SIZE = 24;
    string internal constant SVG_HEADER = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">';
    string internal constant SVG_FOOTER = '</svg>';
    string internal constant SVG_Y = '" y="';
    string internal constant SVG_WIDTH = '" width="1" height="1" fill="rgb(';
    string internal constant SVG_RECT = '<rect x="';
    string internal constant SVG_CLOSE_RECT = ')" />';
//    string internal PLACEHOLDER_IMAGE = '';

    mapping(string => mapping(uint16 => CryptoAIStructs.ItemDetail)) private items;
    mapping(string => mapping(uint16 => CryptoAIStructs.ItemDetail)) private DNA_Variants;
    mapping(string => uint16) private itemCounts;
    mapping(string => uint16) private dnaCounts;

    string[] public DNA_TYPE;

    modifier validItemType(string memory _itemType) {
        bool isValid;
        for (uint i = 0; i < VALID_ITEM_TYPES.length; i++) {
            if (keccak256(abi.encodePacked(_itemType)) == keccak256(abi.encodePacked(VALID_ITEM_TYPES[i]))) {
                isValid = true;
                break;
            }
        }
        require(isValid, Errors.INVALID_ITEM_TYPE);
        _;
    }

    modifier onlyDeployer() {
        require(msg.sender == _deployer, Errors.ONLY_DEPLOYER);
        _;
    }

    modifier onlyAdmin() {
        require(msg.sender == _admin, Errors.ONLY_ADMIN_ALLOWED);
        _;
    }

    function initialize(
        address deployer,
        address admin
    ) initializer public {
        VALID_ITEM_TYPES = ["body", "mouth", "eye", "head"];
        _deployer = deployer;
        _admin = admin;

        __Ownable_init();
    }

    function changeAdmin(address newAdm) external onlyAdmin {
        require(newAdm != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);
        if (_admin != newAdm) {
            address _previousAdmin = _admin;
            _admin = newAdm;
        }
    }

    function changeDeployer(address newAdm) external onlyAdmin {
        require(newAdm != Errors.ZERO_ADDR, Errors.INV_ADD);
        if (_deployer != newAdm) {
            _deployer = newAdm;
        }
    }

    function changeCryptoAIAgentAddress(address newAddr) external onlyDeployer {
        require(newAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        if (_cryptoAIAgentAddr != newAddr) {
            _cryptoAIAgentAddr = newAddr;
        }
    }

    ///////
    function addDNA(string memory dnaType) public returns (string memory dna) {
        DNA_TYPE.push(dnaType);
        return dnaType;
    }

    function getDNA(uint8 indexDNA) public view returns (string memory) {
        return DNA_TYPE[indexDNA];
    }

    function addDNAVariant(string memory _DNAType, string memory _DNAName, uint8 _trait, uint8[] memory _positions) public
        //onlyDeployer
    returns (uint16){
        require(_positions.length % 5 == 0, "Invalid positions array length");
        require(_trait <= 200, "Trait must be <= 200");

        uint16 numPixels = uint16(_positions.length / 5);
        for (uint i = 0; i < numPixels; i++) {
            uint index = i * 5;
            require(_positions[index] <= GRID_SIZE, "X coordinate must be <= 24");
            require(_positions[index + 1] <= GRID_SIZE, "Y coordinate must be <= 24");
        }

        uint16 itemId = uint16(dnaCounts[_DNAType]++);

        DNA_Variants[_DNAType][itemId].name = _DNAName;
        DNA_Variants[_DNAType][itemId].trait = _trait;
        DNA_Variants[_DNAType][itemId].positions = _positions;

        emit CryptoAIStructs.DNAVariantAdded(_DNAType, itemId, _DNAName, _trait);
        return itemId;
    }

    function getDNAVariant(string memory _DNAType, uint16 _itemId) public view returns (
        string memory name,
        uint8 trait,
        uint8[] memory positions
    ) {
        require(_itemId < dnaCounts[_DNAType], Errors.ITEM_NOT_EXIST);
        CryptoAIStructs.ItemDetail memory item = DNA_Variants[_DNAType][_itemId];
        return (item.name, item.trait, item.positions);
    }

    function addItem(
        string memory _itemType,
        string memory _name,
        uint8 _trait,
        uint8[] memory _positions
    ) public validItemType(_itemType)
    onlyDeployer
    returns (uint16) {
        require(_positions.length % 5 == 0, "Invalid positions array length");
        require(_trait <= 200, "Trait must be <= 200");

        uint16 numPixels = uint16(_positions.length / 5);
        for (uint i = 0; i < numPixels; i++) {
            uint index = i * 5;
            require(_positions[index] <= GRID_SIZE, "X coordinate must be <= 24");
            require(_positions[index + 1] <= GRID_SIZE, "Y coordinate must be <= 24");
        }

        uint16 itemId = uint16(itemCounts[_itemType]++);

        items[_itemType][itemId].name = _name;
        items[_itemType][itemId].trait = _trait;
        items[_itemType][itemId].positions = _positions;

        emit CryptoAIStructs.ItemAdded(_itemType, itemId, _name, _trait);
        return itemId;
    }

    function getItem(string memory _itemType, uint16 _itemId) public view validItemType(_itemType) returns (CryptoAIStructs.ItemDetail memory) {
        require(_itemId < itemCounts[_itemType], Errors.ITEM_NOT_EXIST);
        CryptoAIStructs.ItemDetail memory item = items[_itemType][_itemId];
        return item;
    }

    //
    function svgToImageURI(string memory svg) internal pure returns (string memory) {
        string memory svgBase64Encoded = Base64.encode(bytes(svg));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    function createMultipleRects(uint8[] memory positions, uint8[] memory positions2, uint8[] memory positions3, uint8[] memory positions4, uint8[] memory positions5) internal pure returns (bytes memory) {
        bytes memory pixels = new bytes(2304);
        uint idx;
        uint totalLength = positions.length + positions2.length + positions3.length + positions4.length + positions5.length;

        uint8[] memory pos;

        uint16 p;
        uint16 positionLength = uint16(positions.length);

        for (uint i = 0; i < totalLength; i += 5) {
            if (i < positionLength) {
                pos = positions;
                idx = i;
            } else if (i < positionLength + positions2.length) {
                pos = positions2;
                idx = i - positionLength;
            } else if (i < positionLength + positions2.length + positions3.length) {
                pos = positions3;
                idx = i - positionLength - positions2.length;
            } else if (i < positionLength + positions2.length + positions3.length + positions4.length) {
                pos = positions4;
                idx = i - positionLength - positions2.length - positions3.length;
            } else {
                pos = positions5;
                idx = i - positionLength - positions2.length - positions3.length - positions4.length;
            }

            // Calculate pixel position
            p = (uint16(pos[idx + 1]) * GRID_SIZE + uint16(pos[idx])) << 2;

            // Set RGBA values directly
            pixels[p] = bytes1(pos[idx + 2]);     // R
            pixels[p + 1] = bytes1(pos[idx + 3]);   // G
            pixels[p + 2] = bytes1(pos[idx + 4]);   // B
            pixels[p + 3] = bytes1(0xFF);         // A
        }

        return pixels;
    }

    function renderFullSVGWithGrid(uint256 tokenId) external view returns (string memory) {
        /*IAgentNFT nft = IAgentNFT(_cryptoAIAgentAddr);
        bool unlocked = nft.checkUnlockedNFT(tokenId);
        if (unlocked) {
            (uint256 point, uint256 timeLine) = nft.checkNFTPoint(tokenId);
        }*/

        // require(tokenId < TOKEN_LIMIT, "Token ID out of bounds");

        uint16 index = uint16(tokenId);

        string memory DNAType = DNA_TYPE[index];

        CryptoAIStructs.ItemDetail[] memory shuffleDNAVariant = shuffleArray(tokenId, getArrayDNAVariant(DNAType));

        CryptoAIStructs.ItemDetail memory body = items['body'][uint16(randomIndex(itemCounts['body'], tokenId))];
        CryptoAIStructs.ItemDetail memory head = items['head'][uint16(randomIndex(itemCounts['head'], tokenId))];
        CryptoAIStructs.ItemDetail memory eye = items['eye'][uint16(randomIndex(itemCounts['eye'], tokenId))];
        CryptoAIStructs.ItemDetail memory mouth = items['mouth'][uint16(randomIndex(itemCounts['mouth'], tokenId))];

        bytes memory pixel = createMultipleRects(shuffleDNAVariant[index].positions, body.positions,head.positions, items['eye'][0].positions,mouth.positions);

        string memory rects = '';
        uint temp = 0;
        uint8 x;
        uint8 y;
        for (uint i = 0; i < pixel.length; i += 4) {
            if (pixel[i + 3] > 0) {
                temp = i >> 2;
                x = uint8(temp % GRID_SIZE);
                y = uint8(temp / GRID_SIZE);
                if (x < GRID_SIZE && y < GRID_SIZE) {
                    rects = string(abi.encodePacked(
                        rects,
                        string(
                            abi.encodePacked(
                                SVG_RECT,
                                StringsUpgradeable.toString(x),
                                SVG_Y,
                                StringsUpgradeable.toString(y),
                                SVG_WIDTH,
                                StringsUpgradeable.toString(uint8(pixel[i])), ',', StringsUpgradeable.toString(uint8(pixel[i + 1])), ',', StringsUpgradeable.toString(uint8(pixel[i + 2])),
                                SVG_CLOSE_RECT
                            )
                        )
                    ));
                }
            }
        }

        string memory svg = string(
            abi.encodePacked(
                SVG_HEADER,
                rects,
                SVG_FOOTER
            )
        );
        return svgToImageURI(svg);
    }

    function shuffleArray(uint256 tokenId, CryptoAIStructs.ItemDetail[] memory arrayToShuffle) public view returns (CryptoAIStructs.ItemDetail[] memory) {
        CryptoAIStructs.ItemDetail[] memory shuffledArray = arrayToShuffle;
        uint256 n = shuffledArray.length;

        for (uint256 i = 0; i < n; i++) {
            uint256 j = i + uint256(keccak256(abi.encode(tokenId, i))) % (n - i);
            (shuffledArray[i], shuffledArray[j]) = (shuffledArray[j], shuffledArray[i]);
        }
        return shuffledArray;
    }

    /*function getArrayItemsType(string memory _itemType) public view returns (CryptoAIStructs.ItemDetail[] memory item) {
        uint16 count = itemCounts[_itemType];
        item = new CryptoAIStructs.ItemDetail[](count);
        for (uint16 i = 0; i < count; i++) {
            item[i] = items[_itemType][i];
        }
    }*/

    function getArrayDNAVariant(string memory _DNAType) public view returns (CryptoAIStructs.ItemDetail[] memory DNAItems) {
        uint16 count = dnaCounts[_DNAType];
        DNAItems = new CryptoAIStructs.ItemDetail[](count);
        for (uint16 i = 0; i < count; i++) {
            DNAItems[i] = DNA_Variants[_DNAType][i];
        }
    }

    function randomIndex(uint256 maxLength, uint256 tokenId) internal view returns (uint) {
        //uint256 seed = seedTokenId[tokenId];
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(tokenId)));
        return randomNumber % maxLength;
    }

    // 0 => not unlock => tra ve placeholder URL IPFS => only one can update
    // 1 => unlock roi chua mint => mapping range point
    // 2 => unlock va duoc mint
}