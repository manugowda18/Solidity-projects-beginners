// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract PaymentSystem {
    // Contract owner
    address public owner;

    // User balances and PINs mapping
    mapping(address => uint256) public balances;
    mapping(address => bytes4) public userPINs;

    // Events for logging
    event Deposit(address indexed account, uint256 amount);
    event Withdrawal(address indexed account, uint256 amount);
    event Transfer(address indexed from, address indexed to, uint256 amount);

    // Modifier to restrict access to the contract owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the contract owner");
        _;
    }

    // Modifier to check if PIN provided matches the stored PIN for a user
    modifier pinMatches(uint256 _pin) {
        require(userPINs[msg.sender] == bytes4(keccak256(abi.encodePacked(_pin))), "Invalid PIN");
        _;
    }

    // Contract constructor, sets the contract owner to the deployer
    constructor() {
        owner = msg.sender;
    }

    // Function to set a PIN for the calling user
    function setPIN(uint256 _pin) external {
        userPINs[msg.sender] = bytes4(keccak256(abi.encodePacked(_pin)));
    }

    // Function to deposit funds into the contract
    function deposit() external payable {
        require(msg.value > 0, "Invalid deposit amount");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    // Function to withdraw funds from the contract
    function withdraw(uint256 _amount, uint256 _pin) external pinMatches(_pin) {
        require(_amount > 0 && _amount <= balances[msg.sender], "Invalid withdrawal amount");
        balances[msg.sender] -= _amount;
        payable(msg.sender).transfer(_amount);
        emit Withdrawal(msg.sender, _amount);
    }

    // Function to transfer funds from the caller to another address
    function transfer(address _to, uint256 _amount, uint256 _pin) external pinMatches(_pin) {
        require(_amount > 0 && _amount <= balances[msg.sender], "Invalid transfer amount");
        balances[msg.sender] -= _amount;
        balances[_to] += _amount;
        emit Transfer(msg.sender, _to, _amount);
    }

    // Function to get the balance of the calling user
    function getBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

}
