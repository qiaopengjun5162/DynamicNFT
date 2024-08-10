// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {QiaoToken} from "../src/QiaoToken.sol";

contract QiaoTokenScript is Script {
    QiaoToken public qiaotoken;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        uint256 subscriptionId = vm.envUint("SUBSCRIPTION_ID");
        vm.startBroadcast(deployerPrivateKey);

        qiaotoken = new QiaoToken(subscriptionId);
        console.log("QiaoToken deployed to:", address(qiaotoken));

        vm.stopBroadcast();
    }
}
