//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract Wallet{
    
    struct Transaction{
        uint amount;
        uint timestamp;
    }

    struct balance{
        uint totalBalance;
        uint numDeposits;
        mapping(uint => Transaction) deposits;
        uint numWithdrawals;
        mapping(uint => Transaction) withdrawals;
    }
    mapping(address => balance) Balances;

    function depositMoney() public payable{
        Balances[msg.sender].totalBalance+= msg.value;

        Transaction memory deposit = Transaction(msg.value, block.timestamp);
        Balances[msg.sender].deposits[Balances[msg.sender].numDeposits] = deposit;
        Balances[msg.sender].numDeposits++;
    }

    function getDepositNum(address _from, uint _num) public view returns(Transaction memory){
        return Balances[_from].deposits[_num];
    }

    function getWithdrawNum(address _from, uint _num) public view returns(Transaction memory){
        return Balances[_from].withdrawals[_num];
    }

    function withdrawMoney(address payable _to, uint _amount) public payable{
        require(_amount <= Balances[msg.sender].totalBalance, "Not Enough Funds");
        Balances[msg.sender].totalBalance -= _amount;
        
        Transaction memory withdraw = Transaction(msg.value, block.timestamp);
        Balances[msg.sender].withdrawals[Balances[msg.sender].numWithdrawals] = withdraw;
        Balances[msg.sender].numWithdrawals++;
        _to.transfer(_amount);
    }

}
