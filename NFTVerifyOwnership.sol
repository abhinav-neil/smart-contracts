// @notice NFT contract with minting restricted to owners of partner NFT contract
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

abstract contract PartnerContract {
   function balanceOf(address owner) external virtual view returns (uint256 balance);
}

contract NFT is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenId;
    PartnerContract partnerContract = PartnerContract(0xBC4CA0EdA7647A8aB7C2061c2E118A18a936f13D);

    constructor() ERC721("NFT", "NFT") {}

    function mint(uint _mintAmount) public payable {
    require(partnerContract.balanceOf(msg.sender) > 0, "Partner contract owners only");
    for (uint i = 0; i < _mintAmount; i++) {
        _tokenId.increment();
        _safeMint(msg.sender, _tokenId.current());
    }
  }
}