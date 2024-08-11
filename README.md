# Hello Chainlink

欢迎使用 `Hello Chainlink` 仓库！本仓库展示了如何集成 Chainlink 工具来实现一些智能合约功能。你可以找到与 Chainlink 工具相关的示例合约代码，并学习如何将这些工具应用于你的项目中。

## 概述

`Hello Chainlink` 项目提供了一些示例合约，展示了如何集成 Chainlink 的各种工具，如 Chainlink Automation 和 Chainlink Oracles。这些合约包括自动化任务管理、数据预言机等功能，旨在帮助开发者更好地理解和使用 Chainlink 技术。

## 合约示例

### Bank 合约

**描述**：`Bank` 合约允许用户存款，并使用 Chainlink Automation 实现自动化任务。当存款超过指定阈值时，自动将一半的存款转移到指定的地址。
**关键功能**：

- 用户可以通过 `deposit()` 方法存款。
- 使用 Chainlink Automation 的 `checkUpkeep()` 和 `performUpkeep()` 方法自动管理存款。
- `receive()` 和 `fallback()` 方法处理直接转账和非存在函数调用。
