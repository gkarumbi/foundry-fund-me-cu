// 1. Deploy mocks when we are on a lo al anvil chain
// 2. p track of a contract address across different chains
// Eg . Sepolia ETH/USD
// Mainet ETH/USD

//SPDX-License-Identifier: MIT

pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {MockV3Aggregator} from "../test/mocks/MockV3Aggregator.sol";

contract HelperConfig is Script{
    //If we are on  alocal anvil, we deploy mocks/
    //Otherwise, grab the existing address from the live network

    NetworkConfig public activeNetworkConfig;
    uint8 public constant ETH_DECIMALS = 8;
    int256 public constant INTIAL_PRICE = 2000e8;

    //Create a struct of type Network Config
    constructor(){
        if(block.chainid == 11155111){
            activeNetworkConfig = getSepoliaEthConfig();

        } else if(block.chainid == 1){
            activeNetworkConfig = getMainnetEthConfig();

        }
         else{
            activeNetworkConfig = getOrCreateAnvilEthConfig();
        }
    }
    struct NetworkConfig{
        address priceFeed; // ETH/USD price feed address
    }

    function getSepoliaEthConfig() public pure returns (NetworkConfig memory){
        //price feed address
        NetworkConfig memory sepoliaConfig = NetworkConfig({
            priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306
            });
        
        return sepoliaConfig;


    }

     function getMainnetEthConfig() public pure returns (NetworkConfig memory){
        //price feed address
        NetworkConfig memory ethConfig = NetworkConfig({
            priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
            });
        
        return ethConfig;


    }

    function getOrCreateAnvilEthConfig() public  returns (NetworkConfig memory){
        if(activeNetworkConfig.priceFeed != address(0)){
            return activeNetworkConfig;
        }

        //1. Deploy the mocks
        //2. Return the mock address
        vm.startBroadcast();
        MockV3Aggregator mockPriceFeed = new MockV3Aggregator(ETH_DECIMALS, INTIAL_PRICE);
        vm.stopBroadcast();

        NetworkConfig memory anvilConfig = NetworkConfig({
            priceFeed: address(mockPriceFeed)
        });

        return anvilConfig;

    }
}