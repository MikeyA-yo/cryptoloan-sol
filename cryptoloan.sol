// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.4.16 <0.9.0;


contract CryptoLoan {
    mapping(address => uint) public balances;

    function store() public payable {
      balances[msg.sender] += msg.value - (msg.value*10/100);
    }

    function getBalance() public view returns (uint) {
    return address(this).balance;
   }
}