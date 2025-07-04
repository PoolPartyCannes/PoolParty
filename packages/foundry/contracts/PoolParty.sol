//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/* sw0nt contracts */
import {Clone} from "@sw0nt/contracts/Clone.sol";

/* solady contracts */
import {Initializable} from "@solady/contracts/utils/Initializable.sol";

/**
 * @title PoolParty
 * @author https://x.com/0xjsieth
 * @notice Contract for deploying the new token, as a diamond facet
 *
 */
contract PoolParty is Initializable, Clone {
    function initialize(
        address[] calldata _tokens,
        string calldata _identifier
    ) external {}
}
