// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract CreateSubscription is Script {
    function createSubscriptionUsingConfig() public returns(uint256, address)  {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;

        (uint256 subscriptionId, ) = createSubscription(vrfCoordinator);

        return (subscriptionId, vrfCoordinator);

    }

    function createSubscription(address vrfCoordinator) public returns(uint256, address) {
        console.log("Creating subscription on chain Id: ", block.chainid);
        vm.startBroadcast();
        uint256 subscriptionId = VRFCoordinatorV2_5Mock(vrfCoordinator).createSubscription();

        vm.stopBroadcast();

        console.log("your subscription id is: ", subscriptionId);
        return (subscriptionId, vrfCoordinator);
        
    }

    function run() public {
        createSubscriptionUsingConfig();
    }
}


contract FundSubscription is Script {
    uint256 public constant FUND_AMOUNT = 0.3  ether;

    function fundSubscriptionUsingConfig() public {
        HelperConfig helperConfig = new HelperConfig();
        address vrfCoordinator = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;

        
    }

    function run() public {
        
    }
}