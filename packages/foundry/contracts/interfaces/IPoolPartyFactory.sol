//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import {PPDataTypes} from "../libraries/PPDataTypes.sol";

/**
 * @title IPoolPartyFactory
 * @author https://x.com/0xjsieth
 * @notice Yo dawg, I heard you like proxy
 *   factories, so I put a proxy factory inside
 *   your proxy factory so you can delegatecall
 *   while you delegatecall!
 *
 */
interface IPoolPartyFactory {
    function infoOfParty(
        string calldata identifier
    ) external view returns (uint256 totalSupply, uint8 decimals, string memory name, string memory symbol, bool isOwnable);

    function sidePartyAt(
        uint96 chainId
    ) external view returns (address partyAddress);

    function deployParty(
        PPDataTypes.DynamicInfo[] calldata _info,
        string calldata _identifier,
        PPDataTypes.TokenInfo calldata _tokenInfo
    ) external returns (address[] memory _instances);

    function version() external pure returns (uint8 _version);

    function updateImplemantation(address _newImplementation) external;
}
