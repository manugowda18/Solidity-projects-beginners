//SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract PaymentApp{
    address public owner;

    mapping(address=>uint256) public balances;
    mapping(address=>bytes4) public userPin;

    event Deposit(address indexed account,uint256 amount);
    event Withdrawal(address indexed account,uint256 amount);
    event Transfer(address indexed from,address indexed to,uint256 amount);

    modifier onlyOwner(){
        require(msg.sender==owner,"Youre not a owner");
        _;
    }
    modifier pinMatches(uint256 _pin){
        require(userPin[msg.sender]==bytes4(keccak256(abi.encodePacked(_pin))),"Invalid Pin");
        _;
    }
    constructor(){
        owner=msg.sender;
    }

    function setPin(uint256 _pin) external {
        userPin[msg.sender] = bytes4(keccak256(abi.encodePacked(_pin)));
    }
    function deposit() external payable{
        require(msg.value>0,"Invalid Deposit");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender,msg.value);
    }
    function withdraw(uint256 _amount,uint256 _pin) external pinMatches(_pin){
        require(_amount>0 && _amount<=balances[msg.sender],"Invalid Withdrawal amount");
        balances[msg.sender]-=_amount;
        payable(msg.sender).transfer(_amount);
        emit Withdrawal(msg.sender,_amount);
    }
    function transfer(address _to, uint256 _amount, uint256 _pin) external pinMatches(_pin) {
        require(_amount > 0 && _amount <= balances[msg.sender], "Invalid transfer amount");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
    }

    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

}