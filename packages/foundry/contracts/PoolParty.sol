//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/* sw0nt contracts */
import {Clone} from "@sw0nt/contracts/Clone.sol";

/* solady contracts */
import {Initializable} from "@solady/contracts/utils/Initializable.sol";
import {SafeTransferLib} from "@solady/contracts/utils/SafeTransferLib.sol";
import {ERC20} from "@solady/contracts/tokens/ERC20.sol";

/* PoolParty libraries */
import {PPErrors} from "./libraries/PPErrors.sol";
import {PPEvents} from "./libraries/PPEvents.sol";

/**
 * @title PoolParty
 * @author https://x.com/0xjsieth
 * @notice Contract for deploying the new token, as a diamond facet
 *
 */
contract PoolParty is Initializable, Clone {
    using SafeTransferLib for address;

    mapping(address who => mapping(address token => uint256 amount))
        public depositOf;
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

    function factory() external pure returns (address _factory) {
        _factory = _getArgAddress(1);
    }

    function depositToken(
        address _token,
        uint256 _amount
    ) external returns (bool _success) {
        uint256 amountBefore = ERC20(_token).balanceOf(address(this));
        uint256 amountOfTokens = _getArgUint8(0);
        bool exists;
        for (uint256 i = 0; i < amountOfTokens; ) {
            if (getTokenOfIndex(i) == _token) {
                exists = true;
            }
            unchecked {
                i++;
            }
        }
        if (!exists) revert PPErrors.TOKEN_NOT_AVAILABLE();
        _token.safeTransferFrom(msg.sender, address(this), _amount);
        uint256 amountAfter = ERC20(_token).balanceOf(address(this));
        uint256 successfulDeposit = amountAfter - amountBefore;
        if (successfulDeposit == 0) {
            revert PPErrors.DEPOSIT_FAILED();
        } else {
            depositOf[msg.sender][_token] += successfulDeposit;
            _success = true;
            emit PPEvents.YouJoinedTheParty(msg.sender, successfulDeposit);
        }
    }

    function getTokenOfIndex(
        uint256 _index
    ) public pure returns (address _token) {
        uint256 amountOfTokens = _getArgUint8(0);
        if (_index >= amountOfTokens) revert PPErrors.OUT_OF_BOUNDS();

        _token = _getArgAddress(21 + _index * 20);

        return _token;
    }
}
