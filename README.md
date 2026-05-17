# DeFi Super App

A full-stack decentralized protocol built on Base Sepolia.

## Deployed Contracts (Base Sepolia)

| Contract | Address |
|----------|---------|
| GovernanceToken (TokenA) | 0x65fCe7D7786d8307358352aC976F400605DAd019 |
| GovernanceToken (TokenB) | 0x76D1115f4C4E85E8eeB6De10DC38486Ecd65cb1D |
| AMM | 0x78571D874Cf73178dD51A3dF641FaDDcbC3D129e |
| Vault (ERC-4626) | 0x302C61061b82d8Db7A23A6b058fbFE79C25AbD43 |

## Block Explorer Links
- [TokenA on Basescan](https://sepolia.basescan.org/address/0x65fCe7D7786d8307358352aC976F400605DAd019)
- [TokenB on Basescan](https://sepolia.basescan.org/address/0x76D1115f4C4E85E8eeB6De10DC38486Ecd65cb1D)
- [AMM on Basescan](https://sepolia.basescan.org/address/0x78571D874Cf73178dD51A3dF641FaDDcbC3D129e)
- [Vault on Basescan](https://sepolia.basescan.org/address/0x302C61061b82d8Db7A23A6b058fbFE79C25AbD43)

## Architecture

**Option A — DeFi Super-App** consisting of:
- **GovernanceToken** — ERC20Votes + ERC20Permit governance token
- **AMM** — Constant product market maker (x*y=k) with 0.3% fee and LP tokens
- **Vault** — ERC-4626 tokenized yield vault
- **MyGovernor** — OpenZeppelin Governor with Timelock

## Tech Stack
- Solidity 0.8.20
- Foundry (forge, cast)
- OpenZeppelin Contracts
- Base Sepolia (L2)
- Ethers.js v6

## Setup & Installation

```bash
git clone https://github.com/YOUR_USERNAME/defi-super-app
cd defi-super-app
forge install
forge build
```

## Running Tests

```bash
forge test -v
```

## Deploy

```bash
forge script script/Deploy.s.sol:Deploy \
  --rpc-url https://sepolia.base.org \
  --private-key YOUR_PRIVATE_KEY \
  --broadcast
```

## Frontend

Open `frontend/index.html` in your browser. Connect MetaMask to Base Sepolia.

## Gas Comparison (L1 vs L2)

| Operation | L1 Mainnet (est.) | Base Sepolia | Savings |
|-----------|-------------------|--------------|---------|
| Deploy GovernanceToken | ~$45 | ~$0.002 | 99.9% |
| Deploy AMM | ~$80 | ~$0.003 | 99.9% |
| Deploy Vault | ~$30 | ~$0.001 | 99.9% |
| Swap tokens | ~$15 | ~$0.0005 | 99.9% |
| Add Liquidity | ~$20 | ~$0.0006 | 99.9% |
| Vault Deposit | ~$12 | ~$0.0004 | 99.9% |

## Test Coverage

27 tests passing including unit, fuzz, and invariant tests.

## Design Patterns Used

1. **Checks-Effects-Interactions** — used in AMM swap and liquidity functions
2. **ReentrancyGuard** — AMM protected against reentrancy attacks
3. **Access Control / Ownable** — GovernanceToken mint restricted to owner
4. **ERC-4626 Vault** — standardized yield vault interface
5. **Factory pattern** — Deploy script deploys all contracts
6. **Pull-over-push** — users pull their tokens via withdraw/redeem