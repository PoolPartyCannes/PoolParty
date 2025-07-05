//SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import "./DeployHelpers.s.sol";
import {DeployParty} from "./DeployParty.s.sol";

/**
 * @notice Main deployment script for all contracts
 * @dev Run this when you want to deploy multiple contracts at once
 *
 * Example: yarn deploy # runs this script(without`--file` flag)
 */
contract DeployScript is ScaffoldETHDeploy {
    function run(address _endpoint)
        external
        returns (address _implementation, address _factory)
    {
        // Deploys all your contracts sequentially
        // Add new deployments here when needed

        DeployParty partyDeployer = new DeployParty();
        (_implementation, _factory) = partyDeployer.run(_endpoint);

        // Deploy another contract
        // DeployMyContract myContract = new DeployMyContract();
        // myContract.run();
    }
}
