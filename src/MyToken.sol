// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract MyToken {
    string public tokenName;
    string public tokenSymbol;
    uint256 public totalSupply;
    mapping(address => uint256) public balances;

    constructor(string memory _tokenName, string memory _tokenSymbol) {
        tokenName = _tokenName;
        tokenSymbol = _tokenSymbol;
    }

    function mint(uint256 tokenAmount) public {
        balances[msg.sender] += tokenAmount;
        totalSupply += tokenAmount;
    }

    function transfer(uint256 tokenAmount, address payee) public {
        require(balances[msg.sender] >= tokenAmount, "Balance is not enough");
        balances[msg.sender] -= tokenAmount;
        balances[payee] += tokenAmount;
    }
}
