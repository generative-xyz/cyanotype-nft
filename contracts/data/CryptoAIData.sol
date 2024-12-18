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
    uint256 public constant TOKEN_LIMIT = 0x3E8; // 0x2710
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
    string[5] private partsName = ["dna", "Body", "Head", "Eyes", "Mouth"];

    // deployer
    address public _deployer;
    // crypto ai agent address
    address public _cryptoAIAgentAddr;
    bool private _contractSealed;

    // assets
    mapping(uint256 => CryptoAIStructs.Token) private unlockedTokens;
    mapping(string => CryptoAIStructs.ItemDetail) private items;
    CryptoAIStructs.DNA_TYPE private DNA_TYPES;// cat dog human
    mapping(bytes32 => bool) private usedPairs;

    // assets
    string internal PLACEHOLDER_IMAGE;

    modifier unsealed() {
        require(!_contractSealed, Errors.CONTRACT_SEALED);
        _;
    }

    modifier onlyDeployer() {
        require(msg.sender == _deployer, Errors.ONLY_DEPLOYER);
        _;
    }

    modifier onlyAIAgentContract() {
        /* TODO: uncomment when deploy
        require(msg.sender == _cryptoAIAgentAddr, Errors.ONLY_AGENT_CONTRACT);
        */
        _;
    }

    function initialize(
        address deployer
    ) initializer
    public {
        _deployer = deployer;

        __Ownable_init();
    }


    function changeDeployer(address newAdm)
    external
    onlyDeployer unsealed {
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
    unsealed {
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
        require(unlockedTokens[tokenId].weight == 0, Errors.TOKEN_ID_UNLOCKED);
        unlockedTokens[tokenId].weight = nft.getAgentRarity(tokenId);
        */
        unlockedTokens[tokenId].tokenID = tokenId;
        unlockedTokens[tokenId].weight = tokenId + 2000;

        unlockedTokens[tokenId].dna = selectTrait(DNA_TYPES.rarities, unlockedTokens[tokenId].weight, tokenId, 0);
        DNA_TYPES.rarities[unlockedTokens[tokenId].dna] -= DNA_TYPES.rarities[unlockedTokens[tokenId].dna] >> 1;
        partsName[0] = DNA_TYPES.names[unlockedTokens[tokenId].dna];

        bytes32 pairHash;
        uint256 maxAttempts = 5;
        uint256 attempt = 0;
        do {
            attempt++;
            for (uint256 i = 0; i < partsName.length; i++) {
                unlockedTokens[tokenId].traits[i] = selectTrait(items[partsName[i]].rarities, unlockedTokens[tokenId].weight, tokenId, attempt);
                items[partsName[i]].rarities[i] -= items[partsName[i]].rarities[i] >> 1; // increase rarity of trait 50% after using
            }
            pairHash = keccak256(abi.encodePacked(unlockedTokens[tokenId].traits));
        }
        while (usedPairs[pairHash] && attempt < maxAttempts);
        // require(!usedPairs[pairHash], Errors.USED_PAIRs);
        if (!usedPairs[pairHash]) {
            usedPairs[pairHash] = true;
        }
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
    function addDNA(string[] memory _names, uint16[] memory rarities) public onlyDeployer unsealed {
        DNA_TYPES.names = _names;
        DNA_TYPES.rarities = rarities;
    }

    function getDNA() public view returns (CryptoAIStructs.DNA_TYPE memory) {
        return DNA_TYPES;
    }

    function addDNAVariant(string memory _DNAType, string[] memory _DNAName, uint16[] memory _traits, uint8[][] memory _positions) public
    onlyDeployer unsealed {
        items[_DNAType].names = _DNAName;
        items[_DNAType].rarities = _traits;
        items[_DNAType].positions = _positions;
        emit CryptoAIStructs.DNAVariantAdded(_DNAType, _DNAName, _traits, _positions);
    }


    function getDNAVariant(string memory _DNAType) public view returns (CryptoAIStructs.ItemDetail memory) {
        CryptoAIStructs.ItemDetail memory item = items[_DNAType];
        return item;
    }

    function addItem(
        string memory _itemType,
        string[] memory _names,
        uint16[] memory _traits,
        uint8[][] memory _positions
    ) public
    onlyDeployer unsealed
    {
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
        bytes memory byteString;
        uint count = 0;
        string memory traitName;
        string memory value;
        for (uint8 i = 0; i < partsName.length; i++) {
            traitName = partsName[i];
            value = items[partsName[i]].names[unlockedTokens[tokenId].traits[i]];
            if (i == 0) {
                traitName = "DNA";
                value = items[DNA_TYPES.names[unlockedTokens[tokenId].dna]].names[unlockedTokens[tokenId].traits[i]];
            }
            if (bytes(value).length != 0) {
                bytes memory objString = abi.encodePacked(
                    '{"trait":"',
                    traitName,
                    '","value":"',
                    value,
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
            , byteString
        );

        text = string(abi.encodePacked('[', string(byteString), ']'));
    }

    function cryptoAIImage(uint256 tokenId)
    public view
    returns (bytes memory) {
        /* TODO: uncomment when deploy
        require(unlockedTokens[tokenId].tokenID > 0 && unlockedTokens[tokenId].weight > 0, Errors.TOKEN_ID_NOT_UNLOCKED);
        */
        uint8[][] memory data = new uint8[][](5);
        for (uint256 i = 0; i < partsName.length; i++) {
            if (i == 0) {
                data[i] = items[DNA_TYPES.names[unlockedTokens[tokenId].dna]].positions[unlockedTokens[tokenId].traits[i]];
            } else {
                data[i] = items[partsName[i]].positions[unlockedTokens[tokenId].traits[i]];
            }
        }
        bytes memory pixels = new bytes(2304);
        uint idx;
        uint256 totalLength = data[0].length + data[1].length + data[2].length + data[3].length + data[4].length;
        uint8[] memory pos;
        uint16 positionLength = uint16(data[0].length);
        for (uint i = 0; i < totalLength; i += 5) {
            if (i < positionLength) {
                pos = data[0];
                idx = i;
            } else if (i < positionLength + data[1].length) {
                pos = data[1];
                idx = i - positionLength;
            } else if (i < positionLength + data[1].length + data[2].length) {
                pos = data[2];
                idx = i - positionLength - data[1].length;
            } else if (i < positionLength + data[1].length + data[2].length + data[3].length) {
                pos = data[3];
                idx = i - positionLength - data[1].length - data[2].length;
            } else {
                pos = data[4];
                idx = i - positionLength - data[1].length - data[2].length - data[3].length;
            }
            /*
            uint16 p = (uint16(pos[idx + 1]) * GRID_SIZE + uint16(pos[idx])) << 2;

            pixels[p] = bytes1(pos[idx + 2]);
            pixels[p + 1] = bytes1(pos[idx + 3]);
            pixels[p + 2] = bytes1(pos[idx + 4]);
            pixels[p + 3] = bytes1(0xFF);
            */
            assembly {
                let posPtr := add(pos, 0x20)
                let value1 := and(mload(add(posPtr, add(idx, 1))), 0xFF)
                let value2 := and(mload(add(posPtr, idx)), 0xFF)
                let p := shl(2, add(mul(value1, GRID_SIZE), value2))

                let pixelsPtr := add(pixels, 0x20)
                mstore8(add(pixelsPtr, p), and(mload(add(posPtr, add(idx, 2))), 0xFF))
                mstore8(add(add(pixelsPtr, p), 1), and(mload(add(posPtr, add(idx, 3))), 0xFF))
                mstore8(add(add(pixelsPtr, p), 2), and(mload(add(posPtr, add(idx, 4))), 0xFF))
                mstore8(add(add(pixelsPtr, p), 3), 0xFF)
            }
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

    function selectTrait(uint16[] memory rarities, uint256 weight, uint256 tokenId, uint256 attempt) internal view returns (uint256 index) {
        uint256 totalTraits = 0;
        uint256[] memory adjustedRarity = new uint256[](rarities.length);

        for (uint256 i = 0; i < rarities.length; i++) {
            adjustedRarity[i] = weight / rarities[i];
            totalTraits += adjustedRarity[i];
        }

        uint256 randomValue = uint256(keccak256(abi.encodePacked(msg.sender, block.timestamp, block.difficulty, tokenId, attempt))) % totalTraits;
        uint256 cumulativeWeight = 0;

        for (uint256 i = 0; i < rarities.length; i++) {
            cumulativeWeight += adjustedRarity[i];
            if (randomValue < cumulativeWeight) {
                return i;
            }
        }

        return rarities.length - 1;
    }
}
