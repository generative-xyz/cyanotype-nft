pragma solidity ^0.8.0;

library CryptoAIStructs {

    event SVGGenerated(address indexed creator, uint timestamp);
    event ItemAdded(string itemType, uint16 indexed itemId, string name, uint8 trait);
    event DNAVariantAdded(string itemType, uint16 indexed itemId, string name, uint8 trait);
    event TokenMinted(uint256 tokenId);

    struct PositionDetail {
        uint8 x;      // 0-24
        uint8 y;      // 0-24
        uint8 colorId; // Index into colors array
    }

    struct ItemDetail {
        string name;
        uint8 trait;  // 0-200
        uint8[] positions; // x,y,r,g,b stored sequentially
    }

    struct Token {
        uint256 tokenID;
        uint256 rarity;
    }
}