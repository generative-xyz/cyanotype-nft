// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

contract TestPickRandom {
    struct ItemDetail {
        string name;
        uint8 trait; // 0-200 for rarity
    }

    // Mapping to store test items with traits
    mapping(string => ItemDetail[]) public items;
    mapping(uint16 => bool) public tokenExists;
    
    // Constructor to initialize test data with traits
    constructor() {
        // Add test items with traits (lower trait = more rare)
        items["body"].push(ItemDetail("body1", 180)); // Common
        items["body"].push(ItemDetail("body2", 120)); // Uncommon  
        items["body"].push(ItemDetail("body3", 60)); // Rare
        items["body"].push(ItemDetail("body4", 0));  // Very rare - Changed to 0

        items["mouth"].push(ItemDetail("mouth1", 180));
        items["mouth"].push(ItemDetail("mouth2", 140));
        items["mouth"].push(ItemDetail("mouth3", 100));
        items["mouth"].push(ItemDetail("mouth4", 60));

        items["shirt"].push(ItemDetail("shirt1", 180));
        items["shirt"].push(ItemDetail("shirt2", 140));
        items["shirt"].push(ItemDetail("shirt3", 100));
        items["shirt"].push(ItemDetail("shirt4", 60));

        items["eye"].push(ItemDetail("eye1", 180));
        items["eye"].push(ItemDetail("eye2", 140));
        items["eye"].push(ItemDetail("eye3", 100));
        items["eye"].push(ItemDetail("eye4", 60));
    }

    function pickRandomItems(uint16 tokenId) public view returns (
        string memory bodyType,
        string memory mouthType, 
        string memory shirtType,
        string memory eyeType
    ) {
        require(tokenExists[tokenId], "Token does not exist");

        // Pack tokenId with item type strings into single hash operation
        bytes32 combinedHash = keccak256(abi.encodePacked(tokenId, "body", "mouth", "shirt", "eye"));
        
        // Get weighted random indices based on trait values
        uint16 bodyIndex = getWeightedRandomIndex("body", combinedHash);
        uint16 mouthIndex = getWeightedRandomIndex("mouth", combinedHash >> 64);
        uint16 shirtIndex = getWeightedRandomIndex("shirt", combinedHash >> 128);
        uint16 eyeIndex = getWeightedRandomIndex("eye", combinedHash >> 192);

        // Return names of selected items
        return (
            items["body"][bodyIndex].name,
            items["mouth"][mouthIndex].name,
            items["shirt"][shirtIndex].name,
            items["eye"][eyeIndex].name
        );
    }

    function getWeightedRandomIndex(string memory itemType, bytes32 hash) internal view returns (uint16) {
        uint256 totalWeight = 0;
        uint256[] memory weights = new uint256[](items[itemType].length);
        
        // Calculate weights based on trait values with exponential scaling
        for(uint16 i = 0; i < items[itemType].length; i++) {
            weights[i] = 200 - (items[itemType][i].trait * items[itemType][i].trait / 200);
            totalWeight += weights[i];
        }

        // Get random number from hash
        uint256 random = uint256(hash) % totalWeight;
        
        // Find index based on cumulative weights
        uint256 cumulative = 0;
        for(uint16 i = 0; i < items[itemType].length; i++) {
            cumulative += weights[i];
            if(random < cumulative) {
                return i;
            }
        }
        
        return uint16(items[itemType].length - 1); // Fallback to last index
    }
}