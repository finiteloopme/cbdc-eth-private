// SPDX-License-Identifier: Apache-2.0

pragma solidity ^0.8.6;

// Defines ERC20 interface
import "./ierc20.sol";
// Define for a Bank type
import "./bank.sol";

contract vipCBDC is IERC20 {

    // Name for the token on the network
    string public constant name = "vipCBDC";
    // Symbol for the token
    string public constant symbol = "VIP";
    // Accuracy in terms of decimal places
    uint8 public constant decimals = 8;

    // Owner of the contract
    address public owner;

    // List of all the banks
    mapping(address => Bank) banks;

    mapping(address => mapping (address => uint256)) allowed;

    uint256 constant originalSupply = 1000 ether;
    uint256 totalSupply_ = 0 ether;

    constructor() {
        owner = msg.sender;
        banks[owner].isCentralBank = true;
        mint(originalSupply);
    }

    // helper function to check if the caller is a Central bank
    function isCentralBank() internal view returns (bool){
        return banks[msg.sender].isCentralBank;
    }

    // Let the world know that new CBDC has been created
    event NewCBDCMinted(address indexed by, string text, uint256 value);
    // Create money, by minting
    // Only owner or Central can mint
    function mint(uint256 numOfTokens) public returns(uint256){
        // Check that the requester is the Central Bank
        require(isCentralBank(), "Only the Central Bank can mint");
        // increase the total supply
        totalSupply_ += numOfTokens;
        // Allocate these tokens to the Central Bank
        banks[owner].balance += numOfTokens;
        // Send a notification that additional money has been minted
        emit NewCBDCMinted(owner, "New CBDC Created!", numOfTokens);

        return totalSupply_;
    }

    // Get the total CBDC in supply
    function totalSupply() public override view returns (uint256) {
        return totalSupply_;
    }

    // Get the cash on hand or liquidity for the bank
    function balanceOf(address tokenOwner) public override view returns (uint256) {
        return banks[tokenOwner].balance;
    }

    // Transfer the tokens to the receiver
    function transfer(address receiver, uint256 numTokens) public override returns (bool) {
        // Check the send has sufficient balance
        require(numTokens <= banks[msg.sender].balance);
        banks[msg.sender].balance = banks[msg.sender].balance-numTokens;
        banks[receiver].balance = banks[receiver].balance+numTokens;
        emit Transfer(msg.sender, receiver, numTokens);
        return true;
    }

    // Approve a loan
    function approve(address delegate, uint256 numTokens) public override returns (bool) {
        allowed[msg.sender][delegate] = numTokens;
        emit Approval(msg.sender, delegate, numTokens);
        return true;
    }

    // Get the outstanding approved credit that the receiver has with the specific provider
    function allowance(address creditProvider, address creditReceiver) public override view returns (uint) {
        return allowed[creditProvider][creditReceiver];
    }

    // Lending function
    // Before caller can invoke this method, the caller needs sufficient credit with the provider
    // Which can be established using "approve" function
    function transferFrom(address creditProvider, address supplier, uint256 numTokens) public override returns (bool) {
        require(numTokens <= banks[creditProvider].balance);
        require(numTokens <= allowed[creditProvider][msg.sender]);

        banks[creditProvider].balance -= numTokens;
        // msg.sender needs to have a valid approved credit with the provider
        allowed[creditProvider][msg.sender] = allowed[creditProvider][msg.sender]-numTokens;
        banks[creditProvider].loanedAmount[msg.sender] += numTokens;
        banks[msg.sender].borrowedAmount[creditProvider] += numTokens;
        // Note that the transfer happens directly 
        // from the credit provider to the supplier
        banks[supplier].balance = banks[supplier].balance+numTokens;
        emit Transfer(creditProvider, supplier, numTokens);
        return true;
    }

    // Make a loan installement
    // Pay back (part or ) loan amount
    // Does not adjust the line of credit or "allowance"
    // Returns outstanding loan
    function makeInstallment(address creditProvider, uint amount) public returns (uint256){
        require(amount <= banks[msg.sender].borrowedAmount[creditProvider], 
        "Amount bring paid can not be more than amount owed");

        banks[creditProvider].loanedAmount[msg.sender] -= amount;
        banks[msg.sender].borrowedAmount[creditProvider] -= amount;

        return banks[creditProvider].loanedAmount[msg.sender];
    }
}
