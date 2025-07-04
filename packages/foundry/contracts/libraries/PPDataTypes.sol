//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title PPDataTypes
 * @author https://x.com/0xjsieth
 * @notice Library containing Pool Party's custom datatypes
 *
 */
library PPDataTypes {
    /// @dev
    ///   Dynamic info field, used for both keep track
    ///   of how tokens we're allowing and where the
    ///   associated contracts are deployed
    struct DynamicInfo {
        // 20 bytes (160 bits)
        address dynamicAddress;
        // 12 bytes (96 bits)
        uint96 chainId;
    }

    struct PartyInfo {
        DynamicInfo[] allowedTokens;
        DynamicInfo[] deployedParties;
    }

    struct TokenInfo {
        uint256 totalSupply;
        uint8 decimals;
        string name;
        string symbol;
        bool isOwnable;
    }
}
