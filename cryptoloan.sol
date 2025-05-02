// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.8.0;

contract CryptoLoan {
    struct Loan {
        uint amount;
        uint dueDate;
    }

    mapping(address => uint) public balances;
    mapping(address => uint) public highestBalances;
    mapping(address => Loan) public loans;

    // Deposit ETH into contract (10% fee)
    function store() public payable {
        uint fee = msg.value * 10 / 100;
        uint depositAmount = msg.value - fee;
        balances[msg.sender] += depositAmount;

        if (balances[msg.sender] > highestBalances[msg.sender]) {
            highestBalances[msg.sender] = balances[msg.sender];
        }
    }

    // Withdraw user funds
    function withdraw(uint amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");

        balances[msg.sender] -= amount;

        (bool sent, ) = payable(msg.sender).call{value: amount}("");
        require(sent, "Failed to send Ether");
    }

    // Take a loan with a specified duration in days
    function takeLoan(uint _amount, uint periodInDays) public {
        require(loans[msg.sender].amount == 0, "Repay existing loan first");

        uint loanLimit = highestBalances[msg.sender] + (highestBalances[msg.sender] * 50 / 100);
        require(_amount <= loanLimit, "Loan limit exceeded");
        require(_amount <= address(this).balance, "Insufficient contract liquidity");

        balances[msg.sender] += _amount;

        loans[msg.sender] = Loan({
            amount: _amount,
            dueDate: block.timestamp + (periodInDays * 1 days)
        });
    }

    // Repay active loan
    function repayLoan() public payable {
        Loan storage l = loans[msg.sender];
        require(l.amount > 0, "No active loan");
        require(msg.value >= l.amount, "Insufficient repayment");

        // Optionally return excess ETH
        if (msg.value > l.amount) {
            payable(msg.sender).transfer(msg.value - l.amount);
        }

        delete loans[msg.sender]; // Loan fully repaid
    }

    // Check if a user's loan is overdue
    function isLoanOverdue(address user) public view returns (bool) {
        Loan memory l = loans[user];
        return (l.amount > 0 && block.timestamp > l.dueDate);
    }

    // Get contract's ETH balance
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    // Get highest balance ever stored by user
    function getHighestBalance() public view returns (uint) {
        return highestBalances[msg.sender];
    }
}
