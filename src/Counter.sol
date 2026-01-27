// https://docs.soliditylang.org/en/latest/style-guide.html
// Layout of Contract:
// version
// imports
// errors
// interfaces, libraries, contracts
// Type declarations
// State variables
// Events
// Modifiers
// Functions

// Layout of Functions:
// constructor
// receive function (if exists)
// fallback function (if exists)
// external
// public
// internal
// private
// view & pure functions

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

/**
 * @title A sample Raffle contract
 * @author Kazbek DZARASOV
 * @notice This contract is a creating a simple raffle
 * @dev Implements Chainlink VRFv2.5
 */
contract Raffle {
    /** Errors */
    error Raffle__SendMoreToEnterRaffle();

    /** Variables */
    uint256 private immutable i_entranceFee;

    /** Constructor */
    constructor(uint256 entranceFee) {
        i_entranceFee = entranceFee;
    }

    /** Contract's logic */
    function enterRaffle() public payable {
        // require(msg.value >= i_entranceFee, "Not enough ETH sent!");
        // require(msg.value >= i_entranceFee, Raffle__SendMoreToEnterRaffle());
        if (msg.value < i_entranceFee) {
            revert Raffle__SendMoreToEnterRaffle();
        }
    }

    function pickWinner() public {}

    /** Getter Functions */
    function get_entranceFee() external view returns (uint256) {
        return i_entranceFee;
    }
}
