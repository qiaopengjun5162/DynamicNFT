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

<https://docs.chain.link/vrf/v2-5/supported-networks#sepolia-testnet>

![image-20240810093729349](assets/image-20240810093729349.png)

<https://vrf.chain.link/sepolia>

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

<https://sepolia.etherscan.io/address/0xc668d79a54694c4aa212de50178a7c3b265b6373#code>

![image-20240810100049112](assets/image-20240810100049112.png)

![image-20240810100131888](assets/image-20240810100131888.png)

![image-20240810100330747](assets/image-20240810100330747.png)

<https://sepolia.etherscan.io/tx/0xbfb07f08edb17ce6a79a49d162b9ea4217c8f2458c29bbd318c3f2bdefe5bd45>

![image-20240810100252053](assets/image-20240810100252053.png)

<https://vrf.chain.link/sepolia/20706299126585294390866835777988499780843478407105517934508556694810173553544>

![image-20240810100607095](assets/image-20240810100607095.png)

<https://sepolia.etherscan.io/address/0xc668d79a54694c4aa212de50178a7c3b265b6373#writeContract>

![image-20240810101434667](assets/image-20240810101434667.png)

<https://sepolia.etherscan.io/tx/0x6ced5cf21944ed315c5a06c4c34c4429452949977de72ef15e80eb93da844b1a>

![image-20240810101647243](assets/image-20240810101647243.png)

![image-20240810101907411](assets/image-20240810101907411.png)

<https://sepolia.etherscan.io/tx/0xebf4f77bb14e11c61d82a4c3cfc6d957415ee785574e6a9a9cb5c75b2d32ab88>

![image-20240810102252538](assets/image-20240810102252538.png)

### import Token

![image-20240810102107509](assets/image-20240810102107509.png)

查看

![image-20240810102148330](assets/image-20240810102148330.png)

查看日志

<https://sepolia.etherscan.io/tx/0xebf4f77bb14e11c61d82a4c3cfc6d957415ee785574e6a9a9cb5c75b2d32ab88#eventlog>

![image-20240810103004218](assets/image-20240810103004218.png)

完成 vrf 的链上请求及回调响应

查看余额

![image-20240810103206696](assets/image-20240810103206696.png)

生产中需要及时查看余额，如果余额不足需要及时添加，否则会影响请求，结果会失败。



## 利用 Chainlink Automation 自动化 Bank 合约：使用 Solidity 实现动态存款管理和自动转账

实现一个 Bank 合约， 用户可以通过 `deposit()` 存款， 然后使用 ChainLink Automation  实现一个自动化任务， 自动化任务实现：当 Bank 合约的存款超过 x (可自定义数量)时， 转移一半的存款到指定的地址（如 Owner）。

### `Bank` 代码

```solidity
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
    function checkUpkeep(
        bytes calldata /* checkData */
    )
        external
        view
        override
        returns (bool shouldTransferFunds, bytes memory /* performData */)
    {
        shouldTransferFunds = (address(this).balance > threshold);
    }

    // performUpKeep()：这个方法接受从checkUpKeep()方法返回的信息作为参数。Chainlink Automation 会触发对它的调用。函数应该先进行一些检查，再执行链上其他计算。
    function performUpkeep(bytes calldata /* performData */) external override {
        if (address(this).balance > threshold) {
            uint256 halfBalance = address(this).balance / 2;
            // payable(owner).transfer(halfBalance);
            (bool success, ) = payable(owner).call{value: halfBalance}("");
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

```

使用 需要实现两个方法

- checkUpKeep()：在链下间隔执行调用该函数， 该方法返回一个布尔值，告诉网络是否需要自动化执行。

- performUpKeep()：这个方法接受从checkUpKeep()方法返回的信息作为参数。Chainlink Automation 会触发对它的调用。函数应该先进行一些检查，再执行链上其他计算。

更多请参考：https://docs.chain.link/chainlink-automation/guides/compatible-contracts

在上面代码中，

 We don't use the checkData in this example. The checkData is defined when the Upkeep was registered.

We don't use the performData in this example. The performData is generated by the Automation Node's call to your checkUpkeep function

## Chainlink Automation 实操

### 第一步：部署合约

#### 部署脚本

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import {Bank} from "../src/Bank.sol";

contract BankScript is Script {
    Bank public bank;
    uint256 threshold = 0.008 ether;

    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        bank = new Bank(threshold);
        console.log("Bank deployed to:", address(bank));

        vm.stopBroadcast();
    }
}

