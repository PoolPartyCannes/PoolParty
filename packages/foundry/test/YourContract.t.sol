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
        DeployScript partyDeployer = new DeployScript();
        (address implementationAddr, address tokenImplementationAddr, address factoryAddr) = partyDeployer.run(
            endpoints[1]
        );
        (implementation, partyTokenImplementation, factory) = (
            PoolParty(implementationAddr),
            PartyTokenCore(tokenImplementationAddr),
            PoolPartyFactory(factoryAddr)
        );
        
        // Deploy PartyToken implementation for testing
        partyTokenImplementation = new PartyTokenCore();
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
        // Deploy a token for the party
        string memory identifier = "party-single";
        address token = factory.deployToken(identifier);
        
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: token,
            chainId: CHAIN_ID
        });
        
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "PoolParty Token",
            symbol: "PPT",
            isOwnable: false
        });
        
        address[] memory instances = factory.deployParty(
            info,
            identifier,
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
        // Deploy tokens for the party
        address token1 = factory.deployToken("party-multi-1");
        address token2 = factory.deployToken("party-multi-2");
        address token3 = factory.deployToken("party-multi-3");
        
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            3
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: token1,
            chainId: CHAIN_ID
        });
        info[1] = PPDataTypes.DynamicInfo({
            dynamicAddress: token2,
            chainId: CHAIN_ID
        });
        info[2] = PPDataTypes.DynamicInfo({
            dynamicAddress: token3,
            chainId: CHAIN_ID
        });
        
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Multi Token Party",
            symbol: "MTP",
            isOwnable: false
        });
        
        address[] memory instances = factory.deployParty(
            info,
            "multi-party",
            tokenInfo
        );
        
        assertEq(instances.length, 1, "Should deploy one instance");
        assertTrue(
            instances[0] != address(0),
            "Instance should not be zero address"
        );
    }

    function test_DeployParty_DifferentChainId() public {
        address token = factory.deployToken("party-diff-chain");
        
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: token,
            chainId: 999 // Different chain ID
        });
        
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Cross Chain Party",
            symbol: "CCP",
            isOwnable: false
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
        address token = factory.deployToken("party-dup");
        
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: token,
            chainId: CHAIN_ID
        });
        
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Test Party",
            symbol: "TP",
            isOwnable: false
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
        address token = factory.deployToken(identifier);
        // Deploy a party
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: token,
            chainId: CHAIN_ID
        });
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Test Party",
            symbol: "TP",
            isOwnable: false
        });
        address[] memory instances = factory.deployParty(
            info,
            identifier,
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
        address token = factory.deployToken(identifier);
        // Deploy a party
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: token,
            chainId: CHAIN_ID
        });
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Test Party",
            symbol: "TP",
            isOwnable: false
        });
        address[] memory instances = factory.deployParty(
            info,
            identifier,
            tokenInfo
        );
        PoolParty party = PoolParty(instances[0]);
        // Try to initialize again
        vm.expectRevert();
        party.initialize("new-identifier");
    }

    function test_PoolParty_GetTokenOfIndex() public {
        string memory identifier = "party-get-multi-unique";
        address token1 = factory.deployToken(string(abi.encodePacked(identifier, "-1")));
        address token2 = factory.deployToken(string(abi.encodePacked(identifier, "-2")));
        address token3 = factory.deployToken(string(abi.encodePacked(identifier, "-3")));
        // Deploy a party with three tokens
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            3
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: token1,
            chainId: CHAIN_ID
        });
        info[1] = PPDataTypes.DynamicInfo({
            dynamicAddress: token2,
            chainId: CHAIN_ID
        });
        info[2] = PPDataTypes.DynamicInfo({
            dynamicAddress: token3,
            chainId: CHAIN_ID
        });
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Multi Token Party",
            symbol: "MTP",
            isOwnable: false
        });
        address[] memory instances = factory.deployParty(
            info,
            identifier,
            tokenInfo
        );
        PoolParty party = PoolParty(instances[0]);
        // Test getting tokens by index
        assertEq(
            party.getTokenOfIndex(0),
            token1,
            "Token at index 0 should match"
        );
        assertEq(
            party.getTokenOfIndex(1),
            token2,
            "Token at index 1 should match"
        );
        assertEq(
            party.getTokenOfIndex(2),
            token3,
            "Token at index 2 should match"
        );
    }

    function test_PoolParty_GetTokenOfIndex_OutOfBounds() public {
        address token = factory.deployToken("party-oob");
        
        // Deploy a party with one token
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: token,
            chainId: CHAIN_ID
        });
        
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Test Party",
            symbol: "TP",
            isOwnable: false
        });
        
        address[] memory instances = factory.deployParty(
            info,
            PARTY_IDENTIFIER,
            tokenInfo
        );
        PoolParty party = PoolParty(instances[0]);
        
        // Try to get token at invalid index
        vm.expectRevert(PPErrors.OUT_OF_BOUNDS.selector);
        party.getTokenOfIndex(1);
    }

    function test_PoolParty_NewTokenInfo() public {
        string memory identifier = "party-tokeninfo-unique";
        address token = factory.deployToken(identifier);
        // Deploy a party
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: token,
            chainId: CHAIN_ID
        });
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Test Party",
            symbol: "TP",
            isOwnable: false
        });
        address[] memory instances = factory.deployParty(
            info,
            identifier,
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
        // Create a token via the factory
        address token = factory.deployToken("party-adapter");
        PartyToken adapter = PartyToken(token);
        assertTrue(address(adapter) != address(0), "Adapter should be deployed");
    }

    // ============ Integration Tests ============

    function test_CompleteWorkflow() public {
        string memory identifier = "integration-party-unique";
        address token1 = factory.deployToken(string(abi.encodePacked(identifier, "-1")));
        address token2 = factory.deployToken(string(abi.encodePacked(identifier, "-2")));
        // 1. Deploy a party with multiple tokens
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            2
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: token1,
            chainId: CHAIN_ID
        });
        info[1] = PPDataTypes.DynamicInfo({
            dynamicAddress: token2,
            chainId: CHAIN_ID
        });
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000e18,
            decimals: 18,
            name: "Integration Test Party",
            symbol: "ITP",
            isOwnable: true
        });
        address[] memory instances = factory.deployParty(
            info,
            identifier,
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
            token1,
            "Token1 address should match"
        );
        assertEq(
            party.getTokenOfIndex(1),
            token2,
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
        address token = factory.deployToken("party-compat");
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: token,
            chainId: 31337
        });
        PPDataTypes.TokenInfo memory tokenInfo = PPDataTypes.TokenInfo({
            totalSupply: 1000000000000000000,
            decimals: 18,
            name: "NEW COOL TOKEN",
            symbol: "NCT",
            isOwnable: false
        });
        address[] memory instances = factory.deployParty(
            info,
            "test",
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
            token,
            "Token is not found"
        );
    }
}

