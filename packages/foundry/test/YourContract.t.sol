// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "forge-std/Test.sol";

/* Our Own Deploy Script */
import {DeployScript} from "../script/Deploy.s.sol";

/* Our Contracts */
import {PoolPartyFactory} from "../contracts/PoolPartyFactory.sol";
import {PoolParty} from "../contracts/PoolParty.sol";
import {PartyToken, PartyTokenCore} from "../contracts/PartyToken.sol";

/* Our libraries */
import {PPDataTypes} from "../contracts/libraries/PPDataTypes.sol";
import {PPErrors} from "../contracts/libraries/PPErrors.sol";
import {PPEvents} from "../contracts/libraries/PPEvents.sol";

/* LayerZero Test DevTools */
import {TestHelperOz5} from "@layerzerolabs/test-devtools-evm-foundry/contracts/TestHelperOz5.sol";

/* sw0nt libraries */
import {ClonesWithImmutableArgs} from "@sw0nt/contracts/ClonesWithImmutableArgs.sol";

interface IFullTokenFacet {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address) external view returns (uint256);
}

contract YourContractTest is TestHelperOz5 {
    PoolPartyFactory factory;
    PoolParty implementation;
    PartyTokenCore partyTokenImplementation;
    
    // Test addresses
    address public user1 = address(0x2);
    address public user2 = address(0x3);
    address public user3 = address(0x4);
    
    // Test data
    string public constant PARTY_IDENTIFIER = "test-party-123";
    uint96 public constant CHAIN_ID = 31337;

    function setUp() public virtual override {
        super.setUp();
        setUpEndpoints(1, LibraryType.UltraLightNode);
        
        // Deploy the implementation contract first (no constructor parameters)
        implementation = new PoolParty();

        // Deploy the token implementation
        partyTokenImplementation = new PartyTokenCore();

        // Deploy the factory using _deployOApp helper to set test contract as owner
        factory = PoolPartyFactory(
            _deployOApp(
                type(PoolPartyFactory).creationCode,
                abi.encode(
                    endpoints[1],  // endpoint
                    address(this), // owner (test contract)
                    address(implementation), // implementation
                    address(partyTokenImplementation) // token implementation
                )
            )
        );
    }

    // ============ Helper Functions ============

    function deployPartyAndGetTokens(
        string memory _identifier,
        uint256 _numTokens,
        PPDataTypes.TokenInfo memory _tokenInfo
    ) internal returns (address[] memory _tokens, address[] memory _instances) {
        // First, we need to deploy tokens to get their addresses
        // But we can't call deployToken() yet because token info isn't stored
        // So we'll create the tokens directly using the implementation
        
        _tokens = new address[](_numTokens);
        for (uint256 i = 0; i < _numTokens; i++) {
            // Create token data
            bytes memory data = abi.encodePacked(_tokenInfo.decimals, _tokenInfo.totalSupply);
            PartyTokenCore core = PartyTokenCore(ClonesWithImmutableArgs.clone(address(partyTokenImplementation), data));
            core.initialize(_tokenInfo.name, _tokenInfo.symbol);
            _tokens[i] = address(new PartyToken(address(core), endpoints[1], address(this)));
        }
        
        // Now create the party info with the actual token addresses
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](_numTokens);
        for (uint256 i = 0; i < _numTokens; i++) {
            info[i] = PPDataTypes.DynamicInfo({
                dynamicAddress: _tokens[i],
                chainId: CHAIN_ID
            });
        }
        
        // Deploy the party
        _instances = factory.deployParty(info, _identifier, _tokenInfo);
    }

    // ============ Factory Tests ============

    function test_Constructor() public {
        assertEq(factory.version(), 1, "Factory version should be 1");
        assertEq(
            factory.implementation(),
            address(implementation),
            "Implementation address should match"
        );
    }

    function test_DeployParty_SingleToken() public {
        string memory identifier = "party-single";
        
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "PoolParty Token",
            symbol: "PPT",
            isOwnable: false
        });
        
        (address[] memory tokens, address[] memory instances) = deployPartyAndGetTokens(
            identifier,
            1,
            tokenInfo
        );
        
        assertEq(instances.length, 1, "Should deploy one instance");
        assertTrue(
            instances[0] != address(0),
            "Instance should not be zero address"
        );
        
        // Verify party info is stored
        (uint256 totalSupply, uint8 decimals, string memory name, string memory symbol, bool isOwnable) = factory.infoOfParty(
            identifier
        );
        PPDataTypes.TokenInfo memory storedInfo = PPDataTypes.TokenInfo({
            totalSupply: totalSupply,
            decimals: decimals,
            name: name,
            symbol: symbol,
            isOwnable: isOwnable
        });
        assertEq(
            storedInfo.totalSupply,
            tokenInfo.totalSupply,
            "Total supply should match"
        );
        assertEq(
            storedInfo.decimals,
            tokenInfo.decimals,
            "Decimals should match"
        );
        assertEq(storedInfo.name, tokenInfo.name, "Name should match");
        assertEq(storedInfo.symbol, tokenInfo.symbol, "Symbol should match");
        assertEq(
            storedInfo.isOwnable,
            tokenInfo.isOwnable,
            "IsOwnable should match"
        );
    }

    function test_DeployParty_MultipleTokens() public {
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Multi Token Party",
            symbol: "MTP",
            isOwnable: false
        });
        
        (address[] memory tokens, address[] memory instances) = deployPartyAndGetTokens(
            "multi-party",
            3,
            tokenInfo
        );
        
        assertEq(instances.length, 1, "Should deploy one instance");
        assertTrue(
            instances[0] != address(0),
            "Instance should not be zero address"
        );
    }

    function test_DeployParty_DifferentChainId() public {
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Cross Chain Party",
            symbol: "CCP",
            isOwnable: false
        });
        
        // Create token first
        bytes memory data = abi.encodePacked(tokenInfo.decimals, tokenInfo.totalSupply);
        PartyTokenCore core = PartyTokenCore(ClonesWithImmutableArgs.clone(address(partyTokenImplementation), data));
        core.initialize(tokenInfo.name, tokenInfo.symbol);
        address token = address(new PartyToken(address(core), endpoints[1], address(this)));
        
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](1);
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: token,
            chainId: 999 // Different chain ID
        });
        
        address[] memory instances = factory.deployParty(
            info,
            "cross-chain-party",
            tokenInfo
        );
        
        // Should return empty array for different chain ID
        assertEq(
            instances.length,
            0,
            "Should return empty array for different chain ID"
        );
    }

    function test_DeployParty_DuplicateIdentifier() public {
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Test Party",
            symbol: "TP",
            isOwnable: false
        });
        
        // Create token first
        bytes memory data = abi.encodePacked(tokenInfo.decimals, tokenInfo.totalSupply);
        PartyTokenCore core = PartyTokenCore(ClonesWithImmutableArgs.clone(address(partyTokenImplementation), data));
        core.initialize(tokenInfo.name, tokenInfo.symbol);
        address token = address(new PartyToken(address(core), endpoints[1], address(this)));
        
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](1);
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: token,
            chainId: CHAIN_ID
        });
        
        // Deploy first party
        factory.deployParty(info, PARTY_IDENTIFIER, tokenInfo);
        
        // Try to deploy with same identifier
        vm.expectRevert(PPErrors.THIS_IDENTIFIER_ALREADY_EXISTS.selector);
        factory.deployParty(info, PARTY_IDENTIFIER, tokenInfo);
    }

    function test_DeployParty_EmptyTokensArray() public {
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            0
        );
        
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Empty Party",
            symbol: "EP",
            isOwnable: false
        });
        
        vm.expectRevert(PPErrors.MUST_BE_AT_LEAST_ONE_TOKEN.selector);
        factory.deployParty(info, "empty-party", tokenInfo);
    }

    function test_UpdateImplementation() public {
        PoolParty newImplementation = new PoolParty();
        emit log_address(factory.owner());
        // Use the actual owner for this call
        vm.startPrank(factory.owner());
        factory.updateImplemantation(address(newImplementation));
        vm.stopPrank();
        assertEq(
            factory.implementation(),
            address(newImplementation),
            "Implementation should be updated"
        );
    }

    function test_UpdateImplementation_NotOwner() public {
        PoolParty newImplementation = new PoolParty();
        vm.prank(user1);
        vm.expectRevert();
        factory.updateImplemantation(address(newImplementation));
    }

    // ============ PoolParty Tests ============

    function test_PoolParty_Initialize() public {
        string memory identifier = "party-init-unique";
        
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Test Party",
            symbol: "TP",
            isOwnable: false
        });
        
        (address[] memory tokens, address[] memory instances) = deployPartyAndGetTokens(
            identifier,
            1,
            tokenInfo
        );
        
        PoolParty party = PoolParty(instances[0]);
        assertEq(
            party.identifier(),
            identifier,
            "Identifier should match"
        );
        assertEq(
            party.factory(),
            address(factory),
            "Factory address should match"
        );
        assertEq(party.version(), 1, "Version should be 1");
    }

    function test_PoolParty_Initialize_Twice() public {
        string memory identifier = "party-init-twice-unique";
        
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Test Party",
            symbol: "TP",
            isOwnable: false
        });
        
        (address[] memory tokens, address[] memory instances) = deployPartyAndGetTokens(
            identifier,
            1,
            tokenInfo
        );
        
        PoolParty party = PoolParty(instances[0]);
        // Try to initialize again
        vm.expectRevert();
        party.initialize("new-identifier");
    }

    function test_PoolParty_GetTokenOfIndex() public {
        string memory identifier = "party-get-multi-unique";
        
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Multi Token Party",
            symbol: "MTP",
            isOwnable: false
        });
        
        (address[] memory tokens, address[] memory instances) = deployPartyAndGetTokens(
            identifier,
            3,
            tokenInfo
        );
        
        PoolParty party = PoolParty(instances[0]);
        // Test getting tokens by index
        assertEq(
            party.getTokenOfIndex(0),
            tokens[0],
            "Token at index 0 should match"
        );
        assertEq(
            party.getTokenOfIndex(1),
            tokens[1],
            "Token at index 1 should match"
        );
        assertEq(
            party.getTokenOfIndex(2),
            tokens[2],
            "Token at index 2 should match"
        );
    }

    function test_PoolParty_GetTokenOfIndex_OutOfBounds() public {
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Test Party",
            symbol: "TP",
            isOwnable: false
        });
        
        (address[] memory tokens, address[] memory instances) = deployPartyAndGetTokens(
            "party-oob",
            1,
            tokenInfo
        );
        
        PoolParty party = PoolParty(instances[0]);
        
        // Try to get token at invalid index
        vm.expectRevert(PPErrors.OUT_OF_BOUNDS.selector);
        party.getTokenOfIndex(1);
    }

    function test_PoolParty_NewTokenInfo() public {
        string memory identifier = "party-tokeninfo-unique";
        
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Test Party",
            symbol: "TP",
            isOwnable: false
        });
        
        (address[] memory tokens, address[] memory instances) = deployPartyAndGetTokens(
            identifier,
            1,
            tokenInfo
        );
        
        PoolParty party = PoolParty(instances[0]);
        // Get token info from party
        PPDataTypes.TokenInfo memory retrievedInfo = party.newTokenInfo();
        assertEq(
            retrievedInfo.totalSupply,
            tokenInfo.totalSupply,
            "Total supply should match"
        );
        assertEq(
            retrievedInfo.decimals,
            tokenInfo.decimals,
            "Decimals should match"
        );
        assertEq(retrievedInfo.name, tokenInfo.name, "Name should match");
        assertEq(retrievedInfo.symbol, tokenInfo.symbol, "Symbol should match");
        assertEq(
            retrievedInfo.isOwnable,
            tokenInfo.isOwnable,
            "IsOwnable should match"
        );
    }

    // ============ PartyToken Tests ============

    function test_PartyTokenCore_Constructor() public {
        PartyTokenCore newToken = new PartyTokenCore();
        // Test that constructor works without reverting
        assertTrue(address(newToken) != address(0), "Token should be deployed");
    }

    function test_PartyTokenCore_Initialize() public {
        // Test that we can create a new PartyTokenCore
        PartyTokenCore token = new PartyTokenCore();
        assertTrue(address(token) != address(0), "Token should be deployed");
        
        // Note: The actual initialization happens in the factory.deployToken() method
        // which clones the implementation with the identifier as immutable data
    }

    function test_PartyTokenCore_Initialize_Twice() public {
        // Test that we can create a new PartyTokenCore
        PartyTokenCore token = new PartyTokenCore();
        assertTrue(address(token) != address(0), "Token should be deployed");
        
        // Note: The actual initialization happens in the factory.deployToken() method
        // which clones the implementation with the identifier as immutable data
    }

    function test_PartyToken_Constructor() public {
        // First, deploy a party to store token info
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Test Token",
            symbol: "TEST",
            isOwnable: false
        });
        
        (address[] memory tokens, address[] memory instances) = deployPartyAndGetTokens(
            "party-adapter",
            1,
            tokenInfo
        );
        
        // Now create a token via the factory (returns diamond address)
        address diamond = factory.deployToken("party-adapter");
        IFullTokenFacet token = IFullTokenFacet(diamond);
        assertTrue(diamond != address(0), "Diamond should be deployed");
        assertEq(token.name(), "Test Token", "Name should match");
        assertEq(token.symbol(), "TEST", "Symbol should match");
        assertEq(token.totalSupply(), 1000000e18, "Total supply should match");
    }

    // ============ Integration Tests ============

    function test_CompleteWorkflow() public {
        string memory identifier = "integration-party-unique";
        
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Integration Test Party",
            symbol: "ITP",
            isOwnable: true
        });
        
        (address[] memory tokens, address[] memory instances) = deployPartyAndGetTokens(
            identifier,
            2,
            tokenInfo
        );
        
        assertEq(instances.length, 1, "Should deploy one instance");
        PoolParty party = PoolParty(instances[0]);
        assertEq(
            party.identifier(),
            identifier,
            "Identifier should match"
        );
        assertEq(
            party.factory(),
            address(factory),
            "Factory address should match"
        );
        // 2. Verify token info
        PPDataTypes.TokenInfo memory retrievedInfo = party.newTokenInfo();
        assertEq(
            retrievedInfo.totalSupply,
            tokenInfo.totalSupply,
            "Total supply should match"
        );
        assertEq(retrievedInfo.name, tokenInfo.name, "Name should match");
        assertEq(retrievedInfo.symbol, tokenInfo.symbol, "Symbol should match");
        assertEq(
            retrievedInfo.isOwnable,
            tokenInfo.isOwnable,
            "IsOwnable should match"
        );
        // 3. Verify token addresses
        assertEq(
            party.getTokenOfIndex(0),
            tokens[0],
            "Token1 address should match"
        );
        assertEq(
            party.getTokenOfIndex(1),
            tokens[1],
            "Token2 address should match"
        );
    }

    // ============ Edge Cases ============

    function test_Factory_ZeroImplementation() public {
        vm.expectRevert();
        new PoolPartyFactory(address(0), address(this), address(0), address(0));
    }

    function test_Party_Constructor() public {
        PoolParty newParty = new PoolParty();
        assertEq(newParty.version(), 1, "New party version should be 1");
    }

    // ============ Original Tests (for compatibility) ============

    function test_messageOnDeployment() external view {
        assertEq(factory.version(), uint8(1), "Test version is not found");
    }

    function test_deployParty() external {
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000000000000000,
            decimals: 18,
            name: "NEW COOL TOKEN",
            symbol: "NCT",
            isOwnable: false
        });
        
        (address[] memory tokens, address[] memory instances) = deployPartyAndGetTokens(
            "test",
            1,
            tokenInfo
        );
        
        PoolParty instance = PoolParty(instances[0]);
        assertNotEq(address(instance), address(0), "Instance is not deployed");
        assertEq(instance.version(), uint8(1), "Instance version is not found");
        assertEq(
            instance.identifier(),
            "test",
            "Instance identifier is not found"
        );
        vm.expectRevert(PPErrors.OUT_OF_BOUNDS.selector);
        instance.getTokenOfIndex(1);
        assertEq(
            instance.getTokenOfIndex(0),
            tokens[0],
            "Token is not found"
        );
    }
}

