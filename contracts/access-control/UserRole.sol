pragma solidity ^0.5.0;

// Import the library 'Roles'
import "./Roles.sol";

// Define a contract 'UserRole' to manage this role - add, remove, check
contract UserRole {
    using Roles for Roles.Role;

    // Define 2 events, one for Adding, and other for Removing
    event UserAdded(address indexed account);
    event UserRemoved(address indexed account);

    // Define a struct 'users' by inheriting from 'Roles' library, struct Role
    Roles.Role private users;

    // In the constructor make the address that deploys this contract the 1st aluminium producer
    constructor() public {
        _addUser(msg.sender);
    }

    // Define a modifier that checks to see if msg.sender has the appropriate role
    modifier onlyUser() {
        require(isUser(msg.sender), "The address doesn´t match with any aluminum producer");
        _;
    }

    // Define a function 'isUser' to check this role
    function isUser(address account) public view returns (bool) {
        return users.has(account);
    }

    // Define a function 'addUser' that adds this role
    function addUser(address account) public onlyUser() {
        _addUser(account);
    }

    // Define a function 'removeUser' to remove this role
    function removeUser() public {
        _removeUser(msg.sender);
    }

    // Define an internal function '_addUser' to add this role, called by 'addUser'
    function _addUser(address account) internal {
        users.add(account);
        emit UserAdded(account);
    }

    // Define an internal function '_removeUser' to remove this role, called by 'removeUser'
    function _removeUser(address account) internal {
        users.remove(account);
        emit UserRemoved(account);
    }
}