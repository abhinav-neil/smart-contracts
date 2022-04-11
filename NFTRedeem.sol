// Contract to redeem one NFT collection for another

interface IMintPass {
    /**
     * @dev Burns `tokenId`. See {ERC721-_burn}.
     *
     * Requirements:
     *
     * - The caller must own `tokenId` or be an approved operator.
     */
    function burn(uint256 tokenId) external;

    /**
     * @dev Returns the number of tokens in ``owner``'s account.
     */
    function balanceOf(address owner) external view returns (uint256 balance);

    /**
     * @dev Returns a token ID owned by `owner` at a given `index` of its token list.
     * Use along with {balanceOf} to enumerate all of ``owner``'s tokens.
     */
    function tokenOfOwnerByIndex(address owner, uint256 index) external view returns (uint256 tokenId);
}

contract NFTRedeem is ERC721 {
    address public mintPass;
    uint public NFTsPerPass;

    constructor() ERC721("NFT", "NFT") {}

    function redeemMint(uint _mintAmount) public payable {
    require(_mintAmount <= IMintPass(mintPass).balanceOf(msg.sender) * NFTsPerPass);
    for (uint i = 0; i < _mintAmount; i++) {
        _tokenId.increment();
        _safeMint(msg.sender, _tokenId.current());
    }
  }
}