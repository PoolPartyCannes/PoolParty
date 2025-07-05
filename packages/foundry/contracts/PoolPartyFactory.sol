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

/* LayerZero Interfaces */
import {IOAppComposer} from "@layerzerolabs/oapp-evm/contracts/oapp/interfaces/IOAppComposer.sol";
import {Origin, OApp} from "@layerzerolabs/oapp-evm/contracts/oapp/OApp.sol";

/* OpenZeppelin libraries */
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/* Mudgen Contracts */
import {Diamond} from "@mudgen/contracts/Diamond.sol";
import {DiamondCutFacet} from "@mudgen/contracts/facets/DiamondCutFacet.sol";
import {DiamondInit} from "@mudgen/contracts/upgradeInitializers/DiamondInit.sol";
import {IDiamondCut} from "@mudgen/contracts/interfaces/IDiamondCut.sol";

/* PoolParty Facets */
import {FullTokenFacet} from "./FullTokenFacet.sol";

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
        if (_acceptedTokens.length == 0) revert PPErrors.MUST_BE_AT_LEAST_ONE_TOKEN();
        if (
            infoOfParty[_identifier].totalSupply != 0 ||
            infoOfParty[_identifier].decimals != 0
        ) revert PPErrors.THIS_IDENTIFIER_ALREADY_EXISTS();

        infoOfParty[_identifier] = _tokenInfo;

        // Initialize array with proper size for all tokens
        address[] memory tokenArr = new address[](_acceptedTokens.length);
        for (uint256 i = 0; i < _acceptedTokens.length; i++) {
            tokenArr[i] = _acceptedTokens[i].dynamicAddress;
        }

        if (uint256(_acceptedTokens[0].chainId) == block.chainid) {
            _instances = new address[](1);
            _instances[0] = _deployPartyProxy(tokenArr, _identifier);
        } else {
            _instances = new address[](0);
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

        if (tokenInfo.decimals == 0)
            revert PPErrors.TOKEN_INFO_NOT_SET();

        // Deploy the full token first
        bytes memory data = abi.encodePacked(tokenInfo.decimals, tokenInfo.totalSupply);
        PartyTokenCore core = PartyTokenCore(tokenImplementation.clone(data));
        core.initialize(tokenInfo.name, tokenInfo.symbol);
        address partyTokenAdapter = address(new PartyToken(address(core), pEndpoint, msg.sender));
        // Use the core token address for the facet, not the adapter
        address fullToken = address(core);

        // Deploy the diamond with the fullToken as a facet
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        Diamond diamond = new Diamond(address(this), address(diamondCutFacet));

        // Deploy the DiamondInit
        DiamondInit diamondInit = new DiamondInit();

        // Deploy the FullTokenFacet
        FullTokenFacet fullTokenFacet = new FullTokenFacet();
        
        // Define the function selectors for the FullTokenFacet
        bytes4[] memory fullTokenSelectors = new bytes4[](12);
        fullTokenSelectors[0] = bytes4(keccak256("initializeFullToken(address)"));
        fullTokenSelectors[1] = bytes4(keccak256("getFullTokenAddress()"));
        fullTokenSelectors[2] = bytes4(keccak256("balanceOf(address)"));
        fullTokenSelectors[3] = bytes4(keccak256("totalSupply()"));
        fullTokenSelectors[4] = bytes4(keccak256("name()"));
        fullTokenSelectors[5] = bytes4(keccak256("symbol()"));
        fullTokenSelectors[6] = bytes4(keccak256("decimals()"));
        fullTokenSelectors[7] = bytes4(keccak256("transfer(address,uint256)"));
        fullTokenSelectors[8] = bytes4(keccak256("transferFrom(address,address,uint256)"));
        fullTokenSelectors[9] = bytes4(keccak256("approve(address,uint256)"));
        fullTokenSelectors[10] = bytes4(keccak256("allowance(address,address)"));
        fullTokenSelectors[11] = bytes4(keccak256("fullTokenAddress()"));
        
        // Create the facet cut for the FullTokenFacet
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](1);
        facetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: address(fullTokenFacet),
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: fullTokenSelectors
        });
        
        // Cut the facet into the diamond and initialize with DiamondInit
        IDiamondCut(address(diamond)).diamondCut(
            facetCuts,
            address(diamondInit),
            abi.encodeWithSignature("init()")
        );
        
        // Now initialize the FullTokenFacet with the token address
        FullTokenFacet(address(diamond)).initializeFullToken(fullToken);
        
        _instance = address(diamond);
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
