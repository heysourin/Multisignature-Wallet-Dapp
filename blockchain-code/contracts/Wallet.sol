// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract MultisignatureWallet {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed transactionId,
        address indexed transactionTo,
        uint value,
        bytes data// Gas save
    );
    event ConfirmationTransaction(address indexed owner, uint indexed transactionId );
    event RevokeTransaction(address indexed owner, uint indexed transactionId );
    event ExxecuteTransaction(address indexed owner, uint indexed transactionId );

    address[] owners;
    mapping (address => bool) public isOwner;//isOnwer[address] = true/false
    uint public numConfirmationRequired;

    struct Tansaction{
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations
    }
}
