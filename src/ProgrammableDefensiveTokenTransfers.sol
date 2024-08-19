// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

import {IRouterClient} from "@chainlink/contracts-ccip/src/v0.8/ccip/interfaces/IRouterClient.sol";
import {OwnerIsCreator} from "@chainlink/contracts-ccip/src/v0.8/shared/access/OwnerIsCreator.sol";
import {Client} from "@chainlink/contracts-ccip/src/v0.8/ccip/libraries/Client.sol";
import {CCIPReceiver} from "@chainlink/contracts-ccip/src/v0.8/ccip/applications/CCIPReceiver.sol";
import {IERC20} from
    "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/IERC20.sol";
import {SafeERC20} from
    "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/token/ERC20/utils/SafeERC20.sol";
import {EnumerableMap} from
    "@chainlink/contracts-ccip/src/v0.8/vendor/openzeppelin-solidity/v4.8.3/contracts/utils/structs/EnumerableMap.sol";

/**
 * 这是一个使用硬编码值来增加清晰度的示例合约。
 * 这是一个使用未经审计代码的示例合约。
 * 不要在生产环境中使用这段代码。
 */

/// @title - 一个简单的跨链传输/接收代币和数据的信使合约。
/// @dev - 这个示例展示了如何在撤销的情况下恢复代币
contract ProgrammableDefensiveTokenTransfers is CCIPReceiver, OwnerIsCreator {
    using EnumerableMap for EnumerableMap.Bytes32ToUintMap;
    using SafeERC20 for IERC20;

    // 自定义错误，提供更具描述性的撤销消息。
    error NotEnoughBalance(uint256 currentBalance, uint256 calculatedFees); // 用于确保合约有足够的余额来支付费用。
    error NothingToWithdraw(); // 当尝试提取以太币但没有可提取的以太币时使用。
    error FailedToWithdrawEth(address owner, address target, uint256 value); // 当提取以太币失败时使用。
    error DestinationChainNotAllowlisted(uint64 destinationChainSelector); // 当目标链没有被合约所有者列入允许名单时使用。
    error SourceChainNotAllowed(uint64 sourceChainSelector); // 当源链没有被列入允许名单时使用。
    error SenderNotAllowed(address sender); // 当发件人没有被合约所有者列入允许名单时使用。
    error InvalidReceiverAddress(); // 当接收地址为0时使用。
    error OnlySelf(); // 当函数在合约外部被调用时使用。
    error ErrorCase(); // 当模拟消息处理过程中的撤销时使用。
    error MessageNotFailed(bytes32 messageId);

    // 示例错误代码，可以有许多不同的错误代码。
    enum ErrorCode {
        // 首先是RESOLVED，以便默认值是已解决的。
        RESOLVED,
        // 此处可以有任意数量的错误代码。
        FAILED
    }

    struct FailedMessage {
        bytes32 messageId;
        ErrorCode errorCode;
    }

    // 当消息发送到另一个链时发出的事件。
    event MessageSent( // CCIP消息的唯一ID。
        // 目的链的链选择器。
        // 目的链上的接收地址。
        // 被发送的文本。
        // 被转移的代币地址。
        // 被转移的代币数量。
        // 用于支付CCIP费用的代币地址。
        // 为发送消息支付的费用。
        bytes32 indexed messageId,
        uint64 indexed destinationChainSelector,
        address receiver,
        string text,
        address token,
        uint256 tokenAmount,
        address feeToken,
        uint256 fees
    );

    // 当从另一个链收到消息时发出的事件。
    event MessageReceived( // CCIP消息的唯一ID。
        // 来源链的链选择器。
        // 来自源链的发件人地址。
        // 收到的文本。
        // 被转移的代币地址。
        // 被转移的代币数量。
        bytes32 indexed messageId,
        uint64 indexed sourceChainSelector,
        address sender,
        string text,
        address token,
        uint256 tokenAmount
    );

    event MessageFailed(bytes32 indexed messageId, bytes reason);
    event MessageRecovered(bytes32 indexed messageId);

    bytes32 private s_lastReceivedMessageId; // 存储最后接收的消息ID。
    address private s_lastReceivedTokenAddress; // 存储最后接收的代币地址。
    uint256 private s_lastReceivedTokenAmount; // 存储最后接收的数量。
    string private s_lastReceivedText; // 存储最后接收的文本。

    // 映射，用于跟踪允许的目标链。
    mapping(uint64 => bool) public allowlistedDestinationChains;

    // 映射，用于跟踪允许的源链。
    mapping(uint64 => bool) public allowlistedSourceChains;

    // 映射，用于跟踪允许的发件人。
    mapping(address => bool) public allowlistedSenders;

    IERC20 private s_linkToken;

    // 存储失败消息的内容。
    mapping(bytes32 messageId => Client.Any2EVMMessage contents) public s_messageContents;

    // 包含失败消息及其状态。
    EnumerableMap.Bytes32ToUintMap internal s_failedMessages;

    // 用于模拟消息处理函数中的撤销。
    bool internal s_simRevert = false;

    /// @notice 构造函数，用于使用路由器地址初始化合约。
    /// @param _router 路由器合约的地址。
    /// @param _link LINK合约的地址。
    constructor(address _router, address _link) CCIPReceiver(_router) {
        s_linkToken = IERC20(_link);
    }

    /// @dev 修饰符，用于检查给定目标链选择器的链是否被列入允许名单。
    /// @param _destinationChainSelector 目的链的选择器。
    modifier onlyAllowlistedDestinationChain(uint64 _destinationChainSelector) {
        if (!allowlistedDestinationChains[_destinationChainSelector]) {
            revert DestinationChainNotAllowlisted(_destinationChainSelector);
        }
        _;
    }

    /// @dev 修饰符，用于检查源链选择器的链和发件人是否被允许。
    /// @param _sourceChainSelector 目的链的选择器。
    /// @param _sender 发件人的地址。
    modifier onlyAllowlisted(uint64 _sourceChainSelector, address _sender) {
        if (!allowlistedSourceChains[_sourceChainSelector]) {
            revert SourceChainNotAllowed(_sourceChainSelector);
        }
        if (!allowlistedSenders[_sender]) revert SenderNotAllowed(_sender);
        _;
    }

    /// @dev 修饰符，检查接收地址不为0。
    /// @param _receiver 接收地址。
    modifier validateReceiver(address _receiver) {
        if (_receiver == address(0)) revert InvalidReceiverAddress();
        _;
    }

    /// @dev 修饰符，仅允许合同本身执行功能。
    /// 如果由任何帐户调用，则抛出异常，而不是合同本身。
    modifier onlySelf() {
        if (msg.sender != address(this)) revert OnlySelf();
        _;
    }

    /// @dev 更新目标链的交易允许状态。
    /// @notice 只能由所有者调用此功能。
    /// @param _destinationChainSelector 要更新的目的链选择器。
    /// @param allowed 设置目的链的允许状态。
    function allowlistDestinationChain(uint64 _destinationChainSelector, bool allowed) external onlyOwner {
        allowlistedDestinationChains[_destinationChainSelector] = allowed;
    }

    /// @dev 更新源链的允许状态
    /// @notice 只能由所有者调用此功能。
    /// @param _sourceChainSelector 要更新的源链选择器。
    /// @param allowed 设置源链的允许状态。
    function allowlistSourceChain(uint64 _sourceChainSelector, bool allowed) external onlyOwner {
        allowlistedSourceChains[_sourceChainSelector] = allowed;
    }

    /// @dev 更新发件人的交易允许状态。
    /// @notice 只能由所有者调用此功能。
    /// @param _sender 要更新的发件人地址。
    /// @param allowed 设置发件人的允许状态。
    function allowlistSender(address _sender, bool allowed) external onlyOwner {
        allowlistedSenders[_sender] = allowed;
    }

    /// @notice 向目标链上的接收者发送数据和转移代币。
    /// @notice 使用 LINK 支付费用。
    /// @dev 假设你的合约有足够的LINK来支付 CCIP 费用。
    /// @param _destinationChainSelector 目标区块链的标识符（即选择器）。
    /// @param _receiver 目标区块链上的接收者地址。
    /// @param _text 要发送的字符串数据。
    /// @param _token 代币地址。
    /// @param _amount 代币数量。
    /// @return messageId 发送的 CCIP 消息的 ID。
    function sendMessagePayLINK(
        uint64 _destinationChainSelector,
        address _receiver,
        string calldata _text,
        address _token,
        uint256 _amount
    )
        external
        onlyOwner
        onlyAllowlistedDestinationChain(_destinationChainSelector)
        validateReceiver(_receiver)
        returns (bytes32 messageId)
    {
        // 在内存中创建一个 EVM2AnyMessage 结构，其中包含发送跨链消息所需的信息
        // address(linkToken) 表示费用以 LINK 支付
        Client.EVM2AnyMessage memory evm2AnyMessage =
            _buildCCIPMessage(_receiver, _text, _token, _amount, address(s_linkToken));

        // 初始化一个路由器客户端实例，以与跨链路由器交互
        IRouterClient router = IRouterClient(this.getRouter());

        // 获取发送 CCIP 消息所需的费用
        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        if (fees > s_linkToken.balanceOf(address(this))) {
            revert NotEnoughBalance(s_linkToken.balanceOf(address(this)), fees);
        }

        // 批准路由器代表合约转移 LINK 代币。它将花费费用中的 LINK
        s_linkToken.approve(address(router), fees);

        // 批准路由器代表合约花费给定数量的代币。它将花费给定数量的代币
        IERC20(_token).approve(address(router), _amount);

        // 通过路由器发送消息，并存储返回的消息 ID
        messageId = router.ccipSend(_destinationChainSelector, evm2AnyMessage);

        // 发出一个事件，其中包含消息详细信息
        emit MessageSent(
            messageId, _destinationChainSelector, _receiver, _text, _token, _amount, address(s_linkToken), fees
        );

        // 返回消息 ID
        return messageId;
    }

    /// @notice 向目标链上的接收者发送数据和转移代币。
    /// @notice 使用原生gas支付费用。
    /// @dev 假设你的合约有足够的原生gas，如以太坊上的ETH或Polygon上的MATIC。
    /// @param _destinationChainSelector 目标区块链的标识符（即选择器）。
    /// @param _receiver 目标区块链上的接收者地址。
    /// @param _text 要发送的字符串数据。
    /// @param _token 代币地址。
    /// @param _amount 代币数量。
    /// @return messageId 发送的CCIP消息的ID。
    function sendMessagePayNative(
        uint64 _destinationChainSelector,
        address _receiver,
        string calldata _text,
        address _token,
        uint256 _amount
    )
        external
        onlyOwner
        onlyAllowlistedDestinationChain(_destinationChainSelector)
        validateReceiver(_receiver)
        returns (bytes32 messageId)
    {
        // 在内存中创建一个 EVM2AnyMessage 结构，其中包含发送跨链消息所需的信息
        // address(0) 表示费用以原生气体支付
        Client.EVM2AnyMessage memory evm2AnyMessage = _buildCCIPMessage(_receiver, _text, _token, _amount, address(0));

        // 初始化一个路由器客户端实例，以与跨链路由器交互
        IRouterClient router = IRouterClient(this.getRouter());

        // 获取发送 CCIP 消息所需的费用
        uint256 fees = router.getFee(_destinationChainSelector, evm2AnyMessage);

        if (fees > address(this).balance) {
            revert NotEnoughBalance(address(this).balance, fees);
        }

        // 批准路由器代表合约花费给定数量的代币。它将花费给定数量的代币
        IERC20(_token).approve(address(router), _amount);

        // 通过路由器发送消息，并存储返回的消息 ID
        messageId = router.ccipSend{value: fees}(_destinationChainSelector, evm2AnyMessage);

        // 发出一个事件，其中包含消息详细信息
        emit MessageSent(messageId, _destinationChainSelector, _receiver, _text, _token, _amount, address(0), fees);

        // 返回消息 ID
        return messageId;
    }

    /**
     * @notice 返回最后接收到的CCIP消息的详细信息。
     * @dev 此函数检索最后接收到的CCIP消息的ID、文本、代币地址和代币数量。
     * @return messageId 最后接收到的CCIP消息的ID。
     * @return text 最后接收到的CCIP消息的文本。
     * @return tokenAddress 最后接收到的CCIP消息中的代币地址。
     * @return tokenAmount 最后接收到的CCIP消息中的代币数量。
     */
    function getLastReceivedMessageDetails()
        public
        view
        returns (bytes32 messageId, string memory text, address tokenAddress, uint256 tokenAmount)
    {
        return (s_lastReceivedMessageId, s_lastReceivedText, s_lastReceivedTokenAddress, s_lastReceivedTokenAmount);
    }

    /**
     * @notice 检索失败消息的分页列表。
     * @dev 此功能返回由 `offset` 和 `limit` 参数定义的失败消息的子集。它确保分页参数在可用数据集的范围内。
     * @param offset 要返回的第一个失败消息的索引，通过从数据集的开头跳过指定数量的消息来实现分页。
     * @param limit 要返回的失败消息的最大数量，限制返回数组的大小。
     * @return failedMessages `FailedMessage` 结构的数组，每个结构包含一个 `messageId` 和一个 `errorCode`（解决或失败），表示请求的失败消息的子集。返回数组的长度由 `limit` 和失败消息的总数决定。
     */
    function getFailedMessages(uint256 offset, uint256 limit) external view returns (FailedMessage[] memory) {
        uint256 length = s_failedMessages.length();

        // 计算实际返回的项目数量（不能超过总长度或请求的限制）
        uint256 returnLength = (offset + limit > length) ? length - offset : limit;
        FailedMessage[] memory failedMessages = new FailedMessage[](returnLength);

        // 调整循环以尊重分页（从 offset 开始，结束于 offset + limit 或总长度）
        for (uint256 i = 0; i < returnLength; i++) {
            (bytes32 messageId, uint256 errorCode) = s_failedMessages.at(offset + i);
            failedMessages[i] = FailedMessage(messageId, ErrorCode(errorCode));
        }
        return failedMessages;
    }

    /// @notice CCIP 路由器调用的入口点。此功能不应撤销，所有错误应在合约内部处理。
    /// @param any2EvmMessage 要处理的消息。
    /// @dev 非常重要的是确保只有路由器调用此功能。
    function ccipReceive(Client.Any2EVMMessage calldata any2EvmMessage)
        external
        override
        onlyRouter
        onlyAllowlisted(any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address))) // 确保源链和发件人被列入允许名单
    {
        /* solhint-disable no-empty-blocks */
        try this.processMessage(any2EvmMessage) {
            // 本示例中故意为空；如果 processMessage 成功，则无需采取任何行动
        } catch (bytes memory err) {
            // 可以根据捕获的错误设置不同的错误代码。每个都可以有不同的处理方式。
            s_failedMessages.set(any2EvmMessage.messageId, uint256(ErrorCode.FAILED));
            s_messageContents[any2EvmMessage.messageId] = any2EvmMessage;
            // 不要撤销，以免 CCIP 撤销。改为发出事件。
            // 可以稍后重试该消息，而无需手动执行 CCIP。
            emit MessageFailed(any2EvmMessage.messageId, err);
            return;
        }
    }

    /// @notice 为此合约处理传入消息的入口点。
    /// @param any2EvmMessage 接收到的 CCIP 消息。
    /// @dev 将指定数量的代币转移到此合约的所有者。此功能必须是外部的，因为利用 Solidity 的 try/catch 错误处理机制。
    /// 它使用 `onlySelf`：只能由合约调用。
    function processMessage(Client.Any2EVMMessage calldata any2EvmMessage)
        external
        onlySelf
        onlyAllowlisted(any2EvmMessage.sourceChainSelector, abi.decode(any2EvmMessage.sender, (address))) // 确保源链和发件人被列入允许名单
    {
        // 为测试目的模拟撤销
        if (s_simRevert) revert ErrorCase();

        _ccipReceive(any2EvmMessage); // 处理消息 - 可能会撤销
    }

    /// @notice 允许所有者重试失败的消息，以解锁相关的代币。
    /// @param messageId 失败消息的唯一标识符。
    /// @param tokenReceiver 将代币发送到的地址。
    /// @dev 该功能只能由合约所有者调用。它更改消息的状态从 'failed(失败)' 到 'resolved(已解决)'，以防止重复条目和多次重试相同的消息
    function retryFailedMessage(bytes32 messageId, address tokenReceiver) external onlyOwner {
        // 检查消息是否失败；如果没有，则撤销交易。
        if (s_failedMessages.get(messageId) != uint256(ErrorCode.FAILED)) {
            revert MessageNotFailed(messageId);
        }

        // 将错误代码设置为 RESOLVED，以禁止重新进入和多次重试同一失败消息。
        s_failedMessages.set(messageId, uint256(ErrorCode.RESOLVED));

        // 检索失败消息的内容。
        Client.Any2EVMMessage memory message = s_messageContents[messageId];

        // 本示例期望一次发送一枚代币，但你可以处理多个代币。
        // 将关联的代币转移到指定的接收者作为紧急逃生方式。
        IERC20(message.destTokenAmounts[0].token).safeTransfer(tokenReceiver, message.destTokenAmounts[0].amount);

        // 发出事件，表明消息已被恢复。
        emit MessageRecovered(messageId);
    }

    /// @notice 允许所有者切换模拟撤销的测试。
    /// @param simRevert 如果为 `true`，模拟撤销条件；如果为 `false`，禁用模拟。
    /// @dev 该功能只能由合约所有者调用。
    function setSimRevert(bool simRevert) external onlyOwner {
        s_simRevert = simRevert;
    }

    function _ccipReceive(Client.Any2EVMMessage memory any2EvmMessage) internal override {
        s_lastReceivedMessageId = any2EvmMessage.messageId; // 获取消息ID
        s_lastReceivedText = abi.decode(any2EvmMessage.data, (string)); // 解码发送的文本
        // 预期一次转移一个代币，但可以转移多个代币。
        s_lastReceivedTokenAddress = any2EvmMessage.destTokenAmounts[0].token;
        s_lastReceivedTokenAmount = any2EvmMessage.destTokenAmounts[0].amount;
        emit MessageReceived(
            any2EvmMessage.messageId,
            any2EvmMessage.sourceChainSelector, // 获取源链标识符（即选择器）
            abi.decode(any2EvmMessage.sender, (address)), // 解码发送者地址，
            abi.decode(any2EvmMessage.data, (string)),
            any2EvmMessage.destTokenAmounts[0].token,
            any2EvmMessage.destTokenAmounts[0].amount
        );
    }

    /// @notice 构建CCIP消息。
    /// @dev 此函数将创建一个EVM2AnyMessage结构体，包含所有必要的信息以实现可编程的代币转移。
    /// @param _receiver 接收者的地址。
    /// @param _text 要发送的字符串数据。
    /// @param _token 要转移的代币。
    /// @param _amount 要转移的代币数量。
    /// @param _feeTokenAddress 用于费用的代币地址。将address(0)设置为使用原生gas。
    /// @return Client.EVM2AnyMessage 返回一个EVM2AnyMessage结构体，其中包含发送CCIP消息所需的信息。
    function _buildCCIPMessage(
        address _receiver,
        string calldata _text,
        address _token,
        uint256 _amount,
        address _feeTokenAddress
    ) private pure returns (Client.EVM2AnyMessage memory) {
        // 设置代币数量
        Client.EVMTokenAmount[] memory tokenAmounts = new Client.EVMTokenAmount[](1);
        Client.EVMTokenAmount memory tokenAmount = Client.EVMTokenAmount({token: _token, amount: _amount});
        tokenAmounts[0] = tokenAmount;
        // 在内存中创建一个 EVM2AnyMessage 结构，包含发送跨链消息所需的信息
        Client.EVM2AnyMessage memory evm2AnyMessage = Client.EVM2AnyMessage({
            receiver: abi.encode(_receiver), // ABI 编码的接收地址
            data: abi.encode(_text), // ABI 编码的字符串
            tokenAmounts: tokenAmounts, // 被转移的代币数量和类型
            extraArgs: Client._argsToBytes(
                // 额外参数，设置 gas 限制
                Client.EVMExtraArgsV1({gasLimit: 400_000})
            ),
            // 设置 feeToken 为 feeTokenAddress，表示将使用特定资产支付费用
            feeToken: _feeTokenAddress
        });
        return evm2AnyMessage;
    }

    /// @notice 该合约接收以太的默认函数。
    /// @dev 该函数没有函数体，使其成为接收以太的默认函数。
    /// 当向合约发送以太时而没有任何数据时，会自动调用此函数。
    receive() external payable {}

    /// @notice 允许合约所有者从合约中提取全部以太余额。
    /// @dev 如果没有资金可提取或转账失败，该函数将撤销。
    /// 只能由合约所有者调用。
    /// @param _beneficiary 将以太发送到的地址。
    function withdraw(address _beneficiary) public onlyOwner {
        // 检索此合约的余额
        uint256 amount = address(this).balance;

        // 如果没有可提取的内容，撤销
        if (amount == 0) revert NothingToWithdraw();

        // 尝试发送资金，捕获成功状态并丢弃任何返回数据
        (bool sent,) = _beneficiary.call{value: amount}("");

        // 如果发送失败，带有尝试转账信息的撤销
        if (!sent) revert FailedToWithdrawEth(msg.sender, _beneficiary, amount);
    }

    /// @notice 允许合约所有者提取特定ERC20代币的所有代币。
    /// @dev 如果没有代币可提取，则此函数将回滚并显示'NothingToWithdraw'错误。
    /// @param _beneficiary 应将代币发送到的地址。
    /// @param _token 要提取的ERC20代币的合约地址。
    function withdrawToken(address _beneficiary, address _token) public onlyOwner {
        // 检索此合约的代币余额
        uint256 amount = IERC20(_token).balanceOf(address(this));

        // 如果没有可提取的代币，撤销
        if (amount == 0) revert NothingToWithdraw();

        // 安全地将代币转移到指定受益人
        IERC20(_token).safeTransfer(_beneficiary, amount);
    }
}

// https://ccip.chain.link/msg/0x513969ff357db3ce31d79f3aee545a52b4122eed735dbce63f08f2966b659c81
// 0x92acd1c7C99C979fDc75c2F64cB439945392833f
// https://sepolia.etherscan.io/tx/0xa247476281da69df39969cdc7a6fcb4a32767cf96c3b1059bfe593f8246e5221
// https://sepolia.etherscan.io/tx/0xa17dcd8a3087031d1fa0339fee4a906bd8a686e8ef3492ccfab5dde8b8ef1768
// https://sepolia.etherscan.io/tx/0x006fc054715ef50d753305990ffe12f0563cebbe731da51ac1c931d08fb2aae1
// https://sepolia.etherscan.io/tx/0xb7a1e22909d96fe0ad591024f75725e3040b2379f059d5bca78bb0951b1a0809
// https://sepolia.etherscan.io/tx/0xec538255c1f54074cd84445574b537346c328488ebfcf3d52a31e72a0a095a5b
