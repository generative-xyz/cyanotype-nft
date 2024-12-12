// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface ICryptoAIData {
    function renderFullSVGWithGrid(uint256 tokenId) external view returns (string memory);
}