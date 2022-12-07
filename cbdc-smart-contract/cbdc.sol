// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.6;

contract CBDC{

    // Public address of the central bank
    address public owner;

    // Collection of all the consumers
    mapping (address => Consumer) private consumers;
    
    // Consumer types
    enum ConsumerType {CentralBank, CommercialBank, Individual}

    // Bank definition
    struct Consumer{
        // ID for the consumer
        address id;
        // Only the owner of the contract
        // will be the central bank
        ConsumerType consumerType;
        // Cash on hand or liquidity
        uint256 cash;
        // Total amount loaned to customers
        uint256 loanedAmount;
        // Total borrowed
        uint256 borrowedAmount;
    }

    // Transfer, Lend, Borrow, Mint

    // Only executed when contract is created
    constructor(){
        // Set Creator of the contract as the owner
        owner = msg.sender;
        
        newConsumer(msg.sender, true);
    }

    // Returns a New Consumer
    function newConsumer(
        // Address of the consumer, wallet address
        address sender,
        bool isBank
    ) internal returns (Consumer memory) {
        Consumer storage consumer = consumers[sender];
        // Only owner of the contral will be the Central Bank
        if (owner == msg.sender){
            // Central bank
            consumer.consumerType = ConsumerType.CentralBank;
        } else if (isBank == true){
            // Commercial bank
            consumer.consumerType = ConsumerType.CommercialBank;
        } else {
            // This is an individual consumer
            consumer.consumerType = ConsumerType.Individual;
        }

        consumer.id = msg.sender;
        // set default values to 0
        consumer.loanedAmount = 0;
        consumer.deposit = 0;

        return (consumer);
    }

    // Regiser a new bank
    function registerAsBank() public {
        require(consumers[msg.sender].id!=address(0) , "This bank already exists");
        newConsumer(msg.sender, true);

        return ;
    }

    // Get the position of the calling bank
    // Performs a read-only operations
    // So the function has a modifier of "view"
    function getPosition() public view
        returns (
            uint totalLoans, 
            uint totalDeposits
        ){
            require(banks[msg.sender].id == address(0), "The bank doesn't exist");
            Bank memory bank = banks[msg.sender];

            return (bank.loanedAmount, bank.deposit);
    }

    
}