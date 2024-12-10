// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;

interface ICryptoAIData {
    function svgToImageURI(string memory svg) external pure returns (string memory);

    function renderFullSVGWithGrid(uint256 tokenId) external view returns (string memory);
}