// NFT contract with presale/whitelist
//store sale config (price, max tokens etc) in struct instead of individually, do not hard-code but set via setters 
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721Enumerable, Ownable {
  using Strings for uint;
  using Counters for Counters.Counter;

  struct Sale {
      uint state;
      uint maxSupply;
      uint maxTokensPerAddress;
      uint price;
  }

  string public baseURI;
  string public baseExtension;
  uint public maxTotalSupply = 10000;
  Sale public sale;     
  mapping(address => bool) public isWhitelisted;
    
  Counters.Counter private _tokenId;

  constructor() ERC721("NFT", "NFT") {}
  
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }
  
  function mint(uint _mintAmount) public payable {
    require(sale.state != 0, "Sale is not active");
    if (sale.state == 1) {
        require(isWhitelisted[msg.sender], "Only whitelisted users allowed during presale");
    }
    require(_mintAmount > 0, "You must mint at least 1 NFT");
    require(balanceOf(msg.sender) + _mintAmount <= sale.maxTokensPerAddress, "Max tokens per address exceeded for this wave");
    require(_tokenId.current() + _mintAmount < sale.maxSupply, "Max supply exceeded for this phase");
    require(msg.value >= sale.price * _mintAmount, "Please send the correct amount of ETH");
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

  function tokenURI(uint tokenId)
    public
    view
    virtual
    override
    returns (string memory)
  {
    require(
      _exists(tokenId),
      "ERC721Metadata: URI query for nonexistent token"
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }
  
  function setSaleDetails(
      uint _state,
      uint _maxSupply, 
      uint _maxTokensPerAddress,
      uint _price
      ) public onlyOwner {
          sale.state = _state;
          sale.maxSupply = _maxSupply;
          sale.maxTokensPerAddress = _maxTokensPerAddress;
          sale.price = _price;
  } 

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
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