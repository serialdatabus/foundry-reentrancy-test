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
}


