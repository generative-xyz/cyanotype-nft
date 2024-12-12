// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface IAgentNFT {
    function checkUnlockedNFT(uint256 tokenID) external pure returns (bool);

    function checkNFTPoint(uint256 tokenID) external pure returns (uint256, uint256);
}