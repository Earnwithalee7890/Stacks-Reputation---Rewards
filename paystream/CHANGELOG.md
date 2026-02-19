# CHANGELOG — Paystream

All notable changes to this protocol are documented here.

## [2.0.0] — 2026-02-19

### Added
- `pause-stream`: Sender can halt accumulation without losing funds
- `resume-stream`: Sender can restart a previously paused stream
- `cancel-stream`: Sender cancels open stream and recovers unstreamed balance
- `get-claimable-amount`: Read-only preview of withdrawable STX for any stream
- `label` field on streams: optional (string-utf8 50) human-readable name
- Protocol fee (50 BPS = 0.5%) charged on stream creation, routed to contract owner
- `total-volume-streamed` accumulator for on-chain analytics
- `MIN-STREAM-DURATION` constant (10 blocks) prevents dust spam streams

### Changed
- `create-stream` now accepts 4 arguments (added `label`)
- Stream struct expanded with `is-paused`, `paused-at-block`, `label`
- Stream ID counter now starts at `u1` (was implicitly 0)

### Fixed
- Unauthorized callers can no longer call `withdraw` as sender
- Streams with 0 claimable amount now correctly return err-stream-finished

---

## [1.0.0] — 2026-02-01

### Added
- Initial `create-stream`, `withdraw`, `get-stream` functions
- Block-based streaming rate calculation
- STX locking and release via `as-contract`
