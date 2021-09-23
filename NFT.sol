pragma solidity ^0.8.0;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract NFT is ERC721Enumerable, Ownable {
  using Strings for uint;

  string public baseURI;
  string public baseExtension = '';
  uint public price = 0.01 ether;
  uint public maxSupply = 10000;
  uint public maxMintAmount = 10;
  uint public maxTokensOfOwner = 20;
  bool public paused = true;

  constructor(
    string memory _name,
    string memory _symbol,
    string memory _initBaseURI,
    uint _initSupply
  ) ERC721(_name, _symbol) {
    setBaseURI(_initBaseURI);
    mint(msg.sender, _initSupply);
  }

  // internal
  function _baseURI() internal view virtual override returns (string memory) {
    return baseURI;
  }

  // public
  function mint(address _to, uint _mintAmount) public payable {
    uint supply = totalSupply();
    require(!paused, 'Sale is paused');
    require(_mintAmount > 0, 'You must mint at least 1 NFT');
    require(_mintAmount <= maxMintAmount, 'You cannot mint more than 10 NFTs at a time');
    require(supply + _mintAmount <= maxSupply, 'Not enough supply');
    require(balanceOf(_to) + _mintAmount <= maxTokensOfOwner, 'You cannot have more than 20 NFTs');
    require(msg.value >= price * _mintAmount, 'Please send the correct amount of ETH');
    for (uint i = 1; i <= _mintAmount; i++) {
      _safeMint(_to, supply + i);
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

  //only owner
  function setPrice(uint _newPrice) public onlyOwner() {
    price = _newPrice;
  }

  function setmaxMintAmount(uint _newmaxMintAmount) public onlyOwner() {
    maxMintAmount = _newmaxMintAmount;
  }

  function setBaseURI(string memory _newBaseURI) public onlyOwner {
    baseURI = _newBaseURI;
  }

  function setBaseExtension(string memory _newBaseExtension) public onlyOwner {
    baseExtension = _newBaseExtension;
  }

  function pause(bool _state) public onlyOwner {
    paused = _state;
  }
 
  function withdraw() public payable onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}('');
    require(success);
  }
}