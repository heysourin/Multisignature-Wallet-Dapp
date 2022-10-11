// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.17;

contract MultisignatureWallet {
    event Deposit(address indexed sender, uint amount, uint balance);
    event SubmitTransaction(
        address indexed owner,
        uint indexed transactionId,
        address indexed transactionTo,
        uint value,
        bytes data // Gas save
    );
    event ConfirmTransaction(address indexed owner, uint indexed transactionId);
    event RevokeConfirmation(address indexed owner, uint indexed transactionId);
    event ExecuteTransaction(address indexed owner, uint indexed transactionId);

    address[] owners;
    mapping(address => bool) public isOwner; //isOnwer[address] = true/false
    uint public numConfirmationsRequired;

    struct Transaction {
        address to;
        uint value;
        bytes data;
        bool executed;
        uint numConfirmations;
    }

    mapping(uint => mapping(address => bool)) public isConfirmed; //? isConfirmed[Id][address] = true/false

    Transaction[] transactions; //? Creating array of the struct

    modifier onlyOwner() {
        require(isOwner[msg.sender], "only owner has the access"); //? Accessing from the 'isOwner' mapping
        _;
    }

    modifier txExists(uint _transactionId) {
        require(
            _transactionId < transactions.length,
            "Transaction does not exist"
        );
        _;
    }

    modifier notExecuted(uint _txIndex) {
        require(!transactions[_txIndex].executed, "tx already executed");
        _;
    }

    modifier notConfirmed(uint _txIndex) {
        require(!isConfirmed[_txIndex][msg.sender], "tx already confirmed");
        _;
    }

    constructor(address[] memory _owners, uint _numConfirmationsRequired) {
        require(_owners.length > 0, "owners required");
        require(
            _numConfirmationsRequired > 0 &&
                _numConfirmationsRequired <= _owners.length,
            "invalid number of required confirmations"
        );

        //Todo: Registering the owners inside this constructor.
        for (uint i = 0; i < _owners.length; i++) {
            address owner = _owners[i]; //? Setting owner.

            require(owner != address(0), "invalid owner"); //? Checking if input address is invalid.
            require(!isOwner[owner], "owner not unique"); //? Checking onwer is already registered or not.

            isOwner[owner] = true; //? Registration: Pushing 'owner' into 'isOwner' mapping.

            owners.push(owner); //? Pushing into the array 'owners'
        }

        //Todo: Setting the number of confirmations required. Setting this inside constructor.
        numConfirmationsRequired = _numConfirmationsRequired;
    }

    //Todo: Receiving the funds using receive.
    receive() external payable {
        emit Deposit(msg.sender, msg.value, address(this).balance);
    }

    //Todo: Owners can submit the transaction.
    function submitTransaction(
        address _to,
        uint _value,
        bytes memory _data
    ) public onlyOwner {
        uint txIndex = transactions.length; //? Length of the 'transaction' array

        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                data: _data,
                executed: false,
                numConfirmations: 0
            })
        );

        emit SubmitTransaction(msg.sender, txIndex, _to, _value, _data);
    }

    function confirmTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
        notConfirmed(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];
        transaction.numConfirmations += 1;
        isConfirmed[_txIndex][msg.sender] = true;

        emit ConfirmTransaction(msg.sender, _txIndex);
    }

    function executeTransaction(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(
            transaction.numConfirmations >= numConfirmationsRequired,
            "cannot execute tx"
        );

        transaction.executed = true;

        (bool success, ) = transaction.to.call{value: transaction.value}(
            transaction.data
        );
        require(success, "tx failed");

        emit ExecuteTransaction(msg.sender, _txIndex);
    }

    function revokeConfirmation(uint _txIndex)
        public
        onlyOwner
        txExists(_txIndex)
        notExecuted(_txIndex)
    {
        Transaction storage transaction = transactions[_txIndex];

        require(isConfirmed[_txIndex][msg.sender], "tx not confirmed");

        transaction.numConfirmations -= 1;
        isConfirmed[_txIndex][msg.sender] = false;

        emit RevokeConfirmation(msg.sender, _txIndex);
    }

    function getOwners() public view returns (address[] memory) {
        return owners;
    }

    function getTransactionCount() public view returns (uint) {
        return transactions.length;
    }

    function getTransaction(uint _txIndex)
        public
        view
        returns (
            address to,
            uint value,
            bytes memory data,
            bool executed,
            uint numConfirmations
        )
    {
        Transaction storage transaction = transactions[_txIndex];

        return (
            transaction.to,
            transaction.value,
            transaction.data,
            transaction.executed,
            transaction.numConfirmations
        );
    }
}
