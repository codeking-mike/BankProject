// SPDX-License-Identifier: MIT

pragma solidity ^0.8.30;

contract BankProject{
//functionalities
//1. create different accounts
//2. bank/owner can add money to the account
//3. bank/owner can withdraw money from the account
//4. account holder can check balance
//5. account holder can transfer money to another account

//struct to store account details
struct Account {
    string name;
    uint256 balance;
    address accountAddress;
    bool isActive;
}

//create a mapping to store accounts
mapping(address => Account) public userAccounts;
uint256 public totalAmountInBank;

constructor() {
    totalAmountInBank = address(this).balance;
}

//function to create an account
function createAccount(string memory _name) public {
    require(bytes(_name).length > 0, "Name cannot be empty");
    require(!userAccounts[msg.sender].isActive, "Account already exists");
    userAccounts[msg.sender] = Account({
        name: _name, 
        balance: 0, 
        accountAddress: msg.sender, 
        isActive: true
    });
}

//function to add money to the account
function addMoney(address _to) public payable {
    if(_to == address(0)){
        _to = msg.sender;
    }
    require(userAccounts[_to].isActive, "Account does not exist");
    userAccounts[_to].balance += msg.value;
    totalAmountInBank += msg.value;

}

//function to withdraw money from the account
function withdrawMoney(uint256 _amount) public {
    require(userAccounts[msg.sender].isActive, "Account does not exist");
    require(userAccounts[msg.sender].balance >= _amount, "Insufficient balance");
    require(address(this).balance >= _amount, "Bank has insufficient funds");
    userAccounts[msg.sender].balance -= _amount;
    totalAmountInBank -= _amount;
    (bool success, ) = payable(msg.sender).call{value: _amount}("");
    require(success, "Failed to transfer funds");

}

//function to transfer from user a to user b
function transferMoney(address _to, uint256 _amount) public {
    require(userAccounts[msg.sender].isActive, "Sender account does not exist");
    require(userAccounts[_to].isActive, "Recipient account does not exist");
    require(userAccounts[msg.sender].balance >= _amount, "Insufficient balance");
    userAccounts[msg.sender].balance -= _amount;
    userAccounts[_to].balance += _amount;

}

//function to close account
function closeAccount() public {
    require(userAccounts[msg.sender].isActive, "Account does not exist");
    uint256 balance = userAccounts[msg.sender].balance;
    if(balance > 0){
        withdrawMoney(balance);
    }
    userAccounts[msg.sender].balance = 0;
    userAccounts[msg.sender].isActive = false;
    totalAmountInBank -= balance;
    

}

}