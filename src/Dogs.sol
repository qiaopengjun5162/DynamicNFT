// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import {VRFConsumerBaseV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/VRFConsumerBaseV2Plus.sol";
import {VRFV2PlusClient} from "@chainlink/contracts/src/v0.8/vrf/dev/libraries/VRFV2PlusClient.sol";
import {IVRFCoordinatorV2Plus} from "@chainlink/contracts/src/v0.8/vrf/dev/interfaces/IVRFCoordinatorV2Plus.sol";

contract Dogs is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, VRFConsumerBaseV2Plus {
    uint256 private _nextTokenId;

    uint256 public MAX_AMOUNT = 3;
    string uri = "";
    mapping(address => bool) public whiteList;
    bool public preMintWindow = false;
    bool public mintWindow = false;

    // METADATA of NFT
    string constant METADATA_SHIBAINU = "ipfs://QmXw7TEAJWKjKifvLE25Z9yjvowWk2NWY3WgnZPUto9XoA";
    string constant METADATA_HUSKY = "ipfs://QmTFXZBmmnSANGRGhRVoahTTVPJyGaWum8D3YicJQmG97m";
    string constant METADATA_BULLDOG = "ipfs://QmSM5h4WseQWATNhFWeCbqCTAGJCZc11Sa1P5gaXk38ybT";
    string constant METADATA_SHEPHERD = "ipfs://QmRGryH7a1SLyTccZdnatjFpKeaydJcpvQKeQTzQgEp9eK";

    mapping(uint256 => uint256[]) public s_requestIdToRandomWords;
    mapping(uint256 => address) public s_requestIdToAddress;
    uint256 public s_requestId;
    uint256 s_subscriptionId;
    address vrfCoordinatorV2Plus = 0x9DdfaCa8183c41ad55329BdeeD9F6A8d53168B1B;
    uint16 requestConfirmations = 3;
    uint32 callbackGasLimit = 100000;
    uint32 numWords = 1;
    bytes32 keyHash = 0x787d74caea10b2b357790d5b5247c2f63d1d91572a9846f780606e4d953677ae;
    mapping(uint256 => uint256) reqIdToTokenId;

    constructor(uint256 subscriptionId) ERC721("Dogs", "DGS") VRFConsumerBaseV2Plus(vrfCoordinatorV2Plus) {
        s_vrfCoordinator = IVRFCoordinatorV2Plus(vrfCoordinatorV2Plus);
        s_subscriptionId = subscriptionId;
    }

    function preMint() public payable {
        require(preMintWindow, "Premint is not open yet!");
        require(msg.value == 0.001 ether, "The price of dog nft is 0.001 ether");
        require(whiteList[msg.sender], "You are not in the white list");
        require(balanceOf(msg.sender) < 1, "Max amount of NFT minted by an addresss is 1");
        require(totalSupply() < MAX_AMOUNT, "Dog NFT is sold out!");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        request(tokenId);
    }

    function mint() public payable {
        require(mintWindow, "Mint is not open yet!");
        require(msg.value == 0.005 ether, "The price of dog nft is 0.005 ether");
        require(totalSupply() < MAX_AMOUNT, "Dog NFT is sold out!");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        request(tokenId);
    }

    function request(uint256 _tokenId) internal returns (uint256 requestId) {
        requestId = s_vrfCoordinator.requestRandomWords(
            VRFV2PlusClient.RandomWordsRequest({
                keyHash: keyHash,
                subId: s_subscriptionId,
                requestConfirmations: requestConfirmations,
                callbackGasLimit: callbackGasLimit,
                numWords: numWords,
                extraArgs: VRFV2PlusClient._argsToBytes(VRFV2PlusClient.ExtraArgsV1({nativePayment: true})) // new parameter
            })
        );
        s_requestIdToAddress[requestId] = msg.sender;
        // Store the latest requestId for this example.
        s_requestId = requestId;
        // Return the requestId to the requester.
        return requestId;
    }

    function fulfillRandomWords(uint256 requestId, uint256[] calldata randomWords) internal override {
        // transform the result to a number between 1 and 20 inclusively
        uint256 d20Value = (randomWords[0] % 20) + 1;
    }

    function addToWhiteList(address[] calldata addrs) public onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            whiteList[addrs[i]] = true;
        }
    }

    function setWindow(bool _preMintOpen, bool mintOpen) public onlyOwner {
        preMintWindow = _preMintOpen;
        mintWindow = mintOpen;
    }

    // The following functions are overrides required by Solidity.

    function _update(address to, uint256 tokenId, address auth)
        internal
        override(ERC721, ERC721Enumerable)
        returns (address)
    {
        return super._update(to, tokenId, auth);
    }

    function _increaseBalance(address account, uint128 value) internal override(ERC721, ERC721Enumerable) {
        super._increaseBalance(account, value);
    }

    function tokenURI(uint256 tokenId) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable, ERC721URIStorage)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
