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

/**
 * @title FullTokenFacet
 * @author https://x.com/0xjsieth
 * @notice Diamond facet for the full token functionality
 * This facet contains the core token logic that will be cut into the diamond
 */
contract FullTokenFacet {
    // The actual token implementation will be stored as a facet
    // This facet acts as a wrapper/interface to the token functionality
    
    event FullTokenInitialized(address indexed token, string name, string symbol);
    
    // Storage for the token address
    address public fullTokenAddress;
    
    /**
     * @notice Initialize the full token facet with the token address
     * @param _tokenAddress The address of the deployed token
     */
    function initializeFullToken(address _tokenAddress) external {
        require(fullTokenAddress == address(0), "FullTokenFacet: Already initialized");
        fullTokenAddress = _tokenAddress;
        emit FullTokenInitialized(_tokenAddress, "FullToken", "FT");
    }
    
    /**
     * @notice Get the token address
     * @return The address of the full token
     */
    function getFullTokenAddress() external view returns (address) {
        return fullTokenAddress;
    }
    
    /**
     * @notice Delegate call to the token's balanceOf function
     * @param account The account to check balance for
     * @return The balance of the account
     */
    function balanceOf(address account) external view returns (uint256) {
        return ERC20(fullTokenAddress).balanceOf(account);
    }
    
    /**
     * @notice Delegate call to the token's totalSupply function
     * @return The total supply of the token
     */
    function totalSupply() external view returns (uint256) {
        return ERC20(fullTokenAddress).totalSupply();
    }
    
    /**
     * @notice Delegate call to the token's name function
     * @return The name of the token
     */
    function name() external view returns (string memory) {
        return ERC20(fullTokenAddress).name();
    }
    
    /**
     * @notice Delegate call to the token's symbol function
     * @return The symbol of the token
     */
    function symbol() external view returns (string memory) {
        return ERC20(fullTokenAddress).symbol();
    }
    
    /**
     * @notice Delegate call to the token's decimals function
     * @return The decimals of the token
     */
    function decimals() external view returns (uint8) {
        return ERC20(fullTokenAddress).decimals();
    }
    
    /**
     * @notice Delegate call to the token's transfer function
     * @param to The recipient address
     * @param amount The amount to transfer
     * @return Success status
     */
    function transfer(address to, uint256 amount) external returns (bool) {
        return ERC20(fullTokenAddress).transfer(to, amount);
    }
    
    /**
     * @notice Delegate call to the token's transferFrom function
     * @param from The sender address
     * @param to The recipient address
     * @param amount The amount to transfer
     * @return Success status
     */
    function transferFrom(address from, address to, uint256 amount) external returns (bool) {
        return ERC20(fullTokenAddress).transferFrom(from, to, amount);
    }
    
    /**
     * @notice Delegate call to the token's approve function
     * @param spender The spender address
     * @param amount The amount to approve
     * @return Success status
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        return ERC20(fullTokenAddress).approve(spender, amount);
    }
    
    /**
     * @notice Delegate call to the token's allowance function
     * @param owner The owner address
     * @param spender The spender address
     * @return The allowance amount
     */
    function allowance(address owner, address spender) external view returns (uint256) {
        return ERC20(fullTokenAddress).allowance(owner, spender);
    }
} 