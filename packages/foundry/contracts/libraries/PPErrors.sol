//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/**
 * @title PPErrors
 * @author https://x.com/0xjsieth
 * @notice Library containing Pool Party's custom errors
 *
 */
library PPErrors {
    /// @dev
    error WRONGLY_FORMATTED_PARTY_INFO();

    error THIS_IDENTIFIER_ALREADY_EXISTS();

    error MUST_BE_AT_LEAST_ONE_TOKEN();

    error COULD_NOT_DEPLOY_PROXY();

    error OUT_OF_BOUNDS();

    error TOKEN_NOT_AVAILABLE();

    error DEPOSIT_FAILED();

    error TOKEN_INFO_NOT_SET();
}
