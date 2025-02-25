// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

contract Bank {
    mapping(address => uint256) public balances;
    uint256 public totalDeposits = 0;
    address public owner;

    error NotEnoughFunds(uint256 requested, uint256 available);

    function deposit() public payable {
        balances[msg.sender] += msg.value;
        totalDeposits += msg.value;
    }

    /**
     * Withdraws a specified amount of Ether from the contract.
     * ⚠️ This function is vulnerable to reentrancy attacks because the balance update 
     * occurs after the Ether transfer.
     * An attacker could repeatedly call this function within the same transaction, 
     * withdrawing more funds than they actually have.
     */
    function withdraw(uint _amount) public {
        if (balances[msg.sender] < _amount) {
            revert NotEnoughFunds(_amount, balances[msg.sender]);
        }
        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "The transfer has failed.");

        //Condition to avoid underflow
        if (balances[msg.sender] >= _amount) {
            balances[msg.sender] -= _amount;
        }
    }

    /**
     * Secure version of the withdraw function, following the 
     * Checks-Effects-Interactions pattern to prevent reentrancy attacks.
     * ✅ The balance update occurs BEFORE sending Ether, making reentrancy impossible.
     */
    function safeWithdraw(uint _amount) public {
        if (balances[msg.sender] < _amount) {
            revert NotEnoughFunds(_amount, balances[msg.sender]);
        }

        require(balances[msg.sender] >= _amount);
        balances[msg.sender] -= _amount;

        (bool success, ) = msg.sender.call{value: _amount}("");
        require(success, "The transfer has failed.");
    }
}
