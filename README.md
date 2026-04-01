# DoubleWin Smart Contracts

Smart contracts for [DoubleWin](https://doublewin.me) — an AI-powered, provably fair gaming platform deployed on **BNB Smart Chain (BSC)**.

## Deployed Contracts (BSC Mainnet)

| Contract | Address | Description |
|----------|---------|-------------|
| VRFConsumer | `0x1d336B379650782543B39624a3db0a6eb5404376` | Chainlink VRF V2+ randomness consumer |

## Overview

DoubleWin uses **Chainlink VRF V2+** on BNB Smart Chain to generate verifiable, tamper-proof random numbers for all games. Every game outcome is cryptographically committed before play and verifiable after.

### VRFConsumer

The core randomness contract integrates with [Chainlink VRF V2+](https://docs.chain.link/vrf) on BSC:

- Requests on-chain random numbers from Chainlink VRF Coordinator on BNB Chain
- Stores and exposes the latest random result for game seed derivation
- Owner-controlled request function for epoch-based seed rotation
- Events for monitoring: `RandomRequested`, `RandomFulfilled`

### Provably Fair System

Game results are derived using a three-layer architecture:

1. **Epoch Layer** — VRF-based on-chain randomness via Chainlink on BSC
2. **Seed Layer** — Per-player server seeds derived from epoch seed + player-controlled client seeds
3. **Verification** — `HMAC-SHA256(serverSeed, clientSeed:nonce:cursor)` — players can verify any past bet

## Tech Stack

- **Blockchain:** BNB Smart Chain (BSC)
- **Randomness Oracle:** Chainlink VRF V2+ (BSC)
- **Smart Contract Language:** Solidity 0.8.20
- **Framework:** Hardhat 3
- **Dependencies:** OpenZeppelin Contracts, Chainlink Contracts

## Network Configuration

The contracts are configured for BNB Chain networks:

- **BSC Mainnet** — `https://bsc-dataseed.bnbchain.org` (Chain ID: 56)
- **BSC Testnet** — `https://data-seed-prebsc-1-s1.bnbchain.org:8545` (Chain ID: 97)

## Development

### Install

```bash
npm install
```

### Compile

```bash
npx hardhat compile
```

### Test

```bash
npx hardhat test
```

### Deploy

```bash
# BSC Testnet
npx hardhat run scripts/deploy.ts --network bscTestnet

# BSC Mainnet
npx hardhat run scripts/deploy.ts --network bscMainnet
```

## Links

- **Website:** [doublewin.me](https://doublewin.me)
- **Provably Fair Verification:** [doublewin.me/provably-fair](https://doublewin.me/provably-fair)
- **VRFConsumer on BscScan:** [0x1d336B379650782543B39624a3db0a6eb5404376](https://bscscan.com/address/0x1d336B379650782543B39624a3db0a6eb5404376)

## License

MIT
