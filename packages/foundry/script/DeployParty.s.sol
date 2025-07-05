// SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

import "./DeployHelpers.s.sol";

import {PoolPartyFactory} from "../contracts/PoolPartyFactory.sol";
import {PoolParty} from "../contracts/PoolParty.sol";
import {TestHelperOz5} from "@layerzerolabs/test-devtools-evm-foundry/contracts/TestHelperOz5.sol";

/**
 * @notice Deploy script for YourContract contract
 * @dev Inherits ScaffoldETHDeploy which:
 *      - Includes forge-std/Script.sol for deployment
 *      - Includes ScaffoldEthDeployerRunner modifier
 *      - Provides `deployer` variable
 * Example:
 * yarn deploy --file DeployYourContract.s.sol  # local anvil chain
 * yarn deploy --file DeployYourContract.s.sol --network optimism # live network (requires keystore)
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
    function run(address _endpoint)
        external
        ScaffoldEthDeployerRunner
        returns (address _implementation, address _factory)
    {
        // Deploy the implementation contract first (no constructor parameters)
        _implementation = address(new PoolParty());

        // Then deploy the factory with the implementation address
        _factory = _deployOApp(
            type(PoolPartyFactory).creationCode,
            abi.encode(_endpoint, deployer, _implementation)
        );
    }

    function _deployOApp(
        bytes memory _oappBytecode,
        bytes memory _constructorArgs
    ) internal returns (address addr) {
        bytes memory bytecode = bytes.concat(
            abi.encodePacked(_oappBytecode),
            _constructorArgs
        );
        assembly {
            addr := create(0, add(bytecode, 0x20), mload(bytecode))
            if iszero(extcodesize(addr)) {
                revert(0, 0)
            }
        }
    }
}
