// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "forge-std/Test.sol";

/* Our Own Deploy Script */
import {DeployScript} from "../script/Deploy.s.sol";

/* Our Contracts */
import {PoolPartyFactory} from "../contracts/PoolPartyFactory.sol";
import {PoolParty} from "../contracts/PoolParty.sol";
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
}
