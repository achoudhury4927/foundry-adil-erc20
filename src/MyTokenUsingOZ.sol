// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

/**
 * @title A sample ERC-20 Token contract
 * @author Adil Choudhury
 * @notice This contract is for creating an ERC-20 token
 * @dev This is an attempt to create an ERC-20 using the Open Zepplin contracts
 */
contract MyTokenUsingOZ is ERC20 {
    constructor(uint256 initialSupply) ERC20("My Token", "AMT") {
        _mint(msg.sender, initialSupply);
    }
}
