//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/* sw0nt contracts */
import {Clone} from "@sw0nt/contracts/Clone.sol";

/* solady contracts */
import {Initializable} from "@solady/contracts/utils/Initializable.sol";

/* PoolParty libraries */
import {PPErrors} from "./libraries/PPErrors.sol";

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

    function version() external pure returns (uint8 _version) {
        _version = 1;
    }

    function initialize(string calldata _identifier) external initializer {
        identifier = _identifier;
    }

    function getTokenOfIndex(uint256 _index) external pure returns (address _token) {
        uint256 amountOfTokens = _getArgUint8(0);
        if (_index >= amountOfTokens) revert PPErrors.OUT_OF_BOUNDS();

        _token = _getArgAddress(1 + _index * 20);

        return _token;
    }
}
