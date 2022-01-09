// NFT contract with presale/whitelist, reveal
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFT is ERC721Enumerable, Ownable {
  using Strings for uint;

  string public baseURI;
  string public baseExtension = '';
  string public hiddenURI;
  uint public price = 0.01 ether;
  uint public maxSupply = 10000;
  uint public maxMintAmount = 10;
  uint public maxTokensOfOwner = 3;
  uint public saleState;        // Sale status, 0 = inactive, 1 = presale, 2 = open for all
  bool public revealed;
  mapping(address => bool) public isWhitelisted;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _hiddenURI,
    string memory _initBaseURI,
    uint _initSupply
  ) ERC721(_name, _symbol) {
    baseURI = _initBaseURI;
    hiddenURI = _hiddenURI;
    for (uint i = 1; i <= _initSupply; i++) {
      _safeMint(msg.sender, totalSupply() + 1);
    }
  }

  
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  
  function mint(uint _mintAmount) public payable {
    require(saleState != 0, 'Sale is not active');
    uint supply = totalSupply();
    require(_mintAmount > 0, "You must mint at least 1 NFT");
    require(supply + _mintAmount <= maxSupply, 'Not enough supply');
    if (msg.sender != owner()) {
        if(saleState == 1) {
            require(isWhitelisted[msg.sender], 'Only whitelisted users allowed during presale');
        }
        require(_mintAmount <= maxMintAmount, 'You cannot mint more than 10 NFTs at a time');
        require(balanceOf(msg.sender) + _mintAmount <= maxTokensOfOwner, 'You cannot have more than 20 NFTs');
        require(msg.value >= price * _mintAmount, 'Please send the correct amount of ETH');
    }

    for (uint i = 1; i <= _mintAmount; i++) {
      _safeMint(msg.sender, supply + i);
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
    
    if(!revealed) {
        return hiddenURI;
    }

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : "";
  }

  
  function reveal() public onlyOwner() {
      revealed = true;
  }

  function setPrice(uint _newPrice) public onlyOwner() {
    price = _newPrice;
  }

  function setMaxMintAmount(uint _newMaxMintAmount) public onlyOwner() {
    maxMintAmount = _newMaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function setSaleState(uint _state) public onlyOwner {
    saleState = _state;
  }
  
  function whitelist(address[] memory _users) public onlyOwner {
      for(uint i = 0; i < _users.length; i++) {
          require(!isWhitelisted[_users[i]], 'already whitelisted');
          isWhitelisted[_users[i]] = true;
      }
  }
  
  function unWhitelist(address[] memory _users) public onlyOwner {
     for(uint i = 0; i < _users.length; i++) {
          require(isWhitelisted[_users[i]], 'not whitelisted');
          isWhitelisted[_users[i]] = false;
     }
  }
 
  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(owner()).call{value: address(this).balance}("");
    require(success);
  }
}