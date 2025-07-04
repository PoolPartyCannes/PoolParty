//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/* sw0nt libraries */
import {ClonesWithImmutableArgs} from "@sw0nt/contracts/ClonesWithImmutableArgs.sol";

/* PoolParty libraries */
import {PPDataTypes} from "../contracts/libraries/PPDataTypes.sol";
import {PPErrors} from "../contracts/libraries/PPErrors.sol";

/**
 * @title PoolPartyFactory
 * @author https://x.com/0xjsieth
 * @notice Yo dawg, I heard you like proxy
 *   factories, so I put a proxy factory inside
 *   your proxy factory so you can delegatecall
 *   while you delegatecall!
 *
 */
contract PoolPartyFactory {
    function deployParty(PPDataTypes.PartyInfo calldata _info) external {
        if (_info.allowedTokens.length != _info.deployedParties.length)
            revert PPErrors.WRONGLY_FORMATTED_PARTY_INFO();
        for (uint256 i; i < _info.allowdTokens.length; ) {
            // Here we should deploy the proxies
            unchecked {
                i++;
            }
        }
    }
}
