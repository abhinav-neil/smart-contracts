// Airdrop from ERC-721 contract w/ WL & claim (mint) model
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import '@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol';
import '@openzeppelin/contracts/access/Ownable.sol';
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFTAirdropV2 is ERC721Enumerable, Ownable {
  using Strings for uint;
  using Counters for Counters.Counter;

  uint public maxSupply = 10000;
  bool public isAirdropActive; 

//   mapping(address => bool) public isWhitelistedForAirdrop; // same allowance for all
  mapping(address => uint) public airdropAllowance; // variable allowance per address

  Counters.Counter private _tokenId;
  
  constructor() ERC721("NFT", "NFT") {}
  
  function claimAirdrop() public {
    require(isAirdropActive, "Airdrop is inactive");  
    uint _allowance = airdropAllowance[msg.sender];
    require(_allowance > 0, "You have no airdrops to claim");
    require(_tokenId.current() + _allowance <= maxSupply, "Max supply exceeded");
    for (uint i = 0; i < _allowance; i++) {
      _tokenId.increment();
      _safeMint(msg.sender, _tokenId.current());
    }
    airdropAllowance[msg.sender] = 0;
  }

  function setAirdropActive(bool _state) public onlyOwner {
    isAirdropActive = _state;
  }

  function setAirdropAllowance(address[] memory _users, uint[] memory _allowances) public onlyOwner {
      require(_users.length == _allowances.length, "Length mismatch");
      for(uint i = 0; i < _users.length; i++) {
          airdropAllowance[_users[i]] = _allowances[i];
      }
  }

}