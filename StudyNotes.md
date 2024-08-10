# NFT 智能合约教程

- NFT (ERC721) 标准合约
  - ERC721 标准
  - Mint & Permit & 白名单
- NFT 随机铸造
  - VRF +  Mint 保证铸造公平性
- 动态更新NFT
  - Any API 动态更新 NFT 的 metadata
- 合约自动化
  - NFT 合约部分合约函数自动化执行

# [VRF](https://docs.chain.link/vrf/v2-5/best-practices#overview) 实操

```shell
forge install smartcontractkit/chainlink --no-commit
```

https://docs.chain.link/vrf/v2-5/supported-networks#sepolia-testnet

![image-20240810093729349](assets/image-20240810093729349.png)

https://vrf.chain.link/sepolia

![image-20240810093823694](assets/image-20240810093823694.png)

### Create subscription

![image-20240810093851321](assets/image-20240810093851321.png)



![image-20240810093948152](assets/image-20240810093948152.png)



![image-20240810094040952](assets/image-20240810094040952.png)



![image-20240810094204451](assets/image-20240810094204451.png)

Add funds

![image-20240810094234558](assets/image-20240810094234558.png)

### 10

![image-20240810094329132](assets/image-20240810094329132.png)



![image-20240810094508581](assets/image-20240810094508581.png)

### Add consumers

![image-20240810094644195](assets/image-20240810094644195.png)

Consumer address

### 部署

#### 部署脚本

```solidity
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

```

部署

```shell
DynamicNFT on  main [!+?] via 🅒 base 
➜ source .env     

DynamicNFT on  main [!+?] via 🅒 base 
➜ forge script --chain sepolia QiaoTokenScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv  

[⠊] Compiling...
[⠒] Compiling 2 files with Solc 0.8.20
[⠑] Solc 0.8.20 finished in 1.50s
Compiler run successful!
Traces:
  [1555073] QiaoTokenScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::envUint("SUBSCRIPTION_ID") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return] 
    ├─ [1508576] → new QiaoToken@0xC668D79A54694C4AA212dE50178A7c3b265b6373
    │   └─ ← [Return] 6638 bytes of code
    ├─ [0] console::log("QiaoToken deployed to:", QiaoToken: [0xC668D79A54694C4AA212dE50178A7c3b265b6373]) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    └─ ← [Stop] 


Script ran successfully.

== Logs ==
  QiaoToken deployed to: 0xC668D79A54694C4AA212dE50178A7c3b265b6373

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [1508576] → new QiaoToken@0xC668D79A54694C4AA212dE50178A7c3b265b6373
    └─ ← [Return] 6638 bytes of code


==========================

Chain 11155111

Estimated gas price: 4.309264446 gwei

Estimated total gas used for script: 2195060

Estimated amount required: 0.00945909401483676 ETH

==========================

##### sepolia
✅  [Success]Hash: 0x9e67b83b715dfac3d2a2a7f550e643656e580744b06a5a6fc6aa049093c909a0
Contract Address: 0xC668D79A54694C4AA212dE50178A7c3b265b6373
Block: 6470414
Paid: 0.004397538979531588 ETH (1689028 gas * 2.603591521 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.004397538979531588 ETH (1689028 gas * avg 2.603591521 gwei)
                                                                                                                    

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0xC668D79A54694C4AA212dE50178A7c3b265b6373` deployed on sepolia

Submitting verification for [src/QiaoToken.sol:QiaoToken] 0xC668D79A54694C4AA212dE50178A7c3b265b6373.
Submitted contract for verification:
        Response: `OK`
        GUID: `7waicaa49l6cgbaa91qp76itveixtvnfarsnegnztweig9u554`
        URL: https://sepolia.etherscan.io/address/0xc668d79a54694c4aa212de50178a7c3b265b6373
Contract verification status:
Response: `NOTOK`
Details: `Pending in queue`
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!

Transactions saved to: /Users/qiaopengjun/Code/solidity-code/DynamicNFT/broadcast/QiaoToken.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/solidity-code/DynamicNFT/cache/QiaoToken.s.sol/11155111/run-latest.json


DynamicNFT on  main [!+?] via 🅒 base took 1m 1.4s 
➜ 
```

https://sepolia.etherscan.io/address/0xc668d79a54694c4aa212de50178a7c3b265b6373#code

![image-20240810100049112](assets/image-20240810100049112.png)



![image-20240810100131888](assets/image-20240810100131888.png)



![image-20240810100330747](assets/image-20240810100330747.png)



https://sepolia.etherscan.io/tx/0xbfb07f08edb17ce6a79a49d162b9ea4217c8f2458c29bbd318c3f2bdefe5bd45

![image-20240810100252053](assets/image-20240810100252053.png)

https://vrf.chain.link/sepolia/20706299126585294390866835777988499780843478407105517934508556694810173553544

![image-20240810100607095](assets/image-20240810100607095.png)





https://sepolia.etherscan.io/address/0xc668d79a54694c4aa212de50178a7c3b265b6373#writeContract

![image-20240810101434667](assets/image-20240810101434667.png)

https://sepolia.etherscan.io/tx/0x6ced5cf21944ed315c5a06c4c34c4429452949977de72ef15e80eb93da844b1a

![image-20240810101647243](assets/image-20240810101647243.png)



![image-20240810101907411](assets/image-20240810101907411.png)

https://sepolia.etherscan.io/tx/0xebf4f77bb14e11c61d82a4c3cfc6d957415ee785574e6a9a9cb5c75b2d32ab88

![image-20240810102252538](assets/image-20240810102252538.png)

### import Token

![image-20240810102107509](assets/image-20240810102107509.png)

查看

![image-20240810102148330](assets/image-20240810102148330.png)

查看日志

https://sepolia.etherscan.io/tx/0xebf4f77bb14e11c61d82a4c3cfc6d957415ee785574e6a9a9cb5c75b2d32ab88#eventlog

![image-20240810103004218](assets/image-20240810103004218.png)

完成 vrf 的链上请求及回调响应

查看余额

![image-20240810103206696](assets/image-20240810103206696.png)

生产中需要及时查看余额，如果余额不足需要及时添加，否则会影响请求，结果会失败。

## 参考

- <https://medium.com/coinmonks/building-randomness-with-chainlink-vrf-1e3990e05193>
- <https://github.com/SupaMega24/fantasy-team-vrf/blob/main/src/RandomTeamSelector.sol>
- <https://vrf.chain.link/arbitrum-sepolia>
