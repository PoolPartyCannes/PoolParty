//SPDX-License-Identifier: MIT
pragma solidity 0.8.30;


/* Mudgen Contracts */
import {Diamond} from "@mudgen/contracts/Diamond.sol";
import {DiamondCutFacet} from "@mudgen/contracts/facets/DiamondCutFacet.sol";
import {DiamondInit} from "@mudgen/contracts/upgradeInitializers/DiamondInit.sol";
import {IDiamondCut} from "@mudgen/contracts/interfaces/IDiamondCut.sol";

/* PoolParty libraries */
import {PPDataTypes} from "./libraries/PPDataTypes.sol";

/**
 * @title PoolPartyFactory
 * @author https://x.com/0xjsieth
 * @notice Yo dawg, I heard you like proxy
 *   factories, so I put a proxy factory inside
 *   your proxy factory so you can delegatecall
 *   while you delegatecall!
 *
 */
abstract contract DiamondParty {
    function _diamondsOnMyBankAccount(
        address _fullToken,
        PPDataTypes.TokenInfo memory _tokenInfo
    ) internal returns (address _diamond) { 
        // Deploy the diamond with the fullToken as a facet
        DiamondCutFacet diamondCutFacet = new DiamondCutFacet();
        Diamond diamond = new Diamond(address(this), address(diamondCutFacet));

        // Deploy the DiamondInit
        DiamondInit diamondInit = new DiamondInit();

        // Define the function selectors for the FullTokenFacet
        bytes4[] memory fullTokenSelectors = new bytes4[](13);
        fullTokenSelectors[0] = bytes4(keccak256("initialize(string,string)"));
        fullTokenSelectors[1] = bytes4(keccak256("balanceOf(address)"));
        fullTokenSelectors[2] = bytes4(keccak256("totalSupply()"));
        fullTokenSelectors[3] = bytes4(keccak256("name()"));
        fullTokenSelectors[4] = bytes4(keccak256("symbol()"));
        fullTokenSelectors[5] = bytes4(keccak256("decimals()"));
        fullTokenSelectors[6] = bytes4(keccak256("transfer(address,uint256)"));
        fullTokenSelectors[7] = bytes4(keccak256("transferFrom(address,address,uint256)"));
        fullTokenSelectors[8] = bytes4(keccak256("approve(address,uint256)"));
        fullTokenSelectors[9] = bytes4(keccak256("allowance(address,address)"));
        fullTokenSelectors[10] = bytes4(keccak256("permit(address,address,uint256,uint256,uint8,bytes32,bytes32)"));
        fullTokenSelectors[11] = bytes4(keccak256("nonces(address)"));
        fullTokenSelectors[12] = bytes4(keccak256("DOMAIN_SEPARATOR()"));
        
        // Create the facet cut for the FullTokenFacet
        IDiamondCut.FacetCut[] memory facetCuts = new IDiamondCut.FacetCut[](1);
        facetCuts[0] = IDiamondCut.FacetCut({
            facetAddress: _fullToken,
            action: IDiamondCut.FacetCutAction.Add,
            functionSelectors: fullTokenSelectors
        });
        
        // Cut the facet into the diamond and initialize with DiamondInit
        IDiamondCut(address(diamond)).diamondCut(
            facetCuts,
            address(diamondInit),
            abi.encodeWithSignature("init()")
        );
        
        // Initialize the diamond's storage with the token info
        (bool success, ) = address(diamond).call(
            abi.encodeWithSignature("initialize(string,string)", _tokenInfo.name, _tokenInfo.symbol)
        );
        require(success, "Diamond initialize failed");
        
        _diamond = address(diamond);
    }

}