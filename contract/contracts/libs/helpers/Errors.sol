// SPDX-License-Identifier: agpl-3.0
pragma solidity 0.8.12;

library Errors {
    enum ReturnCode {
        SUCCESS,
        FAILED
    }

    string public constant SUCCESS = "0";

    address public constant ZERO_ADDR = address(0x0);

    // common errors
    string public constant INV_ADD = "100";
    string public constant ONLY_ADMIN_ALLOWED = "101";
    string public constant ONLY_DEPLOYER = "102";
    string public constant INVALID_ITEM_TYPE = "103";
    string public constant ITEM_NOT_EXIST = "104";

    // validation error
    string public constant CONTRACT_SEALED = "200";
    string public constant TOKEN_ID_NOT_UNLOCKED = "201";
    string public constant TOKEN_ID_UNLOCKED = "202";
}