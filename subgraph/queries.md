# GraphQL Queries

## 1. Get all swaps
```graphql
{
  swaps(first: 10, orderBy: timestamp, orderDirection: desc) {
    id
    user
    amountIn
    amountOut
    aToB
    timestamp
  }
}
```

## 2. Get liquidity events
```graphql
{
  liquidityEvents(first: 10) {
    id
    user
    amountA
    amountB
    lpTokens
    timestamp
  }
}
```

## 3. Get vault deposits
```graphql
{
  vaultDeposits(first: 10) {
    id
    sender
    assets
    shares
    timestamp
  }
}
```

## 4. Get pool state
```graphql
{
  poolState(id: "1") {
    reserveA
    reserveB
    lastUpdated
  }
}
```

## 5. Get user swaps
```graphql
{
  swaps(where: { user: "0xYOUR_ADDRESS" }) {
    id
    amountIn
    amountOut
    timestamp
  }
}
```