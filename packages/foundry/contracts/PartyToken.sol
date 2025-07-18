//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;

/* LayerZero contracts */
import {OFTAdapter} from "@layerzerolabs/oft-evm/contracts/OFTAdapter.sol";

/* Solady contracts */
import {ERC20} from "@solady/contracts/tokens/ERC20.sol";
import {Initializable} from "@solady/contracts/utils/Initializable.sol";

/* OpenZeppelin contracts */
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

/* sw0nt contracts */
import {Clone} from "@sw0nt/contracts/Clone.sol";

contract PartyToken is ERC20, Initializable, Clone {
    string internal pName;
    string internal pSymbol;

    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory _name,
        string memory _symbol
    ) external initializer {
        pName = _name;
        pSymbol = _symbol;
    }

    function name() public view virtual override returns (string memory _name) {
        _name = pName;
    }

    function symbol()
        public
        view
        virtual
        override
        returns (string memory _symbol)
    {
        _symbol = pSymbol;
    }

    function decimals() public view virtual override returns (uint8 _decimals) {
        _decimals = _getArgUint8(0);
    }

    function totalSupply() public view override returns (uint256 _totalSupply) {
        _totalSupply = _getArgUint256(1);
    }
}