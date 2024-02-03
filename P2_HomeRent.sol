// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

contract HomeRent {
    address public owner;
    address public renter;

    uint public rentAmount;
    uint public securityDeposit;
    uint public leaseDuration; // in Months

    enum ContractStatus { Active, Terminated }
    ContractStatus public status;

    event RentPaid(address indexed payer, uint amount);
    event ContractTerminated(address indexed terminator);

    constructor() {
        owner = msg.sender;
        status = ContractStatus.Active;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can call this function");
        _;
    }

    modifier onlyRenter() {
        require(msg.sender == renter, "Only Renter can call this function");
        _;
    }

    function setRenter(address _renter) public onlyOwner {
        require(status == ContractStatus.Active, "Contract is not active");
        renter = _renter;
    }

    function rentalTerms(uint _rentAmount, uint _securityDeposit, uint _leaseDuration) public onlyOwner {
        require(status == ContractStatus.Active, "Contract is not active");
        rentAmount = _rentAmount;
        securityDeposit = _securityDeposit;
        leaseDuration = _leaseDuration;
    }

    function payRent() public payable onlyRenter {
        require(status == ContractStatus.Active, "Contract is not active");
        require(msg.value == rentAmount, "Invalid amount");

        emit RentPaid(msg.sender, msg.value);
        if (block.timestamp > leaseDuration * 30 days) {
            uint overdueMonths = (block.timestamp - leaseDuration * 30 days) / (30 days);
            uint overdueRent = overdueMonths * rentAmount;

            if (securityDeposit >= overdueRent) {
                securityDeposit -= overdueRent;
            } else {
                securityDeposit = 0;
                terminateContract();
            }
        }
    }

    function terminateContract() public {
        require(msg.sender == owner || msg.sender == renter, "Renter or Owner can terminate contract");
        if (status == ContractStatus.Active) {
            payable(renter).transfer(securityDeposit);
        }
        emit ContractTerminated(msg.sender);
        status = ContractStatus.Terminated;
    }

    function checkStatus() public view returns (ContractStatus) {
        return status;
    }

}
