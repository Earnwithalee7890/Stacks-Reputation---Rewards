# Paystream 🌊

**Paystream** is a decentralized protocol on Stacks for real-time payment streaming. It allows users to stream STX and SIP-010 tokens to recipients over time, enabling use cases like payroll, subscriptions, and vesting.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Stacks](https://img.shields.io/badge/stacks-2.1-purple.svg)

## Features

- **Create Stream**: Lock funds and set a duration for linear release.
- **Withdraw**: Recipients can withdraw vested funds at any time.
- **Cancel**: (Coming Soon) Senders can recover unvested funds.
- **SIP-010 Support**: Compatible with any standard Stacks token.

## Architecture

The project follows a standard Clarinet structure:

- `contracts/paystream.clar`: Core logic for stream management.
- `contracts/stream-token.clar`: Mock token for testing.
- `tests/paystream_test.ts`: Automated unit tests.
- `frontend/`: A lightweight dashboard for interacting with the protocol.

## Quick Start

1. Install [Clarinet](https://github.com/hirosystems/clarinet).
2. Run tests:
   ```bash
   clarinet test
   ```
3. Open `frontend/index.html` to view the UI.

## Contract Interface

### `create-stream`
Creates a new payment stream.
- **Args**: `recipient`, `amount`, `duration`
- **Returns**: `(ok stream-id)`

### `withdraw`
Claims available funds from a stream.
- **Args**: `stream-id`
- **Returns**: `(ok true)`

## License
MIT
