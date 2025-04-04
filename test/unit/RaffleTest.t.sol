// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {DeployRaffle} from "../../script/DeployRaffle.s.sol";
import {Raffle} from "../../src/Raffle.sol";
import {HelperConfig} from "../../script/HelperConfig.s.sol";

contract RaffleTest is Test {
    Raffle raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLane;
    uint32 callbackGasLimit;
    uint256 subscriptionId;

    address public PLAYER = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    event RaffleEntered(address indexed player);


    function setUp() external {
        DeployRaffle deployer = new DeployRaffle();
        (raffle, helperConfig) = deployer.deployRaffle();

        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLane = config.gasLane;
        callbackGasLimit = config.callbackGasLimit;
        subscriptionId = config.subscriptionId;
    }

    function testRaffleInitializesInOpenState() public view {
        assertEq(uint(raffle.getRaffleState()), uint(Raffle.RaffleState.OPEN));
    }


    function testRaffleRevertsWhenDontPaidEnough() public {
        vm.prank(PLAYER);
        vm.expectRevert(Raffle.SendMoreToEnterRaffle.selector);

        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayerWhenTheyEnter() public {
        vm.prank(PLAYER);
        vm.deal(PLAYER, 10e18);
        raffle.enterRaffle{value: entranceFee}();

        address playerRecorded = raffle.getPlayer(0);
        
        assertEq(PLAYER, playerRecorded);
    }

    function testEnteringRaffleEmitsEvent() public {
        vm.prank(PLAYER);
        vm.deal(PLAYER, 10e18);
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYER);
        
        raffle.enterRaffle{value: entranceFee}();
    }

    function testDontAllowPlayersToEnterWhileRaffleIsCalculating() public {
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee}();

        // sets the timestamp
        vm.warp(block.timestamp + interval + 1);
        // sets the block number
        vm.roll(block.number + 1);
        raffle.performUpkeep("");

        vm.expectRevert(Raffle.Raffle_NotOpen.selector);
        vm.prank(PLAYER);
        raffle.enterRaffle{value: entranceFee }();  
    }
}
