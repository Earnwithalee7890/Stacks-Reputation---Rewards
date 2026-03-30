# Deployment Guide 🚀

> Complete guide to deploying EarnWithAlee on Stacks Mainnet/Testnet

**Tags:** Stacks, Clarity, Bitcoin Layer 2

---

## Prerequisites

- Leather Wallet with STX for gas fees
- All contracts passing `clarinet check`
- Access to [Hiro Explorer Sandbox](https://explorer.hiro.so/sandbox)

## Deployment Order (Critical!)

Deploy in this exact sequence due to contract dependencies:

```
1. nft-trait.clar          → No dependencies
2. treasury.clar           → No dependencies
3. daily-check-in.clar     → Depends on treasury
4. proof-of-builder.clar   → Depends on treasury
5. builder-sbt.clar        → Depends on treasury + nft-trait
6. builder-staking.clar    → Depends on treasury
7. project-verifier.clar   → Depends on treasury
8. stx-swap.clar           → Depends on treasury
9. sbtc-escrow.clar        → Depends on treasury
10. builder-bounties.clar  → Depends on treasury
```

## Post-Deployment Authorization

**This is critical!** After all contracts are deployed, authorize each one in the Treasury:

```clarity
(contract-call? .treasury set-authorized-contract .daily-check-in true)
(contract-call? .treasury set-authorized-contract .proof-of-builder true)
(contract-call? .treasury set-authorized-contract .builder-sbt true)
(contract-call? .treasury set-authorized-contract .builder-staking true)
(contract-call? .treasury set-authorized-contract .project-verifier true)
(contract-call? .treasury set-authorized-contract .stx-swap true)
(contract-call? .treasury set-authorized-contract .sbtc-escrow true)
(contract-call? .treasury set-authorized-contract .builder-bounties true)
```

## Frontend Configuration

After deployment, update `index.html` line ~988:

```javascript
const DEPLOYER = 'YOUR_MAINNET_ADDRESS_HERE';
```

Replace with your actual deployed address (the address you used to deploy the contracts).

## Verification

After deployment, verify all contracts by calling their read-only functions:

```clarity
(contract-call? .treasury get-total-revenue)
(contract-call? .proof-of-builder get-total-builders)
(contract-call? .builder-sbt get-last-token-id)
(contract-call? .builder-staking get-total-staked)
(contract-call? .stx-swap get-next-order-id)
(contract-call? .sbtc-escrow get-next-escrow-id)
(contract-call? .builder-bounties get-next-bounty-id)
```

---

*See [SANDBOX_GUIDE.md](SANDBOX_GUIDE.md) for complete testing instructions.*
