# Paystream — Block-by-Block STX Streaming Protocol

## Overview
**Paystream** brings programmable payment streaming to the Stacks blockchain. Instead of lump-sum transfers, senders can define a **flow rate (STX per block)** that recipients withdraw continuously — perfect for salaries, subscriptions, and vesting.

## Why Paystream?
- 🌊 **Real-time Payroll** — Pay contributors per block, not per month
- 🔐 **Trustless Escrow** — STX is locked in the contract; no custodians
- ⏸️ **Pause & Resume** — Senders can pause streams without losing funds
- ❌ **Cancel & Refund** — Unstreamed balance always recoverable by sender
- 🏷️ **Stream Labels** — Tag streams with human-readable descriptions
- 💸 **0.5% Protocol Fee** — Minimal infrastructure fee on stream creation

## Contract Architecture

```
paystream.clar
├── create-stream()     → Lock STX, define recipient + flow rate + label
├── withdraw()          → Recipient claims elapsed blocks × rate
├── pause-stream()      → Sender halts block accumulation
├── resume-stream()     → Sender restarts accumulation
├── cancel-stream()     → Sender cancels; unstreamed balance refunded
└── get-claimable-amount() → Read-only: preview withdrawable STX
```

## Stream Formula
```
Rate = net_amount / duration_in_blocks
Claimable = (current_block - last_claimed_block) × rate
```

## Error Codes

| Code | Meaning |
|------|---------|
| u100 | Amount must be > 0 |
| u101 | Duration below minimum (10 blocks) |
| u102 | Stream not found |
| u103 | Unauthorized caller |
| u104 | Stream has no claimable amount |
| u105 | Stream is paused |
| u106 | Stream is already active |
| u107 | Duration below minimum blocks |

## Example

```clarity
;; Create a 30-day salary stream (4320 blocks @ ~10 min/block)
(contract-call? .paystream create-stream
    'SP2RECIPIENT...
    u100000000          ;; 100 STX
    u4320               ;; ~30 days
    (some u"Dev Salary March 2025"))

;; Recipient withdraws on payday
(contract-call? .paystream withdraw u1)
```

## License
MIT
