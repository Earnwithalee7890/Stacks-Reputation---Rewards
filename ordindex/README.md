# Ordindex 📜

**Ordindex** is a decentralized registry and indexer for Bitcoin Ordinals, built on Stacks. It provides a trustless mapping between Bitcoin Inscription IDs and Stacks principals, enabling truly decentralized ownership verification for dApps.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Stacks](https://img.shields.io/badge/stacks-2.1-purple.svg)

## Features

- **Decentralized Registry**: Map any Bitcoin Inscription ID to a Stacks address.
- **On-Chain Verification**: Verify ownership without relying on centralized indexers like Ordinals.com.
- **Metadata Support**: Attach immutable metadata strings to your inscriptions.

## Project Structure

- `contracts/ordindex.clar`: The core registry smart contract.
- `src/indexer.ts`: (Mock) TypeScript indexer that listens to Bitcoin nodes.
- `index.html`: Web interface for searching and registering inscriptions.

## Quick Start

1. **Install Dependencies**:
   ```bash
   npm install
   ```

2. **Run Tests**:
   ```bash
   clarinet test
   ```

3. **Start Frontend**:
   Open `index.html` in your browser.

## Contract Interface

### `register-inscription`
Registers an inscription to the sender.
- **Args**: `inscription-id` (buff 64), `metadata` (string-utf8 256)
- **Returns**: `(ok true)`

### `get-inscription-owner`
Look up the owner of an ID.
- **Args**: `inscription-id`
- **Returns**: `(some { owner: principal, ... })`

## License
MIT
