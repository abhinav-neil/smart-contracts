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

  function totalSupply() public view returns (uint) {
    return _tokenId.current();
  }

  function mint(uint _mintAmount) public payable {
    require(saleIsActive, "Sale is not active");
    require(_mintAmount > 0 && balanceOf(msg.sender) + _mintAmount <= maxTokensPerAddress, "Invalid mint amount");
    require(_tokenId.current() + _mintAmount < maxSupply, "Not enough supply");
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

  function walletOfOwner(address _owner) public view returns (uint[] memory) {
    uint ownerTokenCount = balanceOf(_owner);
    uint[] memory ownedTokenIds = new uint[](ownerTokenCount);
    uint currentTokenId = 1;
    uint ownedTokenIndex = 0;
    while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply) {
      address currentTokenOwner = ownerOf(currentTokenId);
      if (currentTokenOwner == _owner) {
        ownedTokenIds[ownedTokenIndex] = currentTokenId;
        ownedTokenIndex++;
      }
      currentTokenId++;
    }
    return ownedTokenIds;
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