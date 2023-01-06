//SPDX-License-Identifier: MIT

pragma solidity ^0.8.14;

contract Consumer{
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function deposit() public payable {}
}

contract SmartConractWallet{

    address payable public owner;
    mapping(address => uint) public allowance;
    mapping(address => bool) public isAllowed;

    mapping(address => bool) public guardians;
    address payable nextOwner;
    mapping(address => mapping(address => bool)) nextOwnerVotedBool;
    uint guardiansResetCount;
    uint public constant confirmations = 3;

    constructor(){
        owner = payable(msg.sender);
    }

    receive() external payable{}

    function setGuardian(address _guardian, bool _isGuardian) public{
        require(msg.sender == owner, "You are not the OWNER");
        guardians[_guardian] = _isGuardian;
    }

    function newOwner(address payable _newOwner) public{
        require(guardians[msg.sender], "You are not a GUARDIAN");
        require(nextOwnerVotedBool[_newOwner][msg.sender] == false, "You have VOTED");
        if (_newOwner != nextOwner){
            nextOwner = _newOwner;
            guardiansResetCount = 0;
        }
        guardiansResetCount++;

        if (guardiansResetCount >= confirmations){
            owner = nextOwner;
            nextOwner = payable(address(0));
        }
    }

    function setAllowance(address _for, uint _amount) public{
        require(msg.sender == owner, "You are not the OWNER");
        allowance[_for] = _amount;

        if (_amount > 0){
            isAllowed[_for] = true;
        } else{
            isAllowed[_for] = false;
        }
    }

    function transfer(address payable _to, uint _amount, bytes memory _payload) public returns(bytes memory){
        //require(msg.sender == owner, "You are not the OWNER");
        if (msg.sender != owner){
            require(isAllowed[msg.sender], "Not possible to send ANYTHING");
            require(allowance[msg.sender] >= _amount, "Not possible to send that AMOUNT");

            allowance[msg.sender] -= _amount;
        }

        (bool success, bytes memory returnData) = _to.call{value: _amount}(_payload);
        require(success, "Call wasn't successful");
        return returnData;
    }

    
}
