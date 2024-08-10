// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {HelloWorld} from "./HelloWorld.sol";

contract HelloWorldFactory {
    HelloWorld[] public hws; // getter

    function createHW() public {
        HelloWorld hw = new HelloWorld();
        hws.push(hw);
    }

    function setHelloWorldPhraseByIndex(uint256 index, string memory newPhrase) public {
        hws[index].setHelloWorldPhrase(newPhrase);
    }

    function readHelloWorldPhraseByIndex(uint256 index) public view returns (string memory) {
        return hws[index].phrases(address(this));
    }
}
