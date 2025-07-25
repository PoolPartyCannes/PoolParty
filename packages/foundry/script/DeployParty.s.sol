// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "./DeployHelpers.s.sol";

import {PoolPartyFactory} from "../contracts/PoolPartyFactory.sol";
import {PoolParty} from "../contracts/PoolParty.sol";
import {PartyToken} from "../contracts/PartyToken.sol";

/**
 * @notice Deploy script for PoolParty contracts
 * @dev Inherits ScaffoldETHDeploy which:
 *      - Includes forge-std/Script.sol for deployment
 *      - Includes ScaffoldEthDeployerRunner modifier
 *      - Provides `deployer` variable
 * Example:
 * yarn deploy --file DeployParty.s.sol  # local anvil chain
 * yarn deploy --file DeployParty.s.sol --network optimism # live network (requires keystore)
 */
contract DeployParty is ScaffoldETHDeploy {
    /**
     * @dev Deployer setup based on `ETH_KEYSTORE_ACCOUNT` in `.env`:
     *      - "scaffold-eth-default": Uses Anvil's account #9 (0xa0Ee7A142d267C1f36714E4a8F75612F20a79720), no password prompt
     *      - "scaffold-eth-custom": requires password used while creating keystore
     *
     * Note: Must use ScaffoldEthDeployerRunner modifier to:
     *      - Setup correct `deployer` account and fund it
     *      - Export contract addresses & ABIs to `nextjs` packages
     */
    function run()
        external
        ScaffoldEthDeployerRunner
        returns (
            address _implementation,
            address _tokenImplementation,
            address _factory
        )
    {
        // Deploy the implementation contract first (no constructor parameters)
        _implementation = address(new PoolParty());

        // Deploy the token implementation
        _tokenImplementation = address(new PartyToken());

        // Deploy the factory with the implementation addresses
        _factory = address(new PoolPartyFactory(
            _implementation,
            _tokenImplementation
        ));
    }
}
