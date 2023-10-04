// SPDX-Indirect-License-Identifier: MIT

pragma solidity ^0.8.18;

import {Script, console} from "forge-std/Script.sol";
import {MockV3Aggregator} from "test/mock/MockV3Aggregator.sol";

contract HelperConfig is Script {
    struct NetworkConfig {
        address priceFeed;
        uint256 others;
    }

    NetworkConfig public activeNetworkConfig;
    uint256 private constant SEPOLIA_CHAIN_ID = 11155111;
    uint256 private constant MAINNET_CHAIN_ID = 1;
    uint8 private constant DECIMALS = 8;
    int256 private constant INITIAL_PRICE = 2000e8;

    constructor() {
        if (block.chainid == SEPOLIA_CHAIN_ID) {
            activeNetworkConfig = getSepoliaConfig();
        } else if (block.chainid == MAINNET_CHAIN_ID) {
            activeNetworkConfig = getMainnetConfig();
        } else {
            activeNetworkConfig = getOrCreateLocalConfig();
        }
    }

    function getSepoliaConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory config = NetworkConfig({priceFeed: 0x694AA1769357215DE4FAC081bf1f309aDC325306, others: 0});
        return config;
    }

    function getMainnetConfig() public pure returns (NetworkConfig memory) {
        NetworkConfig memory config = NetworkConfig({priceFeed: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419, others: 0});
        return config;
    }

    function getOrCreateLocalConfig() public returns (NetworkConfig memory) {
        if (activeNetworkConfig.priceFeed != address(0)) {
            return activeNetworkConfig;
        }

        console.log("Perhaps you are running a local network.(anvil or ganache)");
        console.log("Deploying MockV3Aggregator");

        vm.startBroadcast();
        MockV3Aggregator priceFeed = new MockV3Aggregator(
            DECIMALS,
            INITIAL_PRICE
        );
        vm.stopBroadcast();

        NetworkConfig memory config = NetworkConfig({priceFeed: address(priceFeed), others: 0});
        return config;
    }
}