```

#### 部署实操

```shell
hello-chainlink on  main [!?] via 🅒 base 
➜ source .env

hello-chainlink on  main [!?] via 🅒 base 
➜ forge script --chain sepolia BankScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv  

[⠊] Compiling...
No files changed, compilation skipped
Traces:
  [381711] BankScript::run()
    ├─ [0] VM::envUint("PRIVATE_KEY") [staticcall]
    │   └─ ← [Return] <env var value>
    ├─ [0] VM::startBroadcast(<pk>)
    │   └─ ← [Return] 
    ├─ [334903] → new Bank@0x647f8FF9aa0AFC1d560a0C1366734B1f188Aa896
    │   └─ ← [Return] 1451 bytes of code
    ├─ [0] console::log("Bank deployed to:", Bank: [0x647f8FF9aa0AFC1d560a0C1366734B1f188Aa896]) [staticcall]
    │   └─ ← [Stop] 
    ├─ [0] VM::stopBroadcast()
    │   └─ ← [Return] 
    └─ ← [Stop] 


Script ran successfully.

== Logs ==
  Bank deployed to: 0x647f8FF9aa0AFC1d560a0C1366734B1f188Aa896

## Setting up 1 EVM.
==========================
Simulated On-chain Traces:

  [334903] → new Bank@0x647f8FF9aa0AFC1d560a0C1366734B1f188Aa896
    └─ ← [Return] 1451 bytes of code


==========================

Chain 11155111

Estimated gas price: 9.442339362 gwei

Estimated total gas used for script: 535661

Estimated amount required: 0.005057892944988282 ETH

==========================

##### sepolia
✅  [Success]Hash: 0x8e76814070931a6835a077724977a64537ddbae22dec2d916ec8f793b4a48340
Contract Address: 0x647f8FF9aa0AFC1d560a0C1366734B1f188Aa896
Block: 6473990
Paid: 0.002084410794718675 ETH (412147 gas * 5.057445025 gwei)

✅ Sequence #1 on sepolia | Total Paid: 0.002084410794718675 ETH (412147 gas * avg 5.057445025 gwei)
                                                                                                                    

==========================

ONCHAIN EXECUTION COMPLETE & SUCCESSFUL.
##
Start verification for (1) contracts
Start verifying contract `0x647f8FF9aa0AFC1d560a0C1366734B1f188Aa896` deployed on sepolia

Submitting verification for [src/Bank.sol:Bank] 0x647f8FF9aa0AFC1d560a0C1366734B1f188Aa896.

Submitting verification for [src/Bank.sol:Bank] 0x647f8FF9aa0AFC1d560a0C1366734B1f188Aa896.

Submitting verification for [src/Bank.sol:Bank] 0x647f8FF9aa0AFC1d560a0C1366734B1f188Aa896.

Submitting verification for [src/Bank.sol:Bank] 0x647f8FF9aa0AFC1d560a0C1366734B1f188Aa896.

Submitting verification for [src/Bank.sol:Bank] 0x647f8FF9aa0AFC1d560a0C1366734B1f188Aa896.
Submitted contract for verification:
        Response: `OK`
        GUID: `lasmeniskktpdateydsrciwzzyymya3aa4teq6fbri8yudei8t`
        URL: https://sepolia.etherscan.io/address/0x647f8ff9aa0afc1d560a0c1366734b1f188aa896
Contract verification status:
Response: `OK`
Details: `Pass - Verified`
Contract successfully verified
All (1) contracts were verified!

Transactions saved to: /Users/qiaopengjun/Code/solidity-code/hello-chainlink/broadcast/Bank.s.sol/11155111/run-latest.json

Sensitive values saved to: /Users/qiaopengjun/Code/solidity-code/hello-chainlink/cache/Bank.s.sol/11155111/run-latest.json


