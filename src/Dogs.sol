// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Dogs is ERC721, ERC721Enumerable, ERC721URIStorage, ERC721Burnable, Ownable {
    uint256 private _nextTokenId;

    uint256 public MAX_AMOUNT = 3;
    string uri = "";
    mapping(address => bool) public whiteList;
    bool public preMintWindow = false;
    bool public mintWindow = false;

    constructor(address initialOwner) ERC721("Dogs", "DGS") Ownable(initialOwner) {}

    function preMint() public payable {
        require(preMintWindow, "Premint is not open yet!");
        require(msg.value == 0.001 ether, "The price of dog nft is 0.001 ether");
        require(whiteList[msg.sender], "You are not in the white list");
        require(balanceOf(msg.sender) < 1, "Max amount of NFT minted by an addresss is 1");
        require(totalSupply() < MAX_AMOUNT, "Dog NFT is sold out!");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
    }

    function mint() public payable {
          require(mintWindow, "Mint is not open yet!");
        require(msg.value == 0.005 ether, "The price of dog nft is 0.005 ether");
        require(totalSupply() < MAX_AMOUNT, "Dog NFT is sold out!");
        uint256 tokenId = _nextTokenId++;
        _safeMint(msg.sender, tokenId);
        _setTokenURI(tokenId, uri);
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
