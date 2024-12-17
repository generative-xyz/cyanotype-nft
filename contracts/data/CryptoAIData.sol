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
    mapping(string => CryptoAIStructs.ItemDetail) private items;
    mapping(string => CryptoAIStructs.ItemDetail) private DNA_Variants;
    mapping(bytes32 => bool) private usedPairs;

    uint256 public constant TOKEN_LIMIT = 0x3E8;
    uint8 internal constant GRID_SIZE = 0x18;
    bytes16 internal constant _HEX_SYMBOLS = "0123456789abcdef";
    string private constant jsonDataType = "data:application/json;base64,";
    string private constant svgDataType = 'data:image/svg+xml;utf8,';
    string internal constant SVG_HEADER = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'>";
    string internal constant SVG_FOOTER = '</svg>';
    string internal constant SVG_RECT = "<rect x='";
    string internal constant SVG_Y = "' y='";
    string internal constant SVG_WIDTH = "' width='1' height='1' fill='%23";
    string internal constant SVG_CLOSE_RECT = "'/>";
    // placeholder
    string private constant htmlDataType = 'data:text/html;base64,';
    string internal constant PLACEHOLDER_HEADER = "<script>let TokenID='";
    string internal constant PLACEHOLDER_FOOTER = "'</script>";
    string internal PLACEHOLDER_IMAGE;

    string[] private VALID_ITEM_TYPES;
    CryptoAIStructs.DNA_TYPE[] public DNA_TYPE;

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
        /* TODO: uncomment when deploy
    require(msg.sender == _cryptoAIAgentAddr, Errors.ONLY_ADMIN_ALLOWED);
    */
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
        /* TODO: uncomment when deploy
        require(_cryptoAIAgentAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(unlockedTokens[tokenId].tokenID == 0, Errors.TOKEN_ID_NOT_UNLOCKED);
        */
        unlockedTokens[tokenId].tokenID = tokenId;
    }

    function unlockRenderAgent(uint256 tokenId)
    external
    onlyAIAgentContract
    () {
        // agent is minted on nft collection, and unlock render svg by rarity info
        IMintableAgent nft = IMintableAgent(_cryptoAIAgentAddr);
        /* TODO: uncomment when deploy
        require(_cryptoAIAgentAddr != Errors.ZERO_ADDR, Errors.INV_ADD);
        require(unlockedTokens[tokenId].tokenID > 0, Errors.TOKEN_ID_NOT_UNLOCKED);
        require(unlockedTokens[tokenId].rarity == 0, Errors.TOKEN_ID_UNLOCKED);
        unlockedTokens[tokenId].weight = nft.getAgentRarity(tokenId);
        */
        unlockedTokens[tokenId].weight = 100000;
        uint256 dna;
        uint256 body;
        uint256 head;
        uint256 eye;
        uint256 mouth;
        bytes32 pairHash;
        CryptoAIStructs.DNA_TYPE memory DNAType = DNA_TYPE[0];// TODO
        do {
            dna = selectTrait(items[DNAType.name], unlockedTokens[tokenId].weight);
            body = selectTrait(items["body"], unlockedTokens[tokenId].weight);
            head = selectTrait(items["head"], unlockedTokens[tokenId].weight);
            eye = selectTrait(items["eye"], unlockedTokens[tokenId].weight);
            mouth = selectTrait(items["mouth"], unlockedTokens[tokenId].weight);
            pairHash = keccak256(abi.encodePacked(dna, body, head, eye, mouth));
        }
        while (usedPairs[pairHash]);

        unlockedTokens[tokenId].traits["dna"] = dna;
        unlockedTokens[tokenId].traits["body"] = body;
        unlockedTokens[tokenId].traits["head"] = head;
        unlockedTokens[tokenId].traits["eye"] = eye;
        unlockedTokens[tokenId].traits["mouth"] = mouth;
    }

    function getTokenRarity(uint256 tokenId) external
    view returns
    (uint256) {
        require(unlockedTokens[tokenId].tokenID > 0, Errors.TOKEN_ID_NOT_UNLOCKED);
        return unlockedTokens[tokenId].weight;
    }

    function tokenURI(uint256 tokenId)
    external view
    returns (string memory result) {
        require(tokenId < TOKEN_LIMIT, "Token ID out of bounds");
        require(unlockedTokens[tokenId].tokenID > 0, Errors.TOKEN_ID_NOT_UNLOCKED);
        if (unlockedTokens[tokenId].weight == 0) {
            result = string(abi.encodePacked(
                jsonDataType,
                Base64.encode(abi.encodePacked(
                    '{"animation_url": "',
                    cryptoAIImageHtml(tokenId),
                    '"}'
                )
                ))
            );
        } else {
            /*result = string(abi.encodePacked(
                jsonDataType,
                Base64.encode(abi.encodePacked(
                    '{"image": "', cryptoAIImageSvg(tokenId),
                    '", "attributes": ', cryptoAIAttributes(tokenId), '}'
                )
                ))
            );*/
            result = string(abi.encodePacked(
                '{"image": "', cryptoAIImageSvg(tokenId),
                '", "attributes": ', cryptoAIAttributes(tokenId), '}'
            ));
        }
    }

    ///////  DATA assets + rendering //////
    function addDNA(string memory dnaType, uint8 _trait) public onlyDeployer unsealed {
        DNA_TYPE.push(CryptoAIStructs.DNA_TYPE(dnaType, _trait));
    }

    function getDNA(uint8 indexDNA) public view returns (CryptoAIStructs.DNA_TYPE memory) {
        return DNA_TYPE[indexDNA];
    }

    function addDNAVariant(string memory _DNAType, string[] memory _DNAName, uint8[] memory _traits, uint8[][] memory _positions) public
    onlyDeployer unsealed {
        items[_DNAType].names = _DNAName;
        items[_DNAType].rarities = _traits;
        items[_DNAType].positions = _positions;
        emit CryptoAIStructs.DNAVariantAdded(_DNAType, _DNAName, _traits, _positions);
    }


    function getDNAVariant(string memory _DNAType) public view returns (CryptoAIStructs.ItemDetail memory) {
        CryptoAIStructs.ItemDetail memory item = DNA_Variants[_DNAType];
        return item;
    }

    function addItem(
        string memory _itemType,
        string[] memory _names,
        uint8[] memory _traits,
        uint8[][] memory _positions
    ) public validItemType(_itemType)
    onlyDeployer unsealed {
        items[_itemType].names = _names;
        items[_itemType].rarities = _traits;
        items[_itemType].positions = _positions;

        emit CryptoAIStructs.ItemAdded(_itemType, _names, _traits, _positions);
    }

    function getItem(string memory _itemType) public view returns (CryptoAIStructs.ItemDetail memory) {
        //        require(_itemId < itemCounts[_itemType], Errors.ITEM_NOT_EXIST);
        CryptoAIStructs.ItemDetail memory item = items[_itemType];
        return item;
    }

    function cryptoAIAttributes(uint256 tokenId)
    public view
    returns (string memory text) {
        // TODO
        string memory bodyName = items["body"].names[unlockedTokens[tokenId].traits["body"]];
        string memory headName = items["head"].names[unlockedTokens[tokenId].traits["head"]];
        string memory eyeName = items["eye"].names[unlockedTokens[tokenId].traits["eye"]];
        string memory mouthName = items["mouth"].names[unlockedTokens[tokenId].traits["mouth"]];
        text = '[{"trait_type": "Fur", "value": "Dark Brown"}]';
    }

    function cryptoAIImage(uint256 tokenId)
    public view
    returns (bytes memory) {
        /* TODO: uncomment when deploy
        require(unlockedTokens[tokenId].tokenID > 0 && unlockedTokens[tokenId].weight > 0, Errors.TOKEN_ID_NOT_UNLOCKED);
        uint256 weight = unlockedTokens[tokenId].weight;
        */

        uint8[] memory dna_po = items[DNA_TYPE[0].name].positions[unlockedTokens[tokenId].traits["dna"]];
        uint8[] memory body_po = items['body'].positions[unlockedTokens[tokenId].traits["body"]];
        uint8[] memory head_po = items['head'].positions[unlockedTokens[tokenId].traits["head"]];
        uint8[] memory eye_po = items['eye'].positions[unlockedTokens[tokenId].traits["eye"]];
        uint8[] memory mouth_po = items['mouth'].positions[unlockedTokens[tokenId].traits["mouth"]];

        bytes memory pixels = new bytes(2304);
        uint idx;
        uint256 totalLength = dna_po.length + body_po.length + head_po.length + eye_po.length + mouth_po.length;
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

            p = (uint16(pos[idx + 1]) * GRID_SIZE + uint16(pos[idx])) << 2;

            pixels[p] = bytes1(pos[idx + 2]);
            pixels[p + 1] = bytes1(pos[idx + 3]);
            pixels[p + 2] = bytes1(pos[idx + 4]);
            pixels[p + 3] = bytes1(0xFF);
        }

        return pixels;
    }

    function cryptoAIImageHtml(uint256 tokenId)
    public view
    returns (string memory result) {
        return string(abi.encodePacked(
            htmlDataType,
            Base64.encode(
                abi.encodePacked(
                    PLACEHOLDER_HEADER,
                    StringsUpgradeable.toString(tokenId),
                    PLACEHOLDER_FOOTER,
                    PLACEHOLDER_IMAGE
                )
            )
        ));
    }

    function cryptoAIImageSvg(uint256 tokenId)
    public view
        // onlyAIAgentContract
    returns (string memory result) {
        /* TODO: uncomment when deploy
        require(unlockedTokens[tokenId].tokenID > 0 && unlockedTokens[tokenId].rarity > 0, Errors.TOKEN_ID_NOT_UNLOCKED);
        */
        bytes memory pixels = cryptoAIImage(tokenId);
        string memory svg = '';
        bytes memory buffer = new bytes(8);
        uint p;
        for (uint y = 0; y < 24; y++) {
            for (uint x = 0; x < 24; x++) {
                assembly {
                    let multipliedY := mul(y, 24)
                    let sum := add(multipliedY, x)
                    p := mul(sum, 4)
                }
                if (uint8(pixels[p + 3]) > 0) {
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
        // result = string(abi.encodePacked(svgDataType, Base64.encode(abi.encodePacked(SVG_HEADER, svg, SVG_FOOTER))));
        result = string(abi.encodePacked(svgDataType, SVG_HEADER, svg, SVG_FOOTER));
    }

    function selectTrait(CryptoAIStructs.ItemDetail memory attribute, uint256 weight) internal view returns (uint256 index) {
        uint256 totalTraits = 0;
        uint256[] memory adjustedRarity = new uint256[](attribute.names.length);

        for (uint256 i = 0; i < attribute.names.length; i++) {
            adjustedRarity[i] = attribute.rarities[i] / weight;
            totalTraits += adjustedRarity[i];
        }
        uint256 randomValue = uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty))) % totalTraits;
        uint256 cumulativeWeight = 0;

        for (uint256 i = 0; i < attribute.names.length; i++) {
            cumulativeWeight += adjustedRarity[i];
            if (randomValue < cumulativeWeight) {
                attribute.rarities[i] += attribute.rarities[i] >> 1; // increase rarity of trait 50% after using
                return i;
            }
        }

        return attribute.names.length - 1;
    }
}
