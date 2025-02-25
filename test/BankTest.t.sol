// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Bank} from "../src/Bank.sol";
import {Attacker} from "../src/Attacker.sol";

contract BankTest is Test {
    Bank public bank;
    Attacker attacker;
    uint256 private TOTAL_CLIENTS = 2;
    uint256 private constant DEPOSIT_AMOUNT = 1 ether;
    error NotEnoughFunds(uint256 requested, uint256 available);

    function setUp() public {
        // Instantiate a new Bank contract
        bank = new Bank();

        // Instantiate a new Attacker contract, setting Bank as the attack target
        attacker = new Attacker(payable(address(bank)));
    }

    /*
    This test initially ensures that a normal withdrawal works as expected  
    and that a second withdrawal attempt (exceeding the balance) is correctly reverted.  
    
    However, the Bank contract may contain a critical vulnerability,  
    allowing an attacker to withdraw more than their actual balance  
    by exploiting a reentrancy attack or improper balance updates.  
    
    In a later test (`testReentrancyAttack`), we will demonstrate how  
    an insecure withdrawal function can be exploited to drain funds  
    beyond what a single user has deposited.
    */
    function testUserCannotWithdrawMoreThanBalance() public {
        // Simulate multiple users depositing funds into the bank
        for (uint i = 1; i <= TOTAL_CLIENTS; i++) {
            address _user = vm.addr(i);
            vm.deal(_user, DEPOSIT_AMOUNT); // Give the user some ETH
            vm.prank(_user); // Temporarily set the user as msg.sender
            bank.deposit{value: DEPOSIT_AMOUNT}();
        }

        console.log(
            "bank total balance before 1 withdrawal: ",
            address(bank).balance,
            "ether"
        );

        // Simulate a user withdrawing their deposited amount
        address user = vm.addr(1);
        vm.prank(user);
        bank.withdraw(DEPOSIT_AMOUNT);

        // Ensure that attempting to withdraw more than the available balance is reverted
        vm.expectRevert(
            abi.encodeWithSelector(NotEnoughFunds.selector, DEPOSIT_AMOUNT, 0)
        );
        vm.prank(user);
        bank.withdraw(DEPOSIT_AMOUNT);

        console.log(
            "bank total balance after one withdrawal: ",
            address(bank).balance,
            "ether"
        );
    }

    /*
    This test simulates a reentrancy attack on the Bank contract.

    The Bank contract contains a vulnerable `withdraw()` function that performs an external call 
    using `.call{value: _amount}("")` before updating the user's balance. 
    This allows an attacker to recursively call `withdraw()` before their balance is reduced, 
    effectively draining the contract's funds.

    **Attack Flow:**
    1. The test first simulates multiple users depositing ETH into the Bank.
    2. The attacker is then given an initial balance and makes a legitimate deposit into the Bank.
    3. The attacker initiates the attack by calling `withdraw()`, which:
       - Triggers the attacker's `fallback()` function upon receiving ETH.
       - `fallback()` immediately calls `withdraw()` again, repeating the process.
       - This recursion continues until the Bank contract has no more ETH to withdraw.
    4. After the attack, we log the final balances to verify whether the attack successfully drained funds.

    **Expected Outcome:**
    - If the reentrancy vulnerability exists, the attacker should withdraw significantly more than their initial deposit.
    - The Bank’s total balance should be close to zero.
    - The logs should show multiple executions of `fallback()`, indicating recursive withdrawals.

    If the Bank contract were properly secured using the **Checks-Effects-Interactions** pattern or 
    a **reentrancy guard**, the attack would fail.
    */
    function testReentrancyAttack() public {
        TOTAL_CLIENTS = 5;
        
        // Simulate multiple users depositing funds into the bank
        for (uint i = 1; i <= TOTAL_CLIENTS; i++) {
            address _user = vm.addr(i);
            vm.deal(_user, DEPOSIT_AMOUNT); // Give the simulated users some ETH
            vm.prank(_user); // Temporarily set the user as msg.sender
            bank.deposit{value: DEPOSIT_AMOUNT}();
        }

        console.log(
            "bank total balance before attack: ",
            address(bank).balance / 1 ether
        );
        console.log(
            "attacker balance before attack: ",
            address(attacker).balance / 1 ether
        );

        // 🔥🔥🔥 **START OF THE REENTRANCY ATTACK** 🔥🔥🔥
        attacker.attack{value: DEPOSIT_AMOUNT}();
        // 🔥🔥🔥 **END OF THE ATTACK**              🔥🔥🔥

        // Display the final balances of the bank and attacker
        console.log(
            "bank total balance after attack: ",
            address(bank).balance / 1 ether
        );
        console.log(
            "attacker balance after attack",
            address(attacker).balance / 1 ether
        );
    }
}
