// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import '@openzeppelin/contracts/utils/Counters.sol';

contract NFT is ERC721Enumerable, Ownable {
  using Strings for uint;
  using Counters for Counters.Counter;

  string public baseURI;
  uint public price = 0.01 ether;
  uint public maxSupply = 10000;
  uint public maxMintAmount = 3;
  uint public maxTokensOfOwner = 10;
  bool public saleIsActive;
  Counters.Counter private _tokenId;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    uint _initSupply
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    for (uint i = 1; i <= _initSupply; i++) {
      _safeMint(msg.sender, _tokenId.current() + i);
    }
  }

  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  function mint(uint _mintAmount) public payable {
    require(saleIsActive, 'Sale is not active');
    require(_mintAmount > 0, 'You must mint at least 1 NFT');
    require(_mintAmount <= maxMintAmount, 'Max mint amount limit exceeded');
    require(_tokenId.current() + _mintAmount < maxSupply, 'Not enough supply');
    require(balanceOf(msg.sender) + _mintAmount <= maxTokensOfOwner, 'Max tokens per address limit exceeded');
    if (msg.sender != owner()) {
        require(msg.value >= price * _mintAmount, 'Please send the correct amount of ETH');
    }
    for (uint i = 0; i < _mintAmount; i++) {
        _tokenId.increment();
        _safeMint(msg.sender, _tokenId.current());
    }
  }

  function walletOfOwner(address _owner)
    public
    view
    returns (uint[] memory)
  {
    uint ownerTokenCount = balanceOf(_owner);
    uint[] memory tokenIds = new uint[](ownerTokenCount);
    for (uint i; i < ownerTokenCount; i++) {
      tokenIds[i] = tokenOfOwnerByIndex(_owner, i);
    }
    return tokenIds;
  }

  function setPrice(uint _newPrice) public onlyOwner() {
    price = _newPrice;
  }

  function setmaxMintAmount(uint _newmaxMintAmount) public onlyOwner() {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function flipSaleState() public onlyOwner {
    saleIsActive = !saleIsActive;
  }
 
  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}('');
    require(success);
  }
}