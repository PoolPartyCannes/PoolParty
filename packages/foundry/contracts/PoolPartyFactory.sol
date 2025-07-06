//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/* sw0nt libraries */
import {ClonesWithImmutableArgs} from "@sw0nt/contracts/ClonesWithImmutableArgs.sol";

/* PoolParty libraries */
import {PPDataTypes} from "./libraries/PPDataTypes.sol";
import {PPErrors} from "./libraries/PPErrors.sol";
import {PPEvents} from "./libraries/PPEvents.sol";

/* PoolParty contracts */
import {PoolParty} from "../contracts/PoolParty.sol";
import {PartyToken} from "../contracts/PartyToken.sol";
import {DiamondParty} from "../contracts/DiamondParty.sol";

/**
 * @title PoolPartyFactory
 * @author https://x.com/0xjsieth
 * @notice Yo dawg, I heard you like proxy
 *   factories, so I put a proxy factory inside
 *   your proxy factory so you can delegatecall
 *   while you delegatecall!
 *
 */
contract PoolPartyFactory is DiamondParty {
    using ClonesWithImmutableArgs for address;

    address public implementation;
    address public tokenImplementation;
    mapping(string identifier => PPDataTypes.TokenInfo tokenInfo)
        public infoOfParty;

    /// @notice Initialize with implementation and token implementation
    /// @param _implementation The implementation address
    /// @param _tokenImplementation The token implementation address
    constructor(
        address _implementation,
        address _tokenImplementation
    ) {
        implementation = _implementation;
        tokenImplementation = _tokenImplementation;
    }

    function deployParty(
        PPDataTypes.DynamicInfo[] calldata _acceptedTokens,
        string calldata _identifier,
        PPDataTypes.TokenInfo calldata _tokenInfo
    ) external returns (address[] memory _instances) {
        if (_acceptedTokens.length == 0)
            revert PPErrors.MUST_BE_AT_LEAST_ONE_TOKEN();
        if (
            infoOfParty[_identifier].totalSupply != 0 ||
            infoOfParty[_identifier].decimals != 0
        ) revert PPErrors.THIS_IDENTIFIER_ALREADY_EXISTS();

        infoOfParty[_identifier] = _tokenInfo;

        // Initialize array with proper size for all tokens
        address[] memory tokenArr = new address[](_acceptedTokens.length);
        for (uint256 i = 0; i < _acceptedTokens.length; ) {
            tokenArr[i] = _acceptedTokens[i].dynamicAddress;
            unchecked {
                i++;
            }
        }

        for (uint256 i = 0; i < _acceptedTokens.length; ) {
            if (uint256(_acceptedTokens[i].chainId) == block.chainid) {
                _instances = new address[](1);
                _instances[0] = _deployPartyProxy(tokenArr, _identifier);
            }
            unchecked {
                i++;
            }
        }

        if (_instances.length > 0 && _instances[0] == address(0))
            revert PPErrors.COULD_NOT_DEPLOY_PROXY();

        // Create deployedParties array with proper size
        PPDataTypes.DynamicInfo[]
            memory deployedParties = new PPDataTypes.DynamicInfo[](
                _instances.length
            );
        if (_instances.length > 0) {
            deployedParties[0] = PPDataTypes.DynamicInfo({
                dynamicAddress: _instances[0],
                chainId: _acceptedTokens[0].chainId
            });
        }

        emit PPEvents.LetsGetThisPartyStarted(
            msg.sender,
            PPDataTypes.PartyInfo({
                allowedTokens: _acceptedTokens,
                deployedParties: deployedParties
            }),
            _tokenInfo
        );
    }

    function deployToken(
        string calldata _identifier
    ) external returns (address _instance) {
        PPDataTypes.TokenInfo memory tokenInfo = infoOfParty[_identifier];

        if (tokenInfo.decimals == 0) revert PPErrors.TOKEN_INFO_NOT_SET();

        // Deploy the full token first
        bytes memory data = abi.encodePacked(
            tokenInfo.decimals,
            tokenInfo.totalSupply
        );
        PartyToken core = PartyToken(tokenImplementation.clone(data));
        // Use the core token address for the facet, not the adapter
        _instance = _diamondsOnMyBankAccount(address(core), tokenInfo);
    }

    function version() external pure returns (uint8 _version) {
        _version = 1;
    }

    function updateImplemantation(
        address _newImplementation
    ) external {
        implementation = _newImplementation;
    }

    function updateTokenImplemantation(
        address _newTokenImplementation
    ) external {
        tokenImplementation = _newTokenImplementation;
    }

    function _deployPartyProxy(
        address[] memory _tokens,
        string calldata _identifier
    ) internal returns (address _instance) {
        // Pull token length into memory
        uint256 amountOfTokens = _tokens.length;
        // Make sure we at least have one token
        if (amountOfTokens == 0) revert PPErrors.MUST_BE_AT_LEAST_ONE_TOKEN();
        // Fill the first piece of data with the length of the token array for easier handling of token addresses inside of the pool party
        bytes memory data = abi.encodePacked(uint8(amountOfTokens));
        // Add this contracts address to the contact too
        data = bytes.concat(data, abi.encodePacked(address(this)));
        // In order to save gas we're checking if there is 1 or more tokens here...
        if (amountOfTokens > 1) {
            // If there is more...
            for (uint256 i; i < amountOfTokens; ) {
                // We index through them and concatinate them into the bytes data
                data = bytes.concat(data, abi.encodePacked(_tokens[i]));
                // Continue the loop, the sexy way
                unchecked {
                    i++;
                }
            }
            // Else if there is just on token...
        } else {
            // We're only slamming that in, no need to check the length of the tokens
            data = bytes.concat(data, abi.encodePacked(_tokens[0]));
        }

        // Create the minimum proxy
        _instance = implementation.clone(data);

        // initialize it with the identifier
        PoolParty(_instance).initialize(_identifier);
    }
}