hello-chainlink on  main [!?] via 🅒 base took 49.6s 
➜ 
```

#### 部署成功

https://sepolia.etherscan.io/address/0x647f8ff9aa0afc1d560a0c1366734b1f188aa896#code

![image-20240811102919953](assets/image-20240811102919953.png)



### 第二步：打开 Chainlink Automation 主页，点击注册 [Register new Upkeep 按钮](https://automation.chain.link/sepolia/new)

https://automation.chain.link/sepolia

![image-20240810233057744](assets/image-20240810233057744.png)

### 第三步：选择 Custom logic

![image-20240810233304471](assets/image-20240810233304471.png)

### 第四步：点击 Next后添加合约地址 Target contract address

![image-20240810233358057](assets/image-20240810233358057.png)

### 第五步：添加合约地址 Target contract address后点击 Next

![image-20240810233504704](assets/image-20240810233504704.png)

### 第六步：填写相关信息：UpKeep name、Starting balance(LINK)、Gas limit、Project name(可选) ...

![image-20240810233716638](assets/image-20240810233716638.png)

### 第七步：点击 `Register Upkeep`

![image-20240810233920250](assets/image-20240810233920250.png)

### 第八步：转账 10 Link 作为初始余额进行确认

![image-20240810233902927](assets/image-20240810233902927.png)

### 第九步：Confirm 后 Receive confirmation

![image-20240810234010791](assets/image-20240810234010791.png)

### 第十步：Sign message

![image-20240810234105255](assets/image-20240810234105255.png)



### 第十一步：点击 sign

![image-20240810234047774](assets/image-20240810234047774.png)

### 第十二步：成功注册 Upkeep registration request submitted successfully

![image-20240810234207198](assets/image-20240810234207198.png)

### 第十三步：View Upkeep

https://automation.chain.link/sepolia/6794270141962714421784358681294410476764730312771526144237727479012587802307

![image-20240810234315650](assets/image-20240810234315650.png)



### 第十四步：查看并调用合约进行测试

![image-20240810234506446](assets/image-20240810234506446.png)

#### 测试步骤

- **当 Bank 合约的存款超过 0.008 ETH时， 转移一半的存款到指定的地址 Owner**

- **第一步：deposit 0.008 ETH**
- **第二步：deposit 0.002 ETH**
- **第三步：查询余额，超过临界点 一半转入 owner 故查询余额为 0.005**
- **第四步：查询 Chainlink Automation 进行确认 **

### 第十五步：deposit 0.008 ETH

![image-20240810234901403](assets/image-20240810234901403.png)

### 第十六步：Confirm 0.008 Tx

![image-20240810234826193](assets/image-20240810234826193.png)

### 第十七步：查看 Transaction Details

https://sepolia.etherscan.io/tx/0x7140fd39f6ff0199a0b8e9d123bcd18d93ace527de9fe44d36358fd17362d4bb

![image-20240810234939526](assets/image-20240810234939526.png)

### 第十八步：查询余额 0.008 ETH 已存入

![image-20240810235327649](assets/image-20240810235327649.png)

### 第十九步：deposit 0.002 ETH

![image-20240810235629368](assets/image-20240810235629368.png)

### 第二十步：Confirm deposit 0.002 ETH

![image-20240810235542201](assets/image-20240810235542201.png)

### 第二十一步：查看 deposit 0.002 ETH Transaction Details

https://sepolia.etherscan.io/tx/0xbffc1f8eff9f93fb77d350d06813553a354eed0c82b89ec8e945b90386184f80

![image-20240810235722932](assets/image-20240810235722932.png)



![image-20240811000014697](assets/image-20240811000014697.png)



### 第二十二步：查询余额 0.005 ETH

- 第一步存入 0.008

- 第二步存入 0.002

- 超过临界点 一半转入 owner

- 故查询余额为 0.005

![image-20240811000214276](assets/image-20240811000214276.png)

### 第二十三步：在 Chainlink Automation 中查看 History

https://automation.chain.link/sepolia/6794270141962714421784358681294410476764730312771526144237727479012587802307

![image-20240811000331573](assets/image-20240811000331573.png)

### 第二十四步：查看交易详情确认自动化任务按预期完成

https://sepolia.etherscan.io/tx/0x93fd1050b19966c2fad97ea9c5389e2596501b9931c1cfb372fdf885cb91b6c2

![image-20240811000454617](assets/image-20240811000454617.png)

##### 可以看到合约给owner转了一半的存款余额0.005 ETH，成功实现预期目标，完美！

##### 自动化任务实现：当 Bank 合约的存款超过 0.008 ETH时， 转移一半的存款到Owner。



## 参考

- <https://medium.com/coinmonks/building-randomness-with-chainlink-vrf-1e3990e05193>
- <https://github.com/SupaMega24/fantasy-team-vrf/blob/main/src/RandomTeamSelector.sol>
- <https://vrf.chain.link/arbitrum-sepolia>
- https://github.com/smartcontractkit/chainlink





![image-20240811142803020](assets/image-20240811142803020.png)



![image-20240811143519952](assets/image-20240811143519952.png)





![image-20240811144307531](assets/image-20240811144307531.png)
