// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract HelloWorld {
    string public sayHello;
    address public owner;

    mapping(address => string) public phrases;
    mapping(address => bool) public whiteList;

    constructor() {
        owner = msg.sender;
        addWhitelist(owner);
    }

    function setHelloWorldPhrase(string memory newPhrase) public {
        // sayHello = newPhrase;
        require(whiteList[msg.sender], "You are not in the whiteList.");

        phrases[msg.sender] = newPhrase;

        // storage memory stack
    }

    function addWhitelist(address addrToAdd) public onlyOwner {
        // require(msg.sender == owner, "Only owner can call this function.");
        whiteList[addrToAdd] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function.");
        _;
    }
}
