// @notice NFT contract with minting restricted to owners of partner NFT contract, using IERC721
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract NFT is ERC721, Ownable {
    using Counters for Counters.Counter;

    address public partnerContract;
    Counters.Counter private _tokenId;

    constructor() ERC721("NFT", "NFT") {}

    function mint(uint _mintAmount) public payable {
    require(IERC721(partnerContract).balanceOf(msg.sender) > 0, "Partner contract owners only");
    for (uint i = 0; i < _mintAmount; i++) {
        _tokenId.increment();
        _safeMint(msg.sender, _tokenId.current());
    }
  }
}