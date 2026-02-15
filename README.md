# ProofOfBuilder 🛡️

> **Decentralized On-Chain Reputation Engine for the Stacks Ecosystem**

[![Built on Stacks](https://img.shields.io/badge/Built%20on-Stacks-FF4B26?style=flat-square)](https://stacks.co)
[![Clarity](https://img.shields.io/badge/Language-Clarity-7C3AED?style=flat-square)](https://docs.stacks.co/clarity)
[![Bitcoin L2](https://img.shields.io/badge/Bitcoin-Layer%202-F7931A?style=flat-square)](https://stacks.co)
[![License: MIT](https://img.shields.io/badge/License-MIT-green?style=flat-square)](LICENSE)

**Tags:** `Stacks` · `Clarity` · `Bitcoin Layer 2` · `DeFi` · `sBTC` · `SBT` · `Reputation`

---

## 🎯 Problem

In Web3, identifying high-impact builders is fragmented. GitHub activity, on-chain deployments, and community contributions are siloed. There's no single on-chain source of truth for **who's actually building**.

## 💡 Solution

**ProofOfBuilder** is a protocol-level reputation engine that:

1. **Tracks Daily Activity** — 24h-enforced check-in heartbeat with streak tracking
2. **Links Identities** — Maps GitHub profiles to Stacks addresses on-chain
3. **Mints Soulbound Tokens** — Non-transferable NFTs proving builder status (SIP-009)
4. **Enables Staking** — Lock STX to signal long-term ecosystem commitment
5. **Verifies Contributions** — Projects can certify builder contributions on-chain
6. **Facilitates Swaps** — STX-USDC OTC swap desk for builder liquidity
7. **Bridges sBTC** — Escrow for trustless sBTC ↔ STX swaps on Bitcoin L2
8. **Incentivizes OSS** — Bounty board with STX rewards for open-source contributions

All fees flow into a **consolidated treasury** that tracks spend-per-user, enabling fair reward distribution to top contributors after each event period.

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────────┐
│                     ProofOfBuilder Protocol                   │
├──────────┬──────────┬──────────┬──────────┬──────────────────┤
│  Daily   │ Identity │  Builder │  Builder │   Project        │
│ Check-In │ Registry │   SBT    │ Staking  │  Verifier        │
│ (0.03)   │ (0.05)   │ (0.07)   │ (0.04)   │  (0.10)          │
├──────────┼──────────┴─────┬────┴──────────┼──────────────────┤
│ STX-USDC │  sBTC Bridge   │    Builder    │                  │
│  Swap    │   Escrow       │   Bounties    │                  │
│ (0.05)   │  (0.08)        │   (0.06)      │                  │
├──────────┴────────────────┴───────────────┴──────────────────┤
│                    🏦 Treasury Contract                       │
│      Consolidates all fees · Tracks user spend · Rewards     │
└──────────────────────────────────────────────────────────────┘
```

---

## 📜 Smart Contracts

| # | Contract | File | Fee (STX) | Description |
|---|----------|------|-----------|-------------|
| 1 | **Treasury** | `treasury.clar` | — | Central fee vault and spend tracker |
| 2 | **Daily Check-In** | `daily-check-in.clar` | 0.03 | 24h heartbeat with streak system |
| 3 | **Identity Registry** | `proof-of-builder.clar` | 0.05 | GitHub ↔ Stacks address mapping |
| 4 | **Builder SBT** | `builder-sbt.clar` | 0.07 | Non-transferable reputation NFT |
| 5 | **Staking** | `builder-staking.clar` | 0.04 | STX lock for commitment signal |
| 6 | **Verifier** | `project-verifier.clar` | 0.10 | Cross-project contribution proof |
| 7 | **STX-USDC Swap** | `stx-swap.clar` | 0.05 | OTC swap desk for builders |
| 8 | **sBTC Escrow** | `sbtc-escrow.clar` | 0.08 | Trustless BTC ↔ STX bridge |
| 9 | **Bounties** | `builder-bounties.clar` | 0.06 | Open-source bounty board |

---

## 🚀 Quick Start

### Prerequisites

- [Clarinet](https://docs.hiro.so/clarinet) installed
- [Leather Wallet](https://leather.io/) browser extension
- STX tokens for deployment and testing

### Local Development

```bash
# Clone the repository
git clone https://github.com/Earnwithalee7890/ProofOfBuilder.git
cd ProofOfBuilder

# Check all contracts compile
clarinet check

# Run interactive console
clarinet console
```

### Sandbox Testing

```clarity
;; In Clarinet console:

;; 1. Register as a builder
(contract-call? .proof-of-builder register-builder "your-github-username")

;; 2. Daily check-in
(contract-call? .daily-check-in check-in)

;; 3. Check your streak
(contract-call? .daily-check-in get-streak tx-sender)

;; 4. Mint your SBT
(contract-call? .builder-sbt mint-sbt)

;; 5. Stake 10 STX
(contract-call? .builder-staking stake-stx u10000000)

;; 6. Post a bounty (5 STX reward)
(contract-call? .builder-bounties post-bounty u5000000 "Fix the README typo")

;; 7. Create a swap order
(contract-call? .stx-swap create-sell-order u5000000 u1500000)

;; 8. Create sBTC escrow
(contract-call? .sbtc-escrow create-escrow u10000000 u500000)

;; 9. Check treasury totals
(contract-call? .treasury get-total-revenue)
(contract-call? .treasury get-total-spent tx-sender)
```

---

## 🏦 Fee Model & Revenue

All fees are routed to the **Treasury** contract. The treasury:

- **Tracks** every STX spent per user across all contracts
- **Accumulates** protocol revenue transparently on-chain
- **Distributes** rewards to top builders after each event period via `withdraw-for-rewards`

### Fee Breakdown

| Action | Fee | Where It Goes |
|--------|-----|---------------|
| Daily Check-in | 0.03 STX | Treasury |
| Register Identity | 0.05 STX | Treasury |
| Mint SBT | 0.07 STX | Treasury |
| Stake/Unstake | 0.04 STX | Treasury |
| Verify Builder | 0.10 STX | Treasury |
| Create Swap Order | 0.05 STX | Treasury |
| Create Escrow | 0.08 STX | Treasury |
| Post Bounty | 0.06 STX | Treasury |

---

## 🔐 Security

- **Post-Conditions**: All contract calls use Deny mode post-conditions to protect user funds
- **Authorization**: Only whitelisted contracts can record fees in the Treasury
- **Soulbound**: SBTs cannot be transferred — reputation is earned, not bought
- **Time-locks**: Escrows have built-in expiry periods
- **One-per-wallet**: SBT minting is limited to one token per address

---

## 📋 Deployment Order

When deploying to mainnet/testnet, deploy in this order:

1. `nft-trait.clar`
2. `treasury.clar`
3. `daily-check-in.clar`
4. `proof-of-builder.clar`
5. `builder-sbt.clar`
6. `builder-staking.clar`
7. `project-verifier.clar`
8. `stx-swap.clar`
9. `sbtc-escrow.clar`
10. `builder-bounties.clar`

**After deployment:** Call `treasury.set-authorized-contract` for each contract address.

---

## 🗺️ Roadmap

- [x] Core identity and reputation contracts
- [x] Treasury with fee consolidation
- [x] SBT (Soulbound Token) implementation
- [x] STX staking module
- [x] STX-USDC swap desk
- [x] sBTC bridge escrow
- [x] Builder bounty board
- [ ] Frontend with Leather wallet integration
- [ ] Leaderboard with real-time rankings
- [ ] sBTC token integration for escrow fills
- [ ] DAO governance for treasury decisions
- [ ] Cross-chain reputation bridging

---

## 🤝 Contributing

We welcome contributions from all Stacks builders! See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## 📄 License

MIT License — see [LICENSE](LICENSE) for details.

---

**Built for the Stacks Builder Rewards: February 2026** 🚀

*ProofOfBuilder is infrastructure for the Stacks ecosystem. If you're building on Bitcoin L2, your reputation should live on-chain.*
 
 # #   L i v e   D e p l o y m e n t  
 C o n t r a c t s   a r e   l i v e   o n   S t a c k s   M a i n n e t .  
 