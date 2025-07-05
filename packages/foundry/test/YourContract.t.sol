// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "forge-std/Test.sol";

/* Our Own Deploy Script */
import {DeployScript} from "../script/Deploy.s.sol";

/* Our Contracts */
import {PoolPartyFactory} from "../contracts/PoolPartyFactory.sol";
import {PoolParty} from "../contracts/PoolParty.sol";

/* Our libraries */
import {PPDataTypes} from "../contracts/libraries/PPDataTypes.sol";

/* Mock Contracts */
import {ERC20Mock} from "./mocks/ERC20Mock.sol";

/* LayerZero Test DevTools */
import { TestHelperOz5 } from "@layerzerolabs/test-devtools-evm-foundry/contracts/TestHelperOz5.sol";

contract YourContractTest is TestHelperOz5 {
    PoolPartyFactory factory;
    PoolParty implementation;

    function setUp() public virtual override {
        super.setUp();
        setUpEndpoints(1, LibraryType.UltraLightNode);
        DeployScript partyDeployer = new DeployScript();
        (address implementationAddr, address factoryAddr) = partyDeployer.run(endpoints[1]);
        (implementation, factory) = (
            PoolParty(implementationAddr),
            PoolPartyFactory(factoryAddr)
        );
    }

    function test_messageOnDeployment() external view {
        assertEq(factory.version(), uint8(1), "Test version is not found");
    }

    function test_deployParty() external {
        ERC20Mock token = new ERC20Mock("Cool Test Token", "CTT");
        PPDataTypes.DynamicInfo[] memory info = new PPDataTypes.DynamicInfo[](1);
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
        assertEq(instance.identifier(), "test", "Instance identifier is not found");
    }
}
