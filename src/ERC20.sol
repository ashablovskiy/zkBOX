// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-contracts/contracts/access/Ownable.sol";
import "openzeppelin-contracts/contracts/token/ERC20/extensions/draft-ERC20Permit.sol";

contract KhaosAsset is ERC20, Ownable, ERC20Permit {
    constructor() ERC20("KhaosAsset", "KHS") ERC20Permit("KhaosAsset") {}

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }
}