// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract NFTAirdropV2 is ERC721Enumerable, Ownable {
  using Strings for uint;

  string public baseURI;
  string public baseExtension = '';
  uint public maxSupply = 10000;
  bool public airdropIsActive; 

  mapping(address => uint) public recipients;
  
  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
  }

  
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  
  function claim() public {
    uint supply = totalSupply();
    uint amount = recipients[msg.sender];
    require(airdropIsActive, 'Airdrop is not active');
    require(amount > 0, 'You are not listed for airdrops');
    require(supply + amount <= maxSupply, 'Not enough supply');
    for (uint i = 1; i <= amount; i++) {
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
      'ERC721Metadata: URI query for nonexistent token'
    );

    string memory currentBaseURI = _baseURI();
    return bytes(currentBaseURI).length > 0
        ? string(abi.encodePacked(currentBaseURI, tokenId.toString(), baseExtension))
        : '';
  }

  
  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function flipAirdropState() public onlyOwner {
    airdropIsActive = !airdropIsActive;
  }

  function setRecipients(address[] memory _recipients, uint[] memory _amounts) external onlyOwner {
    require(_recipients.length == _amounts.length, 'Recipients and amounts array have to be of same size');
    for(uint i = 0; i < _recipients.length; i++) {
        recipients[_recipients[i]] = _amounts[i];
    }
  }

}