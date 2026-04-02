# 🤝 Talent Protocol Integration Guide

EarnWithAlee is fully integrated with Talent Protocol for the Stacks Builder Rewards April 2026 event.

## Verification Tags
The project is verified using the following meta tag in `index.html`:
```html
<meta name="talentapp:project_verification" content="081a3719b768547de8608f4bcab2b837f7e71c66d1a40294a08672103e88d724c711c3fba6345ccb96fd414e482ebfb8328e711becf16653474568f947f518f7">
```

## Reputation Syncing
We use the `event-logger` contract to emit builder activities:
1. **GitHub Registration**: Logged when `register-builder` is called.
2. **Daily Check-ins**: Tracks activity streaks on-chain.
3. **SBT Minting**: Proof of reputation earned.

## How to Verify Your Builder Status
1. Connect your Stacks wallet (Leather or Xverse).
2. Register your GitHub handle in the Identity Registry.
3. Perform your first Daily Check-in.
4. Your reputation will automatically begin building toward the next SBT tier.

## Talent Protocol Details
- **Project ID**: EarnWithAlee
- **Network**: Stacks Mainnet
- **Event**: April 2026 Builder Challenge
