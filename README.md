# 🔐 Foundry Reentrancy Attack Test

This repository contains a **Foundry based** test suite designed to **simulate and validate reentrancy vulnerabilities** in Solidity smart contracts.
The objective is to demonstrate how a reentrancy attack can be executed and how to prevent it.

## 📌 About the Test

This test simulates a **reentrancy attack** on a vulnerable smart contract, replicating real-world scenarios where funds can be drained before the victim's balance is updated.

### 🔍 What does this test do?
- Deploys a **vulnerable smart contract** susceptible to reentrancy.
- Creates an **attacker contract** that exploits the vulnerability.
- Uses **Foundry** to automate the execution and validation of the attack.
- Checks whether the vulnerable contract’s funds can be drained before the balance update.

## ⚙️ How to Run the Test

### 1️⃣ Install Foundry
If you haven't installed Foundry yet, run:

```bash
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### 2️⃣ Clone the Repository
```bash
git clone https://github.com/your-username/repository-name.git
cd repository-name
```

### 3️⃣ Install Dependencies
```bash
forge install
```

### 4️⃣ Run the Tests
To run all tests, use:

```bash
forge test -vv
```

To run only the **Reentrancy Attack Test**, use:

```bash
forge test --match-test testReentrancyAttack() -vv
```


## 🔗 Reference to the Blog
For a detailed explanation of the reentrancy attack and how this test was built, check out the full article on my blog:

📢 **[🔗 Read the full article](https://thecodepal.com/inside-a-reentrancy-attack-exploiting-testing-in-remix-foundry/)**  

---

## 🛡️ How to Prevent Reentrancy?

To mitigate this type of vulnerability, consider the following best practices:
- **Use the Checks-Effects-Interactions pattern** to update balances before making external calls.
- **Utilize OpenZeppelin’s `reentrancyGuard`** to prevent multiple consecutive calls.
- **Avoid using `.call{value: amount}("")` directly**, prefer `transfer()` or `send()` when possible.

---

## ⚠️ Disclaimer

This repository is **strictly for educational purposes** and was created to help developers understand and prevent reentrancy vulnerabilities. **Do not use this code for malicious purposes.**

---