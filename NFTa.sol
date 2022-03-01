// @notice NFT contract using ERC721a
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "erc721a/contracts/ERC721A.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTa is ERC721A, Ownable {
  using Strings for uint;

  string private _baseURI;
  string private _baseExtension;
  uint public price = 0.01 ether;
  uint public maxSupply = 10000;
  uint public maxTokensPerAddress = 10;
  bool public saleIsActive;
  uint public supply;

  constructor() ERC721A("NFTa", "NFTa") {}

  function mint(uint _mintAmount) public payable {
    require(saleIsActive, "Sale is not active");
    require(_mintAmount > 0, "You must mint at least 1 NFT");
    require(totalSupply() + _mintAmount <= maxSupply, "Not enough supply");
    require(balanceOf(msg.sender) + _mintAmount <= maxTokensPerAddress, "Max tokens per address limit exceeded");
    require(msg.value >= price * _mintAmount, "Please send the correct amount of ETH");
    _safeMint(msg.sender, _mintAmount);
  }

  function tokenURI(uint tokenId) public view virtual override returns (string memory) {
    require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
    return bytes(_baseURI).length > 0
        ? string(abi.encodePacked(_baseURI, tokenId.toString(), _baseExtension)): "";
  }

//   function walletOfOwner(address _owner) public view returns (uint[] memory) {
//     uint ownerTokenCount = balanceOf(_owner);
//     uint[] memory ownedTokenIds = new uint[](ownerTokenCount);
//     uint currentTokenId = 1;
//     uint ownedTokenIndex = 0;
//     while (ownedTokenIndex < ownerTokenCount && currentTokenId <= maxSupply) {
//       address currentTokenOwner = ownerOf(currentTokenId);
//       if (currentTokenOwner == _owner) {
//         ownedTokenIds[ownedTokenIndex] = currentTokenId;
//         ownedTokenIndex++;
//       }
//       currentTokenId++;
//     }
//     return ownedTokenIds;
//   }

  function setPrice(uint _newPrice) public onlyOwner() {
    price = _newPrice;
  }

  function setBaseURI(string memory _newBaseURI, string memory _newBaseExtension) public onlyOwner {
    _baseURI = _newBaseURI;
    _baseExtension = _newBaseExtension;
  }

  function flipSaleState() public onlyOwner {
    saleIsActive = !saleIsActive;
  }
 
  function withdraw() public onlyOwner {
    (bool success, ) = payable(msg.sender).call{value: address(this).balance}("");
    require(success, "Withdrawal of funds failed");
  }
}