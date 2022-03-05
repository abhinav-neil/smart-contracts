//SPDX-License-Identifier: MIT

pragma solidity ^0.8.12;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTa is ERC721A, Ownable {
  using Strings for uint;

  string public baseURI;
  string public baseExtension;
  uint public price = 0.01 ether;
  uint public maxSupply = 10000;
  uint public maxTokensPerAddress = 10;
  bool public saleIsActive;

  constructor() ERC721A("NFTa", "NFTa") {}

  function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
  }

  function mint(uint _mintAmount) public payable {
    require(saleIsActive, "Sale is not active");
    require(_mintAmount > 0, "You must mint at least 1 NFT");
    require(totalSupply() + _mintAmount <= maxSupply, "Not enough supply");
    require(balanceOf(msg.sender) + _mintAmount <= maxTokensPerAddress, "Max tokens per address limit exceeded");
    require(msg.value >= price * _mintAmount, "Please send the correct amount of ETH");
    _safeMint(msg.sender, _mintAmount);
  }

  function tokenURI(uint tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    return bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString(), baseExtension)): "";
  }

  function setBaseURI(string memory _baseURI, string memory _baseExtension) public onlyOwner {
    baseURI = _baseURI;
    baseExtension = _baseExtension;
  }

  function flipSaleState() public onlyOwner {
    saleIsActive = !saleIsActive;
  }
 
  function setPrice(uint _newPrice) public onlyOwner() {
    price = _newPrice;
  }

  function setMaxTokensPerAddress(uint _newMaxTokensPerAddress) public onlyOwner() {
      maxTokensPerAddress = _newMaxTokensPerAddress;
  }

  function withdraw() public onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success, "Withdrawal of funds failed");
  }
}