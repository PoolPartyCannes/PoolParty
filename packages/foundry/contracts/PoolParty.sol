//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/* sw0nt contracts */
import {Clone} from "@sw0nt/contracts/Clone.sol";

/* solady contracts */
import {Initializable} from "@solady/contracts/utils/Initializable.sol";

/* OpenZeppelin libraries */
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title PoolParty
 * @author https://x.com/0xjsieth
 * @notice Contract for deploying the new token, as a diamond facet
 *
 */
contract PoolParty is Initializable, Clone {
    // Identifier fetched from walrus
    string public identifier;

    constructor() {
        _disableInitializers();
    }

    function initialize(string calldata _identifier) external initializer {
        identifier = _identifier;
    }
}
