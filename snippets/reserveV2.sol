uint public maxPublicSupply;

uint public maxSupply;
uint private _reserveTokenId = maxPublicSupply;

function mintReserve(address _to, uint _mintAmount) public onlyOwner {
    require(_reserveTokenId + _mintAmount <= maxSupply, "Max supply exceeded");
    for (uint i = 0; i < _mintAmount; i++) {
      _reserveTokenId++;
      _safeMint(_to, _reserveTokenId);
    }
}


