// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

/// @title AMM — простой обменник токенов (x*y=k)
contract AMM is ERC20, ReentrancyGuard {
    using SafeERC20 for IERC20;

    IERC20 public immutable tokenA;
    IERC20 public immutable tokenB;

    uint256 public reserveA;
    uint256 public reserveB;

    uint256 public constant FEE = 3; // 0.3%

    event Swap(address indexed user, uint256 amountIn, uint256 amountOut, bool aToB);
    event LiquidityAdded(address indexed user, uint256 amountA, uint256 amountB, uint256 lpTokens);
    event LiquidityRemoved(address indexed user, uint256 amountA, uint256 amountB);

    constructor(address _tokenA, address _tokenB)
        ERC20("LP Token", "LP")
    {
        tokenA = IERC20(_tokenA);
        tokenB = IERC20(_tokenB);
    }

    /// @notice Добавить ликвидность в пул
    function addLiquidity(uint256 amountA, uint256 amountB) external nonReentrant returns (uint256 lpTokens) {
        // Checks
        require(amountA > 0 && amountB > 0, "Amounts must be > 0");

        // Effects
        if (totalSupply() == 0) {
            lpTokens = sqrt(amountA * amountB);
        } else {
            lpTokens = min(
                (amountA * totalSupply()) / reserveA,
                (amountB * totalSupply()) / reserveB
            );
        }
        require(lpTokens > 0, "Insufficient liquidity");

        reserveA += amountA;
        reserveB += amountB;
        _mint(msg.sender, lpTokens);

        // Interactions
        tokenA.safeTransferFrom(msg.sender, address(this), amountA);
        tokenB.safeTransferFrom(msg.sender, address(this), amountB);

        emit LiquidityAdded(msg.sender, amountA, amountB, lpTokens);
    }

    /// @notice Обменять токен A на токен B
    function swapAtoB(uint256 amountIn, uint256 minAmountOut) external nonReentrant returns (uint256 amountOut) {
        require(amountIn > 0, "Amount must be > 0");

        // Checks-Effects-Interactions
        amountOut = getAmountOut(amountIn, reserveA, reserveB);
        require(amountOut >= minAmountOut, "Slippage too high");
        require(amountOut < reserveB, "Insufficient liquidity");

        reserveA += amountIn;
        reserveB -= amountOut;

        tokenA.safeTransferFrom(msg.sender, address(this), amountIn);
        tokenB.safeTransfer(msg.sender, amountOut);

        emit Swap(msg.sender, amountIn, amountOut, true);
    }

    /// @notice Обменять токен B на токен A
    function swapBtoA(uint256 amountIn, uint256 minAmountOut) external nonReentrant returns (uint256 amountOut) {
        require(amountIn > 0, "Amount must be > 0");

        amountOut = getAmountOut(amountIn, reserveB, reserveA);
        require(amountOut >= minAmountOut, "Slippage too high");
        require(amountOut < reserveA, "Insufficient liquidity");

        reserveB += amountIn;
        reserveA -= amountOut;

        tokenB.safeTransferFrom(msg.sender, address(this), amountIn);
        tokenA.safeTransfer(msg.sender, amountOut);

        emit Swap(msg.sender, amountIn, amountOut, false);
    }

    /// @notice Убрать ликвидность
    function removeLiquidity(uint256 lpTokens) external nonReentrant returns (uint256 amountA, uint256 amountB) {
        require(lpTokens > 0, "Must burn > 0");

        amountA = (lpTokens * reserveA) / totalSupply();
        amountB = (lpTokens * reserveB) / totalSupply();

        require(amountA > 0 && amountB > 0, "Insufficient amounts");

        reserveA -= amountA;
        reserveB -= amountB;
        _burn(msg.sender, lpTokens);

        tokenA.safeTransfer(msg.sender, amountA);
        tokenB.safeTransfer(msg.sender, amountB);

        emit LiquidityRemoved(msg.sender, amountA, amountB);
    }

    /// @notice Посчитать сколько получишь при обмене (с учётом 0.3% комиссии)
    function getAmountOut(uint256 amountIn, uint256 reserveIn, uint256 reserveOut)
        public pure returns (uint256)
    {
        uint256 amountInWithFee = amountIn * 997;
        return (amountInWithFee * reserveOut) / (reserveIn * 1000 + amountInWithFee);
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) { z = x; x = (y / x + x) / 2; }
        } else if (y != 0) { z = 1; }
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}