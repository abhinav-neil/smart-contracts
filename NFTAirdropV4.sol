//SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract NFTAirdropV3 is Ownable {

  address payable primaryWallet;
  uint airdropId;
  
  struct Airdrop {
      address nft;
      bool active;
      uint tokenId;
      uint maxTokenId;
      uint price;
  }
  
  mapping(uint => Airdrop) public airdrops;
  mapping(uint => mapping(address => bool)) isWhitelisted;

  constructor(address payable _primaryWallet) {
      primaryWallet = _primaryWallet;
  }
  
  function createAirdrop(
      address _nft,
      uint _startingTokenId,
      uint _maxTokenId, 
      uint _price)
      public onlyOwner {
    Airdrop memory airdrop = Airdrop(_nft, false, _startingTokenId, _maxTokenId, _price);
    airdrops[airdropId] = airdrop;
    airdropId++;
  }
  
  function whitelist(uint _airdropId, address[] memory _users) public onlyOwner {
      for(uint i = 0; i < _users.length; i++) {
          require(!isWhitelisted[_airdropId][_users[i]], 'already whitelisted');
          isWhitelisted[_airdropId][_users[i]] = true;
      }
  }

  function claim(uint _airdropId) external payable {
    Airdrop storage airdrop = airdrops[_airdropId];
    require(isWhitelisted[_airdropId][msg.sender], 'You are not listed for airdrops');
    require(airdrop.tokenId <= airdrop.maxTokenId, 'Airdrop over');
    require(msg.value >= airdrop.price, 'Please send correct amount of ETH');
    AirdropInterface(airdrop.nft).claimAirdrop(msg.sender, airdrop.tokenId);
    airdrop.tokenId++;
    isWhitelisted[_airdropId][msg.sender] = false;
    (bool success, ) = primaryWallet.call{value: msg.value}("");
    require(success);
  }
    
  function flipAirdropState(uint _airdropId) public onlyOwner {
    Airdrop storage airdrop = airdrops[_airdropId];
    airdrop.active = !airdrop.active;
  }
}

interface AirdropInterface {
    function claimAirdrop(address _recipient, uint _tokenId) external;
}