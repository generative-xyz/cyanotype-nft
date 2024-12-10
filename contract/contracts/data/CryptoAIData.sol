// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import '@openzeppelin/contracts/utils/Base64.sol';
import "@openzeppelin/contracts-upgradeable/utils/StringsUpgradeable.sol";

import "../interfaces/ICryptoAIData.sol";
import "../libs/structs/CryptoAIStructsLibs.sol";
import "../libs/helpers/Errors.sol";

contract CryptoAIData is OwnableUpgradeable, ICryptoAIData {
    string private constant baseURL = 'data:image/svg+xml;base64,';

    string[] private VALID_ITEM_TYPES = ["body", "mouth", "shirt", "eye"];
    uint8 internal constant GRID_SIZE = 24;
    string internal constant SVG_HEADER = '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24">';
    string internal constant SVG_FOOTER = '</svg>';
    string internal constant SVG_X = 'x="';
    string internal constant SVG_Y = 'y="';
    string internal constant SVG_WIDTH = ' width="1" height="1" ';
    string internal constant SVG_RECT = '<rect ';
    string internal constant SVG_CLOSE_RECT = '/>';

    mapping(string => mapping(uint16 => CryptoAIStructs.ItemDetail)) private items;
    mapping(string => uint16) private itemCounts;

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

    ///////
    function addItem(
        string memory _itemType,
        string memory _name,
        uint8 _trait,
        uint8[] memory _positions
    ) public validItemType(_itemType) returns (uint16) {
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

    //
    function svgToImageURI(string memory svg) external pure returns (string memory) {
        string memory svgBase64Encoded = Base64.encode(bytes(svg));
        return string(abi.encodePacked(baseURL, svgBase64Encoded));
    }

    function createMultipleRects(uint8[] memory positions, uint8[] memory positions2, uint8[] memory positions3, uint8[] memory positions4) internal pure returns (bytes memory) {
        bytes memory pixels = new bytes(2304);
        uint totalLength = positions.length + positions2.length + positions3.length + positions4.length;
        uint16 p;
        uint8[] memory pos;
        uint idx;
        for (uint i = 0; i < totalLength; i += 5) {
            if (i < positions.length) {
                pos = positions;
                idx = i;
            } else if (i < positions.length + positions2.length) {
                pos = positions2;
                idx = i - positions.length;
            } else if (i < positions.length + positions2.length + positions3.length) {
                pos = positions3;
                idx = i - positions.length - positions2.length;
            } else {
                pos = positions4;
                idx = i - positions.length - positions2.length - positions3.length;
            }

            // Calculate pixel position
            p = (uint16(pos[idx + 1]) * GRID_SIZE + uint16(pos[idx])) * 4;

            // Set RGBA values directly
            pixels[p] = bytes1(pos[idx + 2]);     // R
            pixels[p + 1] = bytes1(pos[idx + 3]);   // G
            pixels[p + 2] = bytes1(pos[idx + 4]);   // B
            pixels[p + 3] = bytes1(0xFF);         // A
        }

        return pixels;
    }

    function renderFullSVGWithGrid(uint256 tokenId) external view returns (string memory) {
        // require(tokenId < TOKEN_LIMIT, "Token ID out of bounds");
        bytes memory pixel = createMultipleRects(items['body'][0].positions, items['mouth'][0].positions, items['shirt'][0].positions, items['eye'][0].positions);

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
                                SVG_X,
                                StringsUpgradeable.toString(x), '" ',
                                SVG_Y,
                                StringsUpgradeable.toString(y), '" ',
                                SVG_WIDTH,
                                'fill="rgb(', StringsUpgradeable.toString(uint8(pixel[i])), ',', StringsUpgradeable.toString(uint8(pixel[i + 1])), ',', StringsUpgradeable.toString(uint8(pixel[i + 2])), ')" ',
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
        return svg;
    }
}