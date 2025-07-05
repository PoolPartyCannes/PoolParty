//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/* sw0nt libraries */
import {ClonesWithImmutableArgs} from "@sw0nt/contracts/ClonesWithImmutableArgs.sol";

/* PoolParty libraries */
import {PPDataTypes} from "../contracts/libraries/PPDataTypes.sol";
import {PPErrors} from "../contracts/libraries/PPErrors.sol";

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
contract PoolPartyFactory is IOAppComposer, OApp {
    using ClonesWithImmutableArgs for address;
    address public implementation;
    mapping(uint96 chainId => address partyAddress) public sidePartyAt;
    mapping(string identifier => PPDataTypes.TokenInfo tokenInfo)
        public infoOfParty;

    /// @notice Initialize with Endpoint V2 and owner address
    /// @param _endpoint The local chain's LayerZero Endpoint V2 address
    /// @param _owner    The address permitted to configure this OApp
    constructor(
        address _endpoint,
        address _owner,
        address _implementation
    ) OApp(_endpoint, _owner) Ownable(_owner) {
        implementation = _implementation;
    }

    function deployParty(
        PPDataTypes.DynamicInfo calldata _info,
        string calldata _identifier,
        PPDataTypes.TokenInfo calldata _tokenInfo
    ) external returns (string memory _testMessage) {
        //if (_info.allowedTokens.length)
        //revert PPErrors.WRONGLY_FORMATTED_PARTY_INFO();

        // if (
        //    infoOfParty[_identifier].totalSupply != 0 ||
        //    infoOfParty[_identifier].decimals != 0
        // ) revert PPErrors.THIS_IDENTIFIER_ALREADY_EXISTS();

        //for (uint256 i; i < _info.allowedTokens.length; ) {
        // Here we should deploy the proxies
        //    unchecked {
        //        i++;
        //    }
        //}
        _testMessage = "Hello";
    }

    function updateImplemantation(address _newImplementation) external {
        implementation = _newImplementation;
    }

    /**
     * @notice Handles incoming composed messages from LayerZero.
     * @dev Ensures the message comes from the correct OApp and is sent through the authorized endpoint.
     *
     * @param _oApp The address of the OApp that is sending the composed message.
     */
    function lzCompose(
        address _oApp,
        bytes32 /* _guid */,
        bytes calldata /* _message */,
        address /* _executor */,
        bytes calldata /* _extraData */
    ) external payable override {}

    function _lzReceive(
        Origin calldata /*_origin*/,
        bytes32 /*_guid*/,
        bytes calldata /*_message*/,
        address /*_executor*/,
        bytes calldata /*_extraData*/
    ) internal override {}

    function _deployPartyProxy(
        address[] calldata tokens,
        string calldata identifier
    ) internal {}
}
