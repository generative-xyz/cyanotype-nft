// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import '@openzeppelin/contracts/utils/Base64.sol';
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "../interfaces/ICryptoAIData.sol";
import "../interfaces/IAgentNFT.sol";
import "../libs/structs/CryptoAIStructs.sol";
import "../libs/helpers/Errors.sol";
import "hardhat/console.sol";

contract CryptoAIData is OwnableUpgradeable, ICryptoAIData {
    // super admin
    address public _admin;
    // deployer
    address public _deployer;
    // crypto ai agent address
    address public _cryptoAIAgentAddr;

    bool private _contractSealed;
    mapping(uint256 => CryptoAIStructs.Token) private unlockedTokens;

    uint256 public constant TOKEN_LIMIT = 0x3E8;
    string private constant svgDataType = 'data:image/svg+xml;base64,';
    uint8 internal constant GRID_SIZE = 0x18;
    string internal constant SVG_HEADER = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">';
    string internal constant SVG_FOOTER = '</svg>';
    string internal constant SVG_Y = '" y="';
    bytes16 internal constant _HEX_SYMBOLS = "0123456789abcdef";
    string internal constant SVG_WIDTH = '" width="1" height="1" fill="#';
    string internal constant SVG_RECT = '<rect x="';
    string internal constant SVG_CLOSE_RECT = '"/>';
    // placeholder
    string private constant htmlDataType = 'data:text/html;base64,';
    string internal constant PLACEHOLDER_HEADER = "<script>let TokenID='";
    string internal constant PLACEHOLDER_FOOTER = "'</script>";
    string internal PLACEHOLDER_IMAGE;

    string[] private VALID_ITEM_TYPES;
    mapping(string => mapping(uint16 => CryptoAIStructs.ItemDetail)) private items;
    mapping(string => mapping(uint16 => CryptoAIStructs.ItemDetail)) private DNA_Variants;
    string[] public DNA_TYPE;
    mapping(string => uint16) private itemCounts;
    mapping(string => uint16) private dnaCounts;


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

    modifier unsealed() {
        require(!_contractSealed, Errors.CONTRACT_SEALED);
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

    modifier onlyAIAgentContract() {
        require(msg.sender == _cryptoAIAgentAddr, Errors.ONLY_ADMIN_ALLOWED);
        _;
    }

    function initialize(
        address deployer,
        address admin
    ) initializer
    public {
        VALID_ITEM_TYPES = ["body", "mouth", "eye", "head"];
        _deployer = deployer;
        _admin = admin;

        __Ownable_init();
    }

    function changeAdmin(address newAdm)
    external
    onlyAdmin unsealed {
        require(newAdm != Errors.ZERO_ADDR, Errors.ONLY_ADMIN_ALLOWED);
        if (_admin != newAdm) {
            address _previousAdmin = _admin;
            _admin = newAdm;
        }
    }

    function changeDeployer(address newAdm)
    external
    onlyAdmin unsealed {
        require(newAdm != Errors.ZERO_ADDR, Errors.INV_ADD);
        if (_deployer != newAdm) {
            _deployer = newAdm;
        }
    }

    function changePlaceHolder(string memory content)
    external
    onlyDeployer unsealed {
        PLACEHOLDER_IMAGE = content;
    }

    function changeCryptoAIAgentAddress(address newAddr)
    external
    onlyDeployer unsealed {
        require(newAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        if (_cryptoAIAgentAddr != newAddr) {
            _cryptoAIAgentAddr = newAddr;
        }
    }

    function sealContract()
    external
    onlyAdmin unsealed {
        _contractSealed = true;
    }

    function mintAgent(uint256 tokenId)
    external
    onlyAIAgentContract
    () {
        // agent is minted on nft collection, but not unlock render svg by rarity info
        require(_cryptoAIAgentAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(unlockedTokens[tokenId].tokenID == 0, Errors.TOKEN_ID_UNLOCKED);

        unlockedTokens[tokenId] = CryptoAIStructs.Token(tokenId, 0);
    }

    function unlockRenderAgent(uint256 tokenId)
    external
    onlyAIAgentContract
    () {
        // agent is minted on nft collection, and unlock render svg by rarity info
        require(unlockedTokens[tokenId].tokenID > 0, Errors.TOKEN_ID_UNLOCKED);
        IMintableAgent nft = IMintableAgent(_cryptoAIAgentAddr);
        (uint256 point, uint256 timeLine) = nft.getAgentRating(tokenId);
        unlockedTokens[tokenId].rarity = calculateRarity(tokenId, point * timeLine);
        // TODO
    }

    function calculateRarity(uint256 tokenId, uint256 weight)
    internal pure
    returns (uint256) {
        return ((tokenId % 10) + 1) * weight;
    }

    function getTokenRarity(uint256 tokenId) external
    view returns
    (uint256) {
        require(unlockedTokens[tokenId].tokenID > 0, Errors.TOKEN_ID_NOT_UNLOCKED);
        return unlockedTokens[tokenId].rarity;
    }

    function tokenURI(uint256 tokenId)
    external view
    returns (string memory result) {
        require(tokenId < TOKEN_LIMIT, "Token ID out of bounds");
        // TODO
        require(unlockedTokens[tokenId].tokenID > 0 || true, Errors.TOKEN_ID_NOT_UNLOCKED);
        string memory base64 = "";
        if (unlockedTokens[tokenId].rarity == 0 && false) {
            base64 = Base64.encode(
                abi.encodePacked(
                    '{"animation_url": "',
                    this.cryptoAIImageHtml(tokenId),
                    '}'
                )
            );
        }
        else {
            base64 = Base64.encode(
                abi.encodePacked(
                    '{"image": "', this.cryptoAIImageSvg(tokenId),
                    '", "attributes": ', this.cryptoAIAttributes(tokenId), '}'
                )
            );
        }
        result = string(abi.encodePacked('data:application/json;base64,', base64));
    }

    ///////  DATA assets + rendering //////
    function addDNA(string memory dnaType) public returns (string memory dna) {
        DNA_TYPE.push(dnaType);
        return dnaType;
    }

    function getDNA(uint8 indexDNA) public view returns (string memory) {
        return DNA_TYPE[indexDNA];
    }

    function addDNAVariant(string memory _DNAType, string memory _DNAName, uint8 _trait, uint8[] memory _positions) public
    onlyDeployer
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
    onlyDeployer unsealed
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

    function cryptoAIAttributes(uint256 tokenId)
    external view
    returns (string memory text) {
        // uint256 rarity = unlockedTokens[tokenId].rarity;
        // TODO:  from rarity;
        uint256 rarity = tokenId;
        string memory DNAType = DNA_TYPE[randomIndex(DNA_TYPE.length, rarity)];// TODO
        CryptoAIStructs.ItemDetail[] memory dnaItem = getArrayDNAVariant(DNAType);

        CryptoAIStructs.ItemDetail memory dna_po = dnaItem[randomIndex(dnaItem.length, rarity)];
        CryptoAIStructs.ItemDetail memory body_po = items['body'][uint16(randomIndex(itemCounts['body'], randomIndex(rarity, dna_po.positions.length)))];
        CryptoAIStructs.ItemDetail memory head_po = items['head'][uint16(randomIndex(itemCounts['head'], randomIndex(rarity, body_po.positions.length)))];
        CryptoAIStructs.ItemDetail memory eye_po = items['eye'][uint16(randomIndex(itemCounts['eye'], randomIndex(rarity, head_po.positions.length)))];
        CryptoAIStructs.ItemDetail memory mouth_po = items['mouth'][uint16(randomIndex(itemCounts['mouth'], randomIndex(rarity, eye_po.positions.length)))];

        CryptoAIStructs.Attribute[] memory items = new CryptoAIStructs.Attribute[](5);
        items[0] = CryptoAIStructs.Attribute("DNA", dna_po);
        items[1] = CryptoAIStructs.Attribute("Body", body_po);
        items[2] = CryptoAIStructs.Attribute("Head", head_po);
        items[3] = CryptoAIStructs.Attribute("Eye", eye_po);
        items[4] = CryptoAIStructs.Attribute("Mouth", mouth_po);

        bytes memory byteString ;
        uint count = 0;

        for (uint8 i = 0; i < items.length; i++) {
            if( items[i].item.positions.length > 0) {
                bytes memory objString = abi.encodePacked(
                    '{"trait":"',
                    items[i].trait,
                    '","value":"',
                    items[i].item.name,
                    '"}'
                );
                if (i > 0) {
                    byteString = abi.encodePacked(byteString, ",");
                }
                byteString = abi.encodePacked(byteString, objString);
                count++;
            }
        }

        byteString = abi.encodePacked(
            '{"trait": "attributes"',
            ',"value":"',
            StringsUpgradeable.toString(count),
            '"},'
            ,byteString
        );

        text = string(abi.encodePacked('[', string(byteString), ']'));
    }

    function cryptoAIImage(uint256 tokenId)
    public view
    returns (bytes memory) {
        // uint256 rarity = unlockedTokens[tokenId].rarity;
        // TODO:  from rarity;

        uint256 rarity = tokenId;

        string memory DNAType = DNA_TYPE[randomIndex(DNA_TYPE.length, rarity)];// TODO
        CryptoAIStructs.ItemDetail[] memory dnaItem = getArrayDNAVariant(DNAType);

        uint8[] memory dna_po = dnaItem[randomIndex(dnaItem.length, rarity)].positions;
        uint8[] memory body_po = items['body'][uint16(randomIndex(itemCounts['body'], randomIndex(rarity, dna_po.length)))].positions;
        uint8[] memory head_po = items['head'][uint16(randomIndex(itemCounts['head'], randomIndex(rarity, body_po.length)))].positions;
        uint8[] memory eye_po = items['eye'][uint16(randomIndex(itemCounts['eye'], randomIndex(rarity, head_po.length)))].positions;
        uint8[] memory mouth_po = items['mouth'][uint16(randomIndex(itemCounts['mouth'], randomIndex(rarity, eye_po.length)))].positions;

        bytes memory pixels = new bytes(2304);
        uint idx;
        uint totalLength = dna_po.length + body_po.length + head_po.length + eye_po.length + mouth_po.length;

        uint8[] memory pos;

        uint16 p;
        uint16 positionLength = uint16(dna_po.length);

        for (uint i = 0; i < totalLength; i += 5) {
            if (i < positionLength) {
                pos = dna_po;
                idx = i;
            } else if (i < positionLength + body_po.length) {
                pos = body_po;
                idx = i - positionLength;
            } else if (i < positionLength + body_po.length + head_po.length) {
                pos = head_po;
                idx = i - positionLength - body_po.length;
            } else if (i < positionLength + body_po.length + head_po.length + eye_po.length) {
                pos = eye_po;
                idx = i - positionLength - body_po.length - head_po.length;
            } else {
                pos = mouth_po;
                idx = i - positionLength - body_po.length - head_po.length - eye_po.length;
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

    function cryptoAIImageHtml(uint256 tokenId)
    external view
    returns (string memory result) {
        return string(abi.encodePacked(
            htmlDataType,
            Base64.encode(
                abi.encodePacked(
                    PLACEHOLDER_HEADER,
                    tokenId,
                    PLACEHOLDER_FOOTER,
                    PLACEHOLDER_IMAGE
                )
            )
        ));
    }

    function cryptoAIImageSvg(uint256 tokenId)
    external view
        // onlyAIAgentContract
    returns (string memory result) {
        bytes memory pixels = cryptoAIImage(tokenId);
        string memory svg = '';
        uint temp;
        uint8 x;
        uint8 y;
        uint p;
        bytes memory buffer = new bytes(8);
        for (uint i = 0; i < pixels.length; i += 4) {
            if (pixels[i + 3] > 0) {
                assembly {
                    temp := shr(2, i)
                    x := mod(temp, GRID_SIZE)
                    y := div(temp, GRID_SIZE)
                }
                if (x < GRID_SIZE && y < GRID_SIZE) {
                    p = (uint(y) * 24 + uint(x)) * 4;
                    /*
                    for (uint k = 0; k < 4; k++) {
                        uint8 value = uint8(pixels[p + k]);
                        buffer[k * 2 + 1] = _HEX_SYMBOLS[value & 0xf];
                        value >>= 4;
                        buffer[k * 2] = _HEX_SYMBOLS[value & 0xf];
                    }
                    */
                    assembly {
                        let hexSymbols := _HEX_SYMBOLS
                        let bufferPtr := add(buffer, 0x20)
                        let pixelsPtr := add(add(pixels, 0x20), p)
                        for {let k := 0} lt(k, 4) {k := add(k, 1)} {
                            let value := byte(0, mload(add(pixelsPtr, k)))
                            mstore8(add(bufferPtr, add(mul(k, 2), 1)), byte(and(value, 0xf), hexSymbols))
                            value := shr(4, value)
                            mstore8(add(bufferPtr, mul(k, 2)), byte(and(value, 0xf), hexSymbols))
                        }
                    }

                    svg = string(abi.encodePacked(
                        svg,
                        abi.encodePacked(
                            SVG_RECT,
                            StringsUpgradeable.toString(x),
                            SVG_Y,
                            StringsUpgradeable.toString(y),
                            SVG_WIDTH,
                            string(buffer),
                            SVG_CLOSE_RECT
                        )
                    ));
                }
            }
        }

        result = string(abi.encodePacked(svgDataType, Base64.encode(abi.encodePacked(SVG_HEADER, svg, SVG_FOOTER))));
    }


    function getArrayDNAVariant(string memory _DNAType) public view returns (CryptoAIStructs.ItemDetail[] memory DNAItems) {
        uint16 count = dnaCounts[_DNAType];
        DNAItems = new CryptoAIStructs.ItemDetail[](count);
        for (uint16 i = 0; i < count; i++) {
            DNAItems[i] = DNA_Variants[_DNAType][i];
        }
    }

    function randomIndex(uint256 maxLength, uint256 tokenId) internal view returns (uint) {
        if (maxLength == 0) return 0;
        uint256 randomNumber = uint256(keccak256(abi.encodePacked(tokenId)));
        return randomNumber % maxLength;
    }
}