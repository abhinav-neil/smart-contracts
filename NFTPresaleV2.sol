// @notice NFT contract with presale/whitelist, separate mint funcs & state variables for presale & public sale
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

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
  uint public maxMintAmount = 5;
  uint public maxTokensOfOwner = 10;
  bool public isSaleActive;        
  
  // Presale
  uint public maxPresaleSupply = 1000;
  uint public maxPresaleMintAmount = 1;
  uint public presalePrice = 0.01 ether;
  bool public isPresaleActive;        
  mapping(address => bool) public isWhitelisted;
    
  Counters.Counter private _tokenId;

  constructor() ERC721("NFT", "NFT") {}
  
  function mintPresale(uint _mintAmount) public payable {
    require(isPresaleActive, "Presale is not active");
    require(isWhitelisted[msg.sender], "Only whitelisted users allowed during presale");
    require(_mintAmount > 0, "You must mint at least 1 NFT");
    require(_tokenId.current() + _mintAmount < maxPresaleSupply, "Presale supply exceeded");
    require(_mintAmount <= maxPresaleMintAmount, "Max presale mint limit exceeded");
    require(balanceOf(msg.sender) + _mintAmount <= maxTokensOfOwner, "Max NFTs per address exceeded");
    require(msg.value >= price * _mintAmount, "Please send the correct amount of ETH");
    for (uint i = 0; i < _mintAmount; i++) {
        _tokenId.increment();
        _safeMint(msg.sender, _tokenId.current());
    }

  }
    function mint(uint _mintAmount) public payable {
    require(isSaleActive, "Public sale is not active");
    require(_mintAmount > 0, "You must mint at least 1 NFT");
    require(_mintAmount <= maxMintAmount, "Max mint amount limit exceeded");
    require(_tokenId.current() + _mintAmount < maxSupply, "Not enough supply");
    require(balanceOf(msg.sender) + _mintAmount <= maxTokensOfOwner, "Max tokens per address limit exceeded");
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

  function setMaxMintAmount(uint _newMaxMintAmount) public onlyOwner() {
    maxMintAmount = _newMaxMintAmount;
  }

  function setmaxPresaleMintAmount(uint _newmaxPresaleMintAmount) public onlyOwner() {
    maxPresaleMintAmount = _newmaxPresaleMintAmount;
  }

  function setBaseURI(string memory _baseURI, string memory _baseExtension) public onlyOwner {
    baseURI = _baseURI;
    baseExtension = _baseExtension;
  }

  function flipSaleState() public onlyOwner {
    isSaleActive = !isSaleActive;
  }
  
  function flipPresaleState() public onlyOwner {
    isPresaleActive = !isSaleActive;
  }

  function whitelist(address[] memory _users) public onlyOwner {
      for(uint i = 0; i < _users.length; i++) {
          isWhitelisted[_users[i]] = true;
      }
  }
  
  function unWhitelist(address[] memory _users) public onlyOwner {
     for(uint i = 0; i < _users.length; i++) {
          isWhitelisted[_users[i]] = false;
     }
  }
 
  function withdraw() public onlyOwner {
    (bool success, ) = payable(owner()).call{value: address(this).balance}("");
    require(success);
  }
}