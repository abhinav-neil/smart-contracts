// NFT with reserved supply using uint for both tokenId & reservedTokenId, reserve supply from #1
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;
  
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTReserve is ERC721, Ownable {
  string public baseURI;
  string public baseExtension;
  uint public price = 0.01 ether;
  uint public maxTokensPerAddress = 10;
  bool public saleIsActive;
  uint public maxReserveSupply;
  uint public reserveSupply;
  uint public maxSupply = 10000;
  uint private _reserveTokenId;
  uint private _tokenId=maxReserveSupply;

constructor() ERC721("NFT", "NFT") {}

  function mint(uint _mintAmount) public payable {
    require(saleIsActive, "Sale is not active");
    require(_mintAmount > 0, "You must mint at least 1 NFT");
    require(_tokenId + _mintAmount <= maxSupply, "Not enough supply");
    require(balanceOf(msg.sender) + _mintAmount <= maxTokensPerAddress, "Max tokens per address limit exceeded");
    require(msg.value >= price * _mintAmount, "Please send the correct amount of ETH");
    for (uint i = 0; i < _mintAmount; ++i) {
        _safeMint(msg.sender, _tokenId + i);
    }
    _tokenId += _mintAmount;
  }

  function gift(address _to, uint _alllowance) public onlyOwner {
    require(_reserveTokenId + _alllowance <= maxReserveSupply, "Max reserve supply exceeded");
    for (uint i = 0; i < _alllowance; ++i) {
        _safeMint(_to, _reserveTokenId + i);
    }
    _reserveTokenId += _alllowance;
  }

  function giftSpecial(address _to, uint[] memory _tokenIds) public onlyOwner {
    uint _numTokens = _tokenIds.length;
    require(reserveSupply + _numTokens <= maxReserveSupply, "Max reserve supply exceeded");
    for (uint i = 0; i < _numTokens; i++) {
        _safeMint(_to, _tokenIds[i]);
    }
    reserveSupply += _numTokens;
  }

  function batchGift(address[] calldata _recipients, uint8[] calldata _alllowances) public onlyOwner {
    for (uint i = 0; i < _recipients.length; i++) {
        require(_reserveTokenId + _alllowances[i] <= maxSupply, "Max reserve supply exceeded");
        for (uint j = 0; j < _alllowances[i]; ++j) {
            _safeMint(_recipients[i], _reserveTokenId + j);
        }
        _reserveTokenId += _alllowances[i];
    }
  }
}