//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {PPDataTypes} from "./PPDataTypes.sol";

/**
 * @title PPDataTypes
 * @author https://x.com/0xjsieth
 * @notice Library containing Pool Party's custom events
 *
 */
library PPEvents {
    /// @dev event for successfull party creation
    event LetsGetThisPartyStarted(
        address indexed creator,
        PPDataTypes.PartyInfo partyInfo,
        PPDataTypes.TokenInfo tokenInfo
    );

    /// @dev event when a user has deposited their tokens
    event YouJoinedTheParty(address indexed who, uint256 amount);
}
