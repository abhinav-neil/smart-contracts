uint public reservedForOwner = 1101;
uint private _reserveSupply;
uint private _publicSupply;
  
function mint(uint _mintAmount) public payable {
require(saleState != 0, 'Sale is not active');
uint _currentTokenId = reservedForOwner + _publicSupply;
require(_mintAmount > 0, "You must mint at least 1 NFT");
require(_currentTokenId + _mintAmount <= maxSupply, 'Not enough supply');
if (msg.sender != owner()) {
    if(saleState == 1) {
        require(isWhitelisted[msg.sender], 'Only whitelisted users allowed during presale');
    }
    require(_mintAmount <= maxMintAmount, 'Max mint amount limit exceeded');
    require(balanceOf(msg.sender) + _mintAmount <= maxTokensOfOwner, 'Max tokens per address limit exceeded');
    require(msg.value >= price() * _mintAmount, 'Please send the correct amount of ETH');
}

for (uint i = 1; i <= _mintAmount; i++) {
    _safeMint(msg.sender, _currentTokenId + i);
}
_publicSupply += _mintAmount;
}

function mintReserved(uint _mintAmount) public onlyOwner {
uint _currentTokenId = _reserveSupply;
require(_mintAmount > 0, "You must mint at least 1 NFT");
require(_currentTokenId + _mintAmount <= reservedForOwner, 'Exceeds reserved supply');
for (uint i = 1; i <= _mintAmount; i++) {
    _safeMint(msg.sender, _currentTokenId + i);
} 
_reserveSupply += _mintAmount;
} 