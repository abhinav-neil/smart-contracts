   modifier isMintValid(uint _mintAmount) {
    require(_mintAmount > 0, "You must mint at least 1 NFT"); 
    require(_mintAmount <= maxMintAmount, "Max mint amount limit exceeded");
    require(balanceOf(msg.sender) + _mintAmount <= maxTokensOfOwner, "Max NFTs per address exceeded");
    require(msg.value >= price * _mintAmount, "Please send the correct amount of ETH");
    _;
  }