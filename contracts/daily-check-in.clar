;; Title: Daily Check-in Contract
;; Description: 24-hour enforced on-chain heartbeat for builder reputation
;; Tags: Stacks, Clarity, Bitcoin Layer 2, Reputation
;; Fee: 0.03 STX per check-in
;; Network: Stacks Mainnet
;; Clarity Version: 2

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_CHECKED_IN (err u101))
(define-constant CHECK_IN_FEE u30000) ;; 0.03 STX
(define-constant DAY_IN_BLOCKS u144) ;; ~24 hours on Stacks

(define-map LastCheckIn principal uint)
(define-map CheckInCount principal uint)
(define-map CheckInStreak principal uint)

;; @desc Perform daily check-in (24h cooldown enforced)
(define-public (check-in)
  (let (
    (last-block (default-to u0 (map-get? LastCheckIn tx-sender)))
    (current-count (default-to u0 (map-get? CheckInCount tx-sender)))
    (current-streak (default-to u0 (map-get? CheckInStreak tx-sender)))
    (blocks-since (- stacks-block-height last-block))
  )
    ;; Enforce 24h cooldown
    (asserts! (or (is-eq last-block u0) (>= stacks-block-height (+ last-block DAY_IN_BLOCKS))) ERR_ALREADY_CHECKED_IN)
    ;; Send fee to treasury
    (try! (stx-transfer? CHECK_IN_FEE tx-sender .treasury))
    (try! (contract-call? .treasury record-fee tx-sender CHECK_IN_FEE))
    ;; Update streak: reset if missed >2 days, otherwise increment
    (if (and (> last-block u0) (> blocks-since (* u2 DAY_IN_BLOCKS)))
      (map-set CheckInStreak tx-sender u1)
      (map-set CheckInStreak tx-sender (+ current-streak u1))
    )
    (map-set LastCheckIn tx-sender stacks-block-height)
    (map-set CheckInCount tx-sender (+ current-count u1))
    (print {action: "check-in", user: tx-sender, block: stacks-block-height, count: (+ current-count u1), streak: (+ current-streak u1)})
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-last-check-in (user principal))
  (map-get? LastCheckIn user)
)

(define-read-only (get-check-in-count (user principal))
  (default-to u0 (map-get? CheckInCount user))
)

(define-read-only (get-streak (user principal))
  (default-to u0 (map-get? CheckInStreak user))
)

(define-read-only (can-check-in (user principal))
  (let (
    (last-block (default-to u0 (map-get? LastCheckIn user)))
  )
    (or (is-eq last-block u0) (>= stacks-block-height (+ last-block DAY_IN_BLOCKS)))
  )
)
