// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {AutomationCompatibleInterface} from "@chainlink/contracts/src/v0.8/automation/AutomationCompatible.sol";

contract Bank is AutomationCompatibleInterface {
    address public owner;
    uint256 public threshold;
    mapping(address => uint256) public balances;

    event Deposited(address indexed user, uint256 amount);
    event Withdrawn(address indexed user, uint256 amount);

    constructor(uint256 _threshold) {
        owner = msg.sender;
        threshold = _threshold;
    }

    function deposit() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        balances[msg.sender] += msg.value;
        emit Deposited(msg.sender, msg.value);
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function setThreshold(uint256 _newThreshold) external {
        require(msg.sender == owner, "Only owner can set the threshold");
        threshold = _newThreshold;
    }

    // checkUpKeep()：在链下间隔执行调用该函数， 该方法返回一个布尔值，告诉网络是否需要自动化执行。
    function checkUpkeep(bytes calldata /* checkData */ )
        external
        view
        override
        returns (bool shouldTransferFunds, bytes memory /* performData */ )
    {
        shouldTransferFunds = (address(this).balance > threshold);
    }

    // performUpKeep()：这个方法接受从checkUpKeep()方法返回的信息作为参数。Chainlink Automation 会触发对它的调用。函数应该先进行一些检查，再执行链上其他计算。
    function performUpkeep(bytes calldata /* performData */ ) external override {
        if (address(this).balance > threshold) {
            uint256 halfBalance = address(this).balance / 2;
            // payable(owner).transfer(halfBalance);
            (bool success,) = payable(owner).call{value: halfBalance}("");
            require(success, "Transfer failed");
        }
    }

    function withdraw() external {
        require(msg.sender == owner, "Only owner can withdraw");
        payable(msg.sender).transfer(address(this).balance); // 转账给调用者
    }

    // Receive function to accept direct Ether transfers
    receive() external payable {
        deposit();
    }

    // Fallback function to handle any calls to non-existent functions
    fallback() external payable {
        deposit();
    }
}
