// @notice NFT contract with presale/whitelist, common mint func & sale config object for presale/public sale, values not hard coded but set via setters
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721, Ownable {
  using Strings for uint;
  using Counters for Counters.Counter;

  enum saleState {Closed, presale, public}

  struct SaleConfig {
      uint state;
      uint maxSupply;
      uint maxTokensPerAddress;
      uint price;
  }

  string public baseURI;
  string public baseExtension;
  uint public maxTotalSupply = 10000;
  SaleConfig public saleConfig;     
  mapping(address => bool) public isWhitelisted;
    
  Counters.Counter private _tokenId;

  constructor() ERC721("NFT", "NFT") {}

  function totalSupply() public view returns (uint) {
    return _tokenId.current();
  }
  
  function mint(uint _mintAmount) public payable {
    require(saleConfig.state != 0, "Sale is not active");
    if (saleConfig.state == 1) {
        require(isWhitelisted[msg.sender], "Only whitelisted users allowed during presale");
    }
    require(_mintAmount > 0, "You must mint at least 1 NFT");
    require(balanceOf(msg.sender) + _mintAmount <= saleConfig.maxTokensPerAddress, "Max tokens per address exceeded for this wave");
    require(_tokenId.current() + _mintAmount < saleConfig.maxSupply, "Max supply exceeded for this phase");
    require(msg.value >= saleConfig.price * _mintAmount, "Please send the correct amount of ETH");
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
    while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxTotalSupply) {
      address currentTokenOwner = ownerOf(currentTokenId);
      if (currentTokenOwner == _owner) {
        ownedTokenIds[ownedTokenIndex] = currentTokenId;
        ownedTokenIndex++;
      }
      currentTokenId++;
    }
    return ownedTokenIds;
  }
  
  function setSaleConfig(
      uint _state,
      uint _maxSupply, 
      uint _maxTokensPerAddress,
      uint _price
      ) public onlyOwner {
          saleConfig.state = _state;
          saleConfig.maxSupply = _maxSupply;
          saleConfig.maxTokensPerAddress = _maxTokensPerAddress;
          saleConfig.price = _price;
  } 

  function setBaseURI(string memory _baseURI, string memory _baseExtension) public onlyOwner {
    baseURI = _baseURI;
    baseExtension = _baseExtension;
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