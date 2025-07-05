// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Test.sol";

/* Our Own Deploy Script */
import {DeployScript} from "../script/Deploy.s.sol";

/* Our Contracts */
import {PoolPartyFactory} from "../contracts/PoolPartyFactory.sol";
import {PoolParty} from "../contracts/PoolParty.sol";

contract YourContractTest is Test {
    PoolPartyFactory factory;
    PoolParty implementation;

    function setUp() public {
        DeployScript partyDeployer = new DeployScript();
        (implementation, factory) = partyDeployer.run();
    }

    //    function test_messageOnDeployment() external {
    //        urequire(keccak256(bytes(yourContract.greeting())) == keccak256("Building Unstoppable Apps!!!"));
    //    }
}
