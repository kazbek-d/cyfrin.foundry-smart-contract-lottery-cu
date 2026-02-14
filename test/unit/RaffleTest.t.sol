// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {DeployRaffle} from "script/DeployRaffle.s.sol";
import {Raffle} from "src/Raffle.sol";
import {HelperConfig, CodeConstants} from "script/HelperConfig.s.sol";
import {Vm} from "forge-std/Vm.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";

contract RaffleTest is Test, CodeConstants {
    Raffle public raffle;
    HelperConfig public helperConfig;

    uint256 entranceFee;
    uint256 interval;
    address vrfCoordinator;
    bytes32 gasLine;
    uint256 subscriptionId;
    uint32 callbackGasLimit;

    address public PLAYAR = makeAddr("player");
    uint256 public constant STARTING_PLAYER_BALANCE = 10 ether;

    /** Events (copy/past from Raffre Contract) */
    event RaffleEntered(address indexed player);
    event WinnerPicked(address indexed winner);

    function setUp() external {
        DeployRaffle deployRaffle = new DeployRaffle();
        (raffle, helperConfig) = deployRaffle.deployRaffle();
        deal(PLAYAR, STARTING_PLAYER_BALANCE);
        HelperConfig.NetworkConfig memory config = helperConfig.getConfig();
        entranceFee = config.entranceFee;
        interval = config.interval;
        vrfCoordinator = config.vrfCoordinator;
        gasLine = config.gasLine;
        subscriptionId = config.subscriptionId;
        callbackGasLimit = config.callbackGasLimit;
    }

    function testRaffleInitializesInOpenState() public view {
        assert(raffle.getRaffleState() == Raffle.RaffleState.OPEN);
    }

    function testRaffleRevertsWhenYouDontPayEnough() public {
        // Arrange
        vm.prank(PLAYAR);

        // Act / Assert
        vm.expectRevert(Raffle.Raffle__SendMoreToEnterRaffle.selector);
        raffle.enterRaffle();
    }

    function testRaffleRecordsPlayersWhenTheyEnter() public {
        // Arrange
        vm.prank(PLAYAR);

        // Act
        raffle.enterRaffle{value: entranceFee}();

        // Assert
        assert(raffle.getPlayer(0) == PLAYAR);
    }

    /**   forge test --mt testEnteringRaffleEmitsEvent -vvvv   */
    function testEnteringRaffleEmitsEvent() public {
        // Arrange
        vm.prank(PLAYAR);

        // Act
        vm.expectEmit(true, false, false, false, address(raffle));
        emit RaffleEntered(PLAYAR);

        // Assert
        raffle.enterRaffle{value: entranceFee}();
    }

    modifier raffleEntered() {
        vm.prank(PLAYAR);
        raffle.enterRaffle{value: entranceFee}();
        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1);
        _;
    }

    modifier skipFork() {
        if (block.chainid != LOCAL_CHAIN_ID) {
            return;
        }
        _;
    }

    /**   forge test --mt testDontAllowPlayersToEnterWhileRaffleIsCalculating -vvvv   */
    function testDontAllowPlayersToEnterWhileRaffleIsCalculating()
        public
        raffleEntered
    {
        // Arrange
        raffle.performUpkeep("");

        // Act / Assert
        vm.expectRevert(Raffle.Raffle__RaffleNotOpen.selector);
        vm.prank(PLAYAR);
        raffle.enterRaffle{value: entranceFee}();
    }

    /**   forge test --mt testCheckUpkeepReturnsFalseIfItHasNoBalance -vvvv   */
    function testCheckUpkeepReturnsFalseIfItHasNoBalance() public {
        // Arrange
        vm.warp(block.timestamp + raffle.getInterval() + 1);
        vm.roll(block.number + 1);

        // Act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        // Assert
        assert(!upkeepNeeded);
    }

    /**   forge test --mt testCheckUpkeepReturnsFalseIfRaffleIsntOpen -vvvv   */
    function testCheckUpkeepReturnsFalseIfRaffleIsntOpen()
        public
        raffleEntered
    {
        // Arrange
        raffle.performUpkeep("");

        // Act
        (bool upkeepNeeded, ) = raffle.checkUpkeep("");

        // Assert
        assert(!upkeepNeeded);
    }

    /**   forge test --mt testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue -vvvv   */
    function testPerformUpkeepCanOnlyRunIfCheckUpkeepIsTrue()
        public
        raffleEntered
    {
        // Arrange

        // Act / Assert
        raffle.performUpkeep("");
    }

    /**   forge test --mt testPerformUpkeepRevertsIfCheckUpkeepIsFalse -vvvv   */
    function testPerformUpkeepRevertsIfCheckUpkeepIsFalse() public {
        // Arrange
        uint256 currentBalance = 0;
        uint256 numPlayers = 0;
        Raffle.RaffleState raffleState = raffle.getRaffleState();

        // Act / Assert
        vm.expectRevert(
            abi.encodeWithSelector(
                Raffle.Raffle__RaffleUpkeepNotNeeded.selector,
                currentBalance,
                numPlayers,
                raffleState
            )
        );
        raffle.performUpkeep("");
    }

    /**   forge test --mt testPerformUpkeepUpdatesReffleStateAndEmitsRequestId -vvvv   */
    function testPerformUpkeepUpdatesReffleStateAndEmitsRequestId()
        public
        raffleEntered
    {
        // Arrange

        // Act
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];

        // Assert
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        assert(uint256(requestId) > 0);
        assert(uint256(raffleState) == 1);
    }

    /**   forge test --mt testFullfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep -vvvv   */
    /**   FUZZ Test   */
    function testFullfillRandomWordsCanOnlyBeCalledAfterPerformUpkeep(
        uint256 requestId
    ) public raffleEntered skipFork {
        // Arrange / Act / Assert
        vm.expectRevert(VRFCoordinatorV2_5Mock.InvalidRequest.selector);
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(
            requestId,
            address(raffle)
        );
    }

    /**   forge test --mt testFullfillRandomWordsPicksAWinnerResetAndSendsMoney -vvvv   */
    /**   forge test --mt testFullfillRandomWordsPicksAWinnerResetAndSendsMoney --fork-url $SEPOLIA_RPC_URL -vvvv   */
    function testFullfillRandomWordsPicksAWinnerResetAndSendsMoney()
        public
        raffleEntered
        skipFork
    {
        // Arrange
        uint256 additionalEntrance = 3; // 4 total
        uint256 startingIndex = 1;
        address expectedWinner = address(uint160(2));
        for (uint256 i = startingIndex; i < additionalEntrance; i++) {
            address newPlayer = address(uint160(i));
            hoax(newPlayer, 1 ether); // deal + vm.prank
            raffle.enterRaffle{value: entranceFee}();
        }
        uint256 startingTimeStamp = raffle.getLastTimeStamp();
        uint256 winnerStartingBalance = expectedWinner.balance;

        // Act
        vm.recordLogs();
        raffle.performUpkeep("");
        Vm.Log[] memory entries = vm.getRecordedLogs();
        bytes32 requestId = entries[1].topics[1];
        VRFCoordinatorV2_5Mock(vrfCoordinator).fulfillRandomWords(
            uint256(requestId),
            address(raffle)
        );

        // Assert
        address recentWinner = raffle.getRecentWinner();
        Raffle.RaffleState raffleState = raffle.getRaffleState();
        uint256 winnerBalance = recentWinner.balance;
        uint256 endingTimeStamp = raffle.getLastTimeStamp();
        uint256 prize = entranceFee * additionalEntrance;

        assert(recentWinner == expectedWinner);
        assert(uint256(raffleState) == 0);
        assert(winnerBalance == winnerStartingBalance + prize);
        assert(endingTimeStamp > startingTimeStamp);
    }
}
