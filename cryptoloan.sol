// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;


contract CryptoLoan {
    mapping(address => uint) public balances;
    mapping(address => uint) public highestBalances;
    function store() public payable {
      uint fee = msg.value * 10 / 100;
      uint depositAmount = msg.value - fee;
      balances[msg.sender] += depositAmount;
      if (balances[msg.sender] > highestBalances[msg.sender]) {
        highestBalances[msg.sender] = depositAmount;   
      }

    }

    function getBalance() public view returns (uint) {
      return address(this).balance;
   }
    function getHighestBalance() public view returns (uint) {
        return highestBalances[msg.sender];
    }

   function withdraw(uint amount) public {
    require(balances[msg.sender] >= amount, "Insufficient balance");

    balances[msg.sender] -= amount;

    (bool sent, ) = payable(msg.sender).call{value: amount}("");
    require(sent, "Failed to send Ether");
   }
}