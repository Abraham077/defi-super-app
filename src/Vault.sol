// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC4626.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

/// @title Vault — ERC-4626 хранилище токенов
contract Vault is ERC4626, Ownable {
    event YieldAdded(uint256 amount);

    constructor(address asset)
        ERC4626(IERC20(asset))
        ERC20("Vault Share", "vSHARE")
        Ownable(msg.sender)
    {}

    /// @notice Владелец может добавить доходность в vault
    function addYield(uint256 amount) external onlyOwner {
        SafeERC20.safeTransferFrom(IERC20(asset()), msg.sender, address(this), amount);
        emit YieldAdded(amount);
    }
}