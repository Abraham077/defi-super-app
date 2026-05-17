import { Swap, LiquidityAdded } from "../generated/AMM/AMM";
import { Deposit } from "../generated/Vault/Vault";
import {
  Swap as SwapEntity,
  LiquidityEvent,
  VaultDeposit,
  PoolState,
} from "../generated/schema";
import { BigInt } from "@graphprotocol/graph-ts";

export function handleSwap(event: Swap): void {
  let id = event.transaction.hash.toHex() + "-" + event.logIndex.toString();
  let swap = new SwapEntity(id);
  swap.user = event.params.user;
  swap.amountIn = event.params.amountIn;
  swap.amountOut = event.params.amountOut;
  swap.aToB = event.params.aToB;
  swap.blockNumber = event.block.number;
  swap.timestamp = event.block.timestamp;
  swap.save();

  // Update pool state
  let pool = PoolState.load("1");
  if (!pool) {
    pool = new PoolState("1");
    pool.reserveA = BigInt.fromI32(0);
    pool.reserveB = BigInt.fromI32(0);
  }
  pool.lastUpdated = event.block.timestamp;
  pool.save();
}

export function handleLiquidityAdded(event: LiquidityAdded): void {
  let id = event.transaction.hash.toHex() + "-" + event.logIndex.toString();
  let liq = new LiquidityEvent(id);
  liq.user = event.params.user;
  liq.amountA = event.params.amountA;
  liq.amountB = event.params.amountB;
  liq.lpTokens = event.params.lpTokens;
  liq.blockNumber = event.block.number;
  liq.timestamp = event.block.timestamp;
  liq.save();
}

export function handleVaultDeposit(event: Deposit): void {
  let id = event.transaction.hash.toHex() + "-" + event.logIndex.toString();
  let dep = new VaultDeposit(id);
  dep.sender = event.params.sender;
  dep.owner = event.params.owner;
  dep.assets = event.params.assets;
  dep.shares = event.params.shares;
  dep.blockNumber = event.block.number;
  dep.timestamp = event.block.timestamp;
  dep.save();
}