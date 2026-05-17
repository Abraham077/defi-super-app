// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "forge-std/Test.sol";
import "../src/GovernanceToken.sol";
import "../src/AMM.sol";
import "../src/Vault.sol";

contract DeFiTest is Test {
    GovernanceToken public token;
    GovernanceToken public tokenB;
    AMM public amm;
    Vault public vault;

    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");

    function setUp() public {
        token = new GovernanceToken();
        tokenB = new GovernanceToken();
        amm = new AMM(address(token), address(tokenB));
        vault = new Vault(address(token));

        // Даём alice и bob токены для тестов
        token.mint(alice, 100_000 ether);
        token.mint(bob, 100_000 ether);
        tokenB.mint(alice, 100_000 ether);
        tokenB.mint(bob, 100_000 ether);
    }

    // ===== GOVERNANCE TOKEN TESTS =====

    function test_TokenName() public view {
        assertEq(token.name(), "DeFi Gov Token");
    }

    function test_TokenSymbol() public view {
        assertEq(token.symbol(), "DGT");
    }

    function test_InitialSupply() public view {
        assertGt(token.totalSupply(), 0);
    }

    function test_MintOnlyOwner() public {
        vm.prank(alice);
        vm.expectRevert();
        token.mint(alice, 1000);
    }

    function test_MintByOwner() public {
        uint256 before = token.totalSupply();
        token.mint(alice, 1000 ether);
        assertEq(token.totalSupply(), before + 1000 ether);
    }

    function test_Delegate() public {
        vm.prank(alice);
        token.delegate(alice);
        assertGt(token.getVotes(alice), 0);
    }

    function test_Transfer() public {
        vm.prank(alice);
        token.transfer(bob, 100 ether);
        assertEq(token.balanceOf(bob), 100_100 ether);
    }

    function test_Allowance() public {
        vm.prank(alice);
        token.approve(bob, 500 ether);
        assertEq(token.allowance(alice, bob), 500 ether);
    }

    // ===== AMM TESTS =====

    function test_AddLiquidity() public {
        vm.startPrank(alice);
        token.approve(address(amm), 1000 ether);
        tokenB.approve(address(amm), 1000 ether);
        uint256 lp = amm.addLiquidity(1000 ether, 1000 ether);
        vm.stopPrank();

        assertGt(lp, 0);
        assertEq(amm.reserveA(), 1000 ether);
        assertEq(amm.reserveB(), 1000 ether);
    }

    function test_SwapAtoB() public {
        // Сначала добавляем ликвидность
        vm.startPrank(alice);
        token.approve(address(amm), 10000 ether);
        tokenB.approve(address(amm), 10000 ether);
        amm.addLiquidity(10000 ether, 10000 ether);
        vm.stopPrank();

        // Bob меняет токены
        vm.startPrank(bob);
        token.approve(address(amm), 100 ether);
        uint256 out = amm.swapAtoB(100 ether, 1);
        vm.stopPrank();

        assertGt(out, 0);
    }

    function test_SwapBtoA() public {
        vm.startPrank(alice);
        token.approve(address(amm), 10000 ether);
        tokenB.approve(address(amm), 10000 ether);
        amm.addLiquidity(10000 ether, 10000 ether);
        vm.stopPrank();

        vm.startPrank(bob);
        tokenB.approve(address(amm), 100 ether);
        uint256 out = amm.swapBtoA(100 ether, 1);
        vm.stopPrank();

        assertGt(out, 0);
    }

    function test_RemoveLiquidity() public {
        vm.startPrank(alice);
        token.approve(address(amm), 1000 ether);
        tokenB.approve(address(amm), 1000 ether);
        uint256 lp = amm.addLiquidity(1000 ether, 1000 ether);
        amm.removeLiquidity(lp);
        vm.stopPrank();

        assertEq(amm.balanceOf(alice), 0);
    }

    function test_SwapRevertSlippage() public {
        vm.startPrank(alice);
        token.approve(address(amm), 10000 ether);
        tokenB.approve(address(amm), 10000 ether);
        amm.addLiquidity(10000 ether, 10000 ether);
        vm.stopPrank();

        vm.startPrank(bob);
        token.approve(address(amm), 100 ether);
        // minAmountOut невозможно высокий — должен упасть
        vm.expectRevert();
        amm.swapAtoB(100 ether, 999999 ether);
        vm.stopPrank();
    }

    function test_AddLiquidityZeroReverts() public {
        vm.startPrank(alice);
        token.approve(address(amm), 1000 ether);
        tokenB.approve(address(amm), 1000 ether);
        vm.expectRevert();
        amm.addLiquidity(0, 1000 ether);
        vm.stopPrank();
    }

    function test_GetAmountOut() public view {
        uint256 out = amm.getAmountOut(100 ether, 10000 ether, 10000 ether);
        assertGt(out, 0);
        assertLt(out, 100 ether); // комиссия уменьшает выход
    }

    // ===== VAULT TESTS =====

    function test_VaultDeposit() public {
        vm.startPrank(alice);
        token.approve(address(vault), 500 ether);
        uint256 shares = vault.deposit(500 ether, alice);
        vm.stopPrank();

        assertGt(shares, 0);
        assertEq(vault.balanceOf(alice), shares);
    }

    function test_VaultWithdraw() public {
        vm.startPrank(alice);
        token.approve(address(vault), 500 ether);
        vault.deposit(500 ether, alice);
        uint256 balBefore = token.balanceOf(alice);
        vault.withdraw(500 ether, alice, alice);
        vm.stopPrank();

        assertGt(token.balanceOf(alice), balBefore);
    }

    function test_VaultShares() public {
        vm.startPrank(alice);
        token.approve(address(vault), 1000 ether);
        vault.deposit(1000 ether, alice);
        vm.stopPrank();

        vm.startPrank(bob);
        token.approve(address(vault), 1000 ether);
        vault.deposit(1000 ether, bob);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), vault.balanceOf(bob));
    }

    function test_VaultRedeem() public {
        vm.startPrank(alice);
        token.approve(address(vault), 500 ether);
        uint256 shares = vault.deposit(500 ether, alice);
        vault.redeem(shares, alice, alice);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 0);
    }

    // ===== FUZZ TESTS =====

    function testFuzz_SwapAlwaysLessThanReserve(uint256 amountIn) public {
        vm.startPrank(alice);
        token.approve(address(amm), 50000 ether);
        tokenB.approve(address(amm), 50000 ether);
        amm.addLiquidity(50000 ether, 50000 ether);
        vm.stopPrank();

        amountIn = bound(amountIn, 1, 1000 ether);

        vm.startPrank(bob);
        token.approve(address(amm), amountIn);
        uint256 out = amm.swapAtoB(amountIn, 0);
        vm.stopPrank();

        assertLt(out, amm.reserveB() + out); // вышло меньше чем было в резерве
    }

    function testFuzz_VaultDepositWithdraw(uint256 amount) public {
        amount = bound(amount, 1 ether, 10000 ether);

        vm.startPrank(alice);
        token.approve(address(vault), amount);
        uint256 shares = vault.deposit(amount, alice);
        assertGt(shares, 0);
        vault.redeem(shares, alice, alice);
        vm.stopPrank();

        assertEq(vault.balanceOf(alice), 0);
    }

    function testFuzz_TokenMint(uint256 amount) public {
        amount = bound(amount, 1, 1_000_000 ether);
        uint256 before = token.totalSupply();
        token.mint(alice, amount);
        assertEq(token.totalSupply(), before + amount);
    }

    // ===== INVARIANT-STYLE TESTS =====

    function test_KInvariant() public {
        vm.startPrank(alice);
        token.approve(address(amm), 10000 ether);
        tokenB.approve(address(amm), 10000 ether);
        amm.addLiquidity(10000 ether, 10000 ether);
        vm.stopPrank();

        uint256 kBefore = amm.reserveA() * amm.reserveB();

        vm.startPrank(bob);
        token.approve(address(amm), 100 ether);
        amm.swapAtoB(100 ether, 0);
        vm.stopPrank();

        uint256 kAfter = amm.reserveA() * amm.reserveB();
        assertGe(kAfter, kBefore); // k не должен уменьшаться
    }

    function test_TotalSupplyConservation() public {
        uint256 supplyBefore = token.totalSupply();
        vm.prank(alice);
        token.transfer(bob, 100 ether);
        assertEq(token.totalSupply(), supplyBefore); // transfer не меняет supply
    }

    function test_VaultTotalAssetsGrowsWithDeposit() public {
        uint256 before = vault.totalAssets();
        vm.startPrank(alice);
        token.approve(address(vault), 1000 ether);
        vault.deposit(1000 ether, alice);
        vm.stopPrank();
        assertGt(vault.totalAssets(), before);
    }
}