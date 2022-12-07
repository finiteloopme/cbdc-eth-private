// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.6;

// Bank definition
struct Bank{
    // ID for the bank
    address id;
    // Only the owner of the contract
    // will be the central bank
    bool isCentralBank;
    // Cash on hand or liquidity
    uint256 balance;

    // TODO: allow creation of currency at level-2
    // Via commercial banks or lenders, who could borrow
    // from Central bank or other lenders
    // // List of customers who have a loan with this bank
    // mapping(address => uint256) loanedAmount;
    // // List of borrowers who this bank has borrowed from
    // mapping(address => uint256) borrowedAmount;
}
