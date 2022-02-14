// @notice NFT contract using ERC721 with Counters instead of ERC721Enumerable, to to optimize on gas for txns 
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721, Ownable {
  using Strings for uint;
  using Counters for Counters.Counter;

  string public baseURI;
  string public baseExtension;
  uint public price = 0.01 ether;
  uint public maxSupply = 10000;
  uint public maxTokensPerAddress = 10;
  bool public saleIsActive;
  Counters.Counter private _tokenId;

  constructor() ERC721("NFT", "NFT") {}

  function mint(uint _mintAmount) public payable {
    require(saleIsActive, "Sale is not active");
    require(_mintAmount > 0, "You must mint at least 1 NFT");
    require(_tokenId.current() + _mintAmount < maxSupply, "Not enough supply");
    require(balanceOf(msg.sender) + _mintAmount <= maxTokensPerAddress, "Max tokens per address limit exceeded");
    require(msg.value >= price * _mintAmount, "Please send the correct amount of ETH");
    for (uint i = 0; i < _mintAmount; i++) {
        _tokenId.increment();
        _safeMint(msg.sender, _tokenId.current());
    }
  }

function tokenURI(uint tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    return bytes(baseURI).length > 0
        ? string(abi.encodePacked(baseURI, tokenId.toString(), baseExtension)): "";
  }

  function setPrice(uint _newPrice) public onlyOwner() {
    price = _newPrice;
  }

  function setBaseURI(string memory _baseURI, string memory _baseExtension) public onlyOwner {
    baseURI = _baseURI;
    baseExtension = _baseExtension;
  }

  function flipSaleState() public onlyOwner {
    saleIsActive = !saleIsActive;
  }
 
  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success, "Withdrawal of funds failed");
  }
}