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
import {PartyTokenCore, PartyToken} from "../contracts/PartyToken.sol";
import {DiamondParty} from "../contracts/DiamondParty.sol";

/* LayerZero Interfaces */
import {IOAppComposer} from "@layerzerolabs/oapp-evm/contracts/oapp/interfaces/IOAppComposer.sol";
import {Origin, OApp} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

/* OpenZeppelin libraries */
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/**
 * @title PoolPartyFactory
 * @author https://x.com/0xjsieth
 * @notice Yo dawg, I heard you like proxy
 *   factories, so I put a proxy factory inside
 *   your proxy factory so you can delegatecall
 *   while you delegatecall!
 *
 */
contract PoolPartyFactory is IOAppComposer, OApp, DiamondParty {
    using ClonesWithImmutableArgs for address;
    //using MsgCodec for bytes;
    //using OptionsBuilder for bytes;

    address public implementation;
    address public tokenImplementation;
    address private pEndpoint;
    mapping(uint96 chainId => address partyAddress) public sidePartyAt;
    mapping(string identifier => PPDataTypes.TokenInfo tokenInfo)
        public infoOfParty;

    /// @notice Initialize with Endpoint V2 and owner address
    /// @param _endpoint The local chain's LayerZero Endpoint V2 address
    /// @param _owner    The address permitted to configure this OApp
    constructor(
        address _endpoint,
        address _owner,
        address _implementation,
        address _tokenImplementation
    ) OApp(_endpoint, _owner) Ownable(_owner) {
        implementation = _implementation;
        tokenImplementation = _tokenImplementation;
        pEndpoint = _endpoint;
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
            } else {
                // // This needs to be fixed
                // _lzSend(
                // _acceptedTokens[i].chainId,
                // abi.encode(tokenArr, _identifier, _tokenInfo),
                // msg.sender,
                // msg.sender
                // );
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
        PartyTokenCore core = PartyTokenCore(tokenImplementation.clone(data));
        // Don't initialize the clone directly - we'll initialize the diamond instead
        address partyTokenAdapter = address(
            new PartyToken(address(core), pEndpoint, msg.sender)
        );
        // Use the core token address for the facet, not the adapter
        address fullToken = address(core);
        _instance = _diamondsOnMyBankAccount(fullToken, tokenInfo);
    }

    function version() external pure returns (uint8 _version) {
        _version = 1;
    }

    function updateImplemantation(
        address _newImplementation
    ) external onlyOwner {
        implementation = _newImplementation;
    }

    function updateTokenImplemantation(
        address _newTokenImplementation
    ) external onlyOwner {
        tokenImplementation = _newTokenImplementation;
    }

    function addSideParty(
        uint96 _chainId,
        address _partyAddress
    ) external onlyOwner {
        sidePartyAt[_chainId] = _partyAddress;
    }

    /**
     * @notice Handles incoming composed messages from LayerZero.
     * @dev Ensures the message comes from the correct OApp and is sent through the authorized endpoint.
     *
     * @param _oApp The address of the OApp that is sending the composed message.
     *
     */
    function lzCompose(
        address _oApp,
        bytes32 /* _guid */,
        bytes calldata _message,
        address /* _executor */,
        bytes calldata /* _extraData */
    ) external payable override {
        // if (msg.sender != endpoint) revert PPErrors.NOT_LAYER_ZERO_ENDPOINT();
        // if (_oApp != address(this)) revert PPErrors.NOT_OAPP();
        // (address[] memory acceptedTokens, string memory identifier, PPDataTypes.TokenInfo memory tokenInfo) = abi.decode(
        // OFTComposeMsgCodec.composeMsg(_message),
        // (address[], string, PPDataTypes.TokenInfo)
        // );
        // if (acceptedTokens.length == 0)
        // revert PPErrors.MUST_BE_AT_LEAST_ONE_TOKEN();
        // if (tokenInfo.decimals == 0 || tokenInfo.totalSupply == 0) {
        // revert PPErrors.TOKEN_INFO_NOT_SET();
        // } else {
        // infoOfParty[identifier] = tokenInfo;
        // _deployPartyProxy(acceptedTokens, identifier);
        // }
    }

    function _lzReceive(
        Origin calldata _origin,
        bytes32 _guid,
        bytes calldata _message,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {
        // if (_message.isComposed()) {
        // // @dev Proprietary composeMsg format for the OFT.
        // bytes memory composeMsg = OFTComposeMsgCodec.encode(
        // _origin.nonce,
        // _origin.srcEid,
        // amountReceivedLD,
        // _message.composeMsg()
        // );
        // // @dev Stores the lzCompose payload that will be executed in a separate tx.
        // // Standardizes functionality for executing arbitrary contract invocation on some non-evm chains.
        // // @dev The off-chain executor will listen and process the msg based on the src-chain-callers compose options passed.
        // // @dev The index is used when a OApp needs to compose multiple msgs on lzReceive.
        // // For default OFT implementation there is only 1 compose msg per lzReceive, thus its always 0.
        // endpoint.sendCompose(toAddress, _guid, 0 /* the index of the composed message*/, composeMsg);
        // }
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
