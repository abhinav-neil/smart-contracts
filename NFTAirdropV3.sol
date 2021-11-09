pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC721/IERC721.sol';
import '@openzeppelin/contracts/access/Ownable.sol';

contract NFTAirdropV3 is Ownable {
  
  bool public airdropIsActive;
  uint public tokenId;
  uint public maxTokenId;
  address public nft;

  mapping(address => bool) public isWhitelistedForAirdrop;

  constructor(
      address _nft,
      uint _tokenId,
      uint _maxTokenId) {
      nft = _nft;
      tokenId = _tokenId;
      maxTokenId = _maxTokenId;
  }
  
  function whitelistForAirdrop(address[] memory _users) public onlyOwner {
      for(uint i = 0; i < _users.length; i++) {
          require(!isWhitelistedForAirdrop[_users[i]], 'already whitelisted');
          isWhitelistedForAirdrop[_users[i]] = true;
      }
  }

  function claim() external {
    require(isWhitelistedForAirdrop[msg.sender], 'You are not listed for airdrops');
    require(tokenId <= maxTokenId, 'Airdrop over');
    require(IERC721(nft).ownerOf(tokenId) == address(this), 'NFT not found');
    IERC721(nft).safeTransferFrom(address(this), msg.sender, tokenId);
    tokenId++;
    isWhitelistedForAirdrop[msg.sender] = false;
  }
  
  function setAirdropNFT(address _nft, uint _startingIndex, uint _maxTokenId) public onlyOwner {
      nft = _nft;
      tokenId = _startingIndex;
      maxTokenId = _maxTokenId;
  }
    
  function flipAirdropState() public onlyOwner {
    airdropIsActive = !airdropIsActive;
  }
}