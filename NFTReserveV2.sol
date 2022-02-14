// NFT with reserved supply using uint for reservedTokenId
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;
  
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTReserve is ERC721, Ownable {
  uint public maxPublicSupply;
  uint public maxSupply;
  uint private _reserveTokenId = maxPublicSupply+1;

constructor() ERC721("NFT", "NFT") {}

  function reserveTokensMinted() public view returns(uint) {
    return _reserveTokenId - maxPublicSupply;
  }

  function gift(address _to, uint _alllowance) public onlyOwner {
    require(_reserveTokenId + _alllowance <= maxSupply, "Max reserve supply exceeded");
    for (uint i = 0; i < _alllowance; ++i) {
        _safeMint(_to, _reserveTokenId + i);
    }
    _reserveTokenId += _alllowance;
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