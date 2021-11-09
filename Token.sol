// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract Token is ERC20 {
    
    constructor (
        string memory _name,
        string memory _symbol,
        uint _initSupply
        ) ERC20 (_name, _symbol) {
            _mint(msg.sender, _initSupply);
        }
        
        function mint(address _account, uint _amount) external {
            _mint(_account, _amount);
        }
}