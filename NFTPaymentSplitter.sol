// SPDX-License-Identifier: MIT

pragma solidity ^0.8.11;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/finance/PaymentSplitter.sol";

contract NFTPaymentSplitter is ERC721, Ownable, PaymentSplitter {
    constructor(address[] memory _team, uint256[] memory _shares)
        ERC721("NFTPaymentSplitter", "NFTPS")
        PaymentSplitter(_team, _shares)
    {}

    function etherBalanceOf(address _account) public view returns (uint256) {
        return
            ((address(this).balance + totalReleased()) * shares(_account)) /
            totalShares() -
            released(_account);
    }

    function release(address payable account) public override onlyOwner {
        super.release(account);
    }

    function withdraw() public {
        require(etherBalanceOf(msg.sender) > 0, "No funds to withdraw");
        super.release(payable(msg.sender));
    }
}
