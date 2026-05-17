// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Votes.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title GovernanceToken
/// @notice ERC20 токен с правом голоса для DAO
contract GovernanceToken is ERC20Votes, ERC20Permit, Ownable {
    constructor()
        ERC20("DeFi Gov Token", "DGT")
        ERC20Permit("DeFi Gov Token")
        Ownable(msg.sender)
    {
        // Минтим 1 миллион токенов создателю
        _mint(msg.sender, 1_000_000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    // Обязательные override функции
    function _update(address from, address to, uint256 value)
        internal
        override(ERC20, ERC20Votes)
    {
        super._update(from, to, value);
    }

    function nonces(address owner)
        public view override(ERC20Permit, Nonces)
        returns (uint256)
    {
        return super.nonces(owner);
    }
}