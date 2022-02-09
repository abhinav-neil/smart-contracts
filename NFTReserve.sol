// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;
  
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTReserve is ERC721Enumerable, Ownable {
  using Counters for Counters.Counter;
  uint public maxPublicSupply;
  uint public maxReserveSupply;
  Counters.Counter private _reserveTokenId;

constructor() ERC721("NFT", "NFT") {}

  function reserveTokensMinted() public view returns(uint) {
    return _reserveTokenId.current();
  }

  function gift(address _to, uint _alllowance) public onlyOwner {
    require(_reserveTokenId.current() + _alllowance <= maxReserveSupply, "Max reserve supply exceeded");
    for (uint i = 0; i < _alllowance; i++) {
        _reserveTokenId.increment();
        _safeMint(_to, maxPublicSupply + _reserveTokenId.current());
    }
  }

  function batchGift(address[] memory _recipients, uint8[] memory _alllowances) public onlyOwner {
    for (uint i = 0; i < _recipients.length; i++) {
        require(_reserveTokenId.current() + _alllowances[i] <= maxReserveSupply, "Max reserve supply exceeded");
        for (uint j = 0; j < _alllowances[i]; j++) {
            _reserveTokenId.increment();
            _safeMint(_recipients[i], maxPublicSupply + _reserveTokenId.current());
        }
    }
  }
}