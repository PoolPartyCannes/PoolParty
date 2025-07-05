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

    // Test tokens
    ERC20Mock public token1;
    ERC20Mock public token2;
    ERC20Mock public token3;

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
        (address implementationAddr, address factoryAddr) = partyDeployer.run(
            endpoints[1]
        );
        (implementation, factory) = (
            PoolParty(implementationAddr),
            PoolPartyFactory(factoryAddr)
        );

        // Deploy test tokens
        token1 = new ERC20Mock("Token 1", "TK1");
        token2 = new ERC20Mock("Token 2", "TK2");
        token3 = new ERC20Mock("Token 3", "TK3");

        // Mint tokens to users
        token1.mint(user1, 1000e18);
        token2.mint(user2, 1000e18);
        token3.mint(user3, 1000e18);

        // Mint tokens to owner for testing
        token1.mint(address(this), 1000e18);
        token2.mint(address(this), 1000e18);
        token3.mint(address(this), 1000e18);
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
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
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
            PARTY_IDENTIFIER,
            tokenInfo
        );

        assertEq(instances.length, 1, "Should deploy one instance");
        assertTrue(
            instances[0] != address(0),
            "Instance should not be zero address"
        );

        // Verify party info is stored
        PPDataTypes.TokenInfo memory storedInfo = factory.infoOfParty(
            PARTY_IDENTIFIER
        );
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
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            3
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
            chainId: CHAIN_ID
        });
        info[1] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token2),
            chainId: CHAIN_ID
        });
        info[2] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token3),
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
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
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
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
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
        factory.updateImplemantation(address(newImplementation));

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
        // Deploy a party
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
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

        assertEq(
            party.identifier(),
            PARTY_IDENTIFIER,
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
        // Deploy a party
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
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

        // Try to initialize again
        vm.expectRevert();
        party.initialize("new-identifier");
    }

    function test_PoolParty_DepositToken() public {
        // Deploy a party
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
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

        // User deposits tokens
        vm.startPrank(user1);

        uint256 depositAmount = 100e18;
        uint256 balanceBefore = token1.balanceOf(user1);

        token1.approve(address(party), depositAmount);

        vm.expectEmit(true, false, false, true);
        emit PPEvents.YouJoinedTheParty(user1, depositAmount);

        bool success = party.depositToken(address(token1), depositAmount);

        assertTrue(success, "Deposit should succeed");
        assertEq(
            party.depositOf(user1, address(token1)),
            depositAmount,
            "Deposit amount should match"
        );
        assertEq(
            token1.balanceOf(user1),
            balanceBefore - depositAmount,
            "User balance should decrease"
        );
        assertEq(
            token1.balanceOf(address(party)),
            depositAmount,
            "Party balance should increase"
        );

        vm.stopPrank();
    }

    function test_PoolParty_DepositToken_MultipleUsers() public {
        // Deploy a party with multiple tokens
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            2
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
            chainId: CHAIN_ID
        });
        info[1] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token2),
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
        PoolParty party = PoolParty(instances[0]);

        // User1 deposits token1
        vm.startPrank(user1);
        token1.approve(address(party), 100e18);
        bool success1 = party.depositToken(address(token1), 100e18);
        assertTrue(success1, "User1 deposit should succeed");
        assertEq(
            party.depositOf(user1, address(token1)),
            100e18,
            "User1 deposit amount should match"
        );
        vm.stopPrank();

        // User2 deposits token2
        vm.startPrank(user2);
        token2.approve(address(party), 200e18);
        bool success2 = party.depositToken(address(token2), 200e18);
        assertTrue(success2, "User2 deposit should succeed");
        assertEq(
            party.depositOf(user2, address(token2)),
            200e18,
            "User2 deposit amount should match"
        );
        vm.stopPrank();

        // User1 deposits more token1
        vm.startPrank(user1);
        token1.approve(address(party), 50e18);
        bool success3 = party.depositToken(address(token1), 50e18);
        assertTrue(success3, "User1 second deposit should succeed");
        assertEq(
            party.depositOf(user1, address(token1)),
            150e18,
            "User1 total deposit should match"
        );
        vm.stopPrank();
    }

    function test_PoolParty_DepositToken_NotAvailable() public {
        // Deploy a party with only token1
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
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

        // Try to deposit token2 which is not in the allowed list
        vm.startPrank(user2);
        token2.approve(address(party), 100e18);
        vm.expectRevert(PPErrors.TOKEN_NOT_AVAILABLE.selector);
        party.depositToken(address(token2), 100e18);
        vm.stopPrank();
    }

    function test_PoolParty_DepositToken_ZeroAmount() public {
        // Deploy a party
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
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

        // Try to deposit zero amount
        vm.startPrank(user1);
        token1.approve(address(party), 0);
        vm.expectRevert(PPErrors.DEPOSIT_FAILED.selector);
        party.depositToken(address(token1), 0);
        vm.stopPrank();
    }

    function test_PoolParty_GetTokenOfIndex() public {
        // Deploy a party with multiple tokens
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            3
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
            chainId: CHAIN_ID
        });
        info[1] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token2),
            chainId: CHAIN_ID
        });
        info[2] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token3),
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
        PoolParty party = PoolParty(instances[0]);

        // Test getting tokens by index
        assertEq(
            party.getTokenOfIndex(0),
            address(token1),
            "Token at index 0 should match"
        );
        assertEq(
            party.getTokenOfIndex(1),
            address(token2),
            "Token at index 1 should match"
        );
        assertEq(
            party.getTokenOfIndex(2),
            address(token3),
            "Token at index 2 should match"
        );
    }

    function test_PoolParty_GetTokenOfIndex_OutOfBounds() public {
        // Deploy a party with one token
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
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
        // Deploy a party
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
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

    // ============ Integration Tests ============

    function test_CompleteWorkflow() public {
        // 1. Deploy a party with multiple tokens
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            2
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
            chainId: CHAIN_ID
        });
        info[1] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token2),
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
            "integration-party",
            tokenInfo
        );
        assertEq(instances.length, 1, "Should deploy one instance");

        PoolParty party = PoolParty(instances[0]);
        assertEq(
            party.identifier(),
            "integration-party",
            "Identifier should match"
        );
        assertEq(
            party.factory(),
            address(factory),
            "Factory address should match"
        );

        // 2. Multiple users deposit different tokens
        // User1 deposits token1
        vm.startPrank(user1);
        token1.approve(address(party), 100e18);
        bool success1 = party.depositToken(address(token1), 100e18);
        assertTrue(success1, "User1 deposit should succeed");
        assertEq(
            party.depositOf(user1, address(token1)),
            100e18,
            "User1 deposit amount should match"
        );
        vm.stopPrank();

        // User2 deposits token2
        vm.startPrank(user2);
        token2.approve(address(party), 200e18);
        bool success2 = party.depositToken(address(token2), 200e18);
        assertTrue(success2, "User2 deposit should succeed");
        assertEq(
            party.depositOf(user2, address(token2)),
            200e18,
            "User2 deposit amount should match"
        );
        vm.stopPrank();

        // User3 deposits token1
        vm.startPrank(user3);
        token1.approte(address(party), 50e18);
        bool success3 = party.depositToken(address(token1), 50e18);
        assertTrue(success3, "User3 deposit should succeed");
        assertEq(
            party.depositOf(user3, address(token1)),
            50e18,
            "User3 deposit amount should match"
        );
        vm.stopPrank();

        // 3. Verify total deposits
        assertEq(
            party.depositOf(user1, address(token1)),
            100e18,
            "User1 total deposit should match"
        );
        assertEq(
            party.depositOf(user2, address(token2)),
            200e18,
            "User2 total deposit should match"
        );
        assertEq(
            party.depositOf(user3, address(token1)),
            50e18,
            "User3 total deposit should match"
        );

        // 4. Verify token balances
        assertEq(
            token1.balanceOf(address(party)),
            150e18,
            "Party token1 balance should match"
        );
        assertEq(
            token2.balanceOf(address(party)),
            200e18,
            "Party token2 balance should match"
        );

        // 5. Verify token info
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
    }

    // ============ Edge Cases ============

    function test_DepositToken_Reentrancy() public {
        // Deploy a party
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token1),
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

        // Test deposit with exact balance
        vm.startPrank(user1);
        uint256 userBalance = token1.balanceOf(user1);
        token1.approve(address(party), userBalance);

        bool success = party.depositToken(address(token1), userBalance);
        assertTrue(success, "Deposit should succeed");
        assertEq(
            party.depositOf(user1, address(token1)),
            userBalance,
            "Deposit amount should match"
        );
        assertEq(token1.balanceOf(user1), 0, "User balance should be zero");

        vm.stopPrank();
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
        ERC20Mock token = new ERC20Mock("Cool Test Token", "CTT");
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](
            1
        );
        info[0] = PPDataTypes.DynamicInfo({
            dynamicAddress: address(token),
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
            address(token),
            "Token is not found"
        );
    }
}
