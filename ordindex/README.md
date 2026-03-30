# OrdIndex v2 — Bitcoin Ordinal Accumulator

## Overview
A specialized Stacks contract for indexing Bitcoin Ordinal Inscriptions and organizing them into collections. Version 2 adds robust collection management and automatic supply tracking.

## Features
- 📚 **Collection Management** — Create named collections with on-chain supply counters.
- 🔗 **Inscription Linking** — Register ordinals and link them to collections.
- 📉 **Supply Tracking** — Automatically increments/decrements collection supply on registration/removal.
- 🔍 **Metadata Pointer** — Stores IPFS/Arweave URIs for off-chain metadata.
- 🗑️ **Admin Removal** — Contract owner can delist invalid inscriptions.

## Contract Functions

| Function | Description |
|----------|-------------|
| `create-collection` | Create a new collection (returns ID) |
| `register-ordinal` | Index an inscription and link to collection |
| `transfer-ordinal` | Update owner of registered ordinal |
| `remove-ordinal` | Admin: delete ordinal and decrement supply |
| `get-ordinal` | Read-only: get metadata and owner |
| `get-collection` | Read-only: get name and total supply |

## License
MIT
