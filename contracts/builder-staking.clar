;; Title: Builder Staking Module
;; Description: Stake STX to signal long-term commitment to the Stacks ecosystem
;; Tags: Stacks, Clarity, Bitcoin Layer 2, Staking, DeFi
;; Fee: 0.04 STX per stake/unstake action
;; Network: Stacks Mainnet
;; Clarity Version: 2

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_INSUFFICIENT (err u101))
(define-constant ERR_MIN_STAKE (err u102))
(define-constant STAKE_ACTION_FEE u40000) ;; 0.04 STX
(define-constant MIN_STAKE u1000000) ;; 1 STX minimum

(define-map StakedBalances principal uint)
(define-map StakeTimestamp principal uint)
(define-data-var total-staked uint u0)

;; @desc Stake STX (action fee sent to treasury, stake locked in contract)
(define-public (stake-stx (amount uint))
  (let (
    (current-stake (default-to u0 (map-get? StakedBalances tx-sender)))
  )
    (asserts! (>= amount MIN_STAKE) ERR_MIN_STAKE)
    (try! (stx-transfer? STAKE_ACTION_FEE tx-sender .treasury))
    (try! (contract-call? .treasury record-fee tx-sender STAKE_ACTION_FEE))
    (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
    (map-set StakedBalances tx-sender (+ current-stake amount))
    (map-set StakeTimestamp tx-sender stacks-block-height)
    (var-set total-staked (+ (var-get total-staked) amount))
    (print {action: "stake", user: tx-sender, amount: amount, total: (+ current-stake amount)})
    (ok true)
  )
)

;; @desc Unstake STX
(define-public (unstake-stx (amount uint))
  (let (
    (current-stake (default-to u0 (map-get? StakedBalances tx-sender)))
  )
    (asserts! (>= current-stake amount) ERR_INSUFFICIENT)
    (try! (stx-transfer? STAKE_ACTION_FEE tx-sender .treasury))
    (try! (contract-call? .treasury record-fee tx-sender STAKE_ACTION_FEE))
    (try! (as-contract (stx-transfer? amount (as-contract tx-sender) tx-sender)))
    (map-set StakedBalances tx-sender (- current-stake amount))
    (var-set total-staked (- (var-get total-staked) amount))
    (print {action: "unstake", user: tx-sender, amount: amount})
    (ok true)
  )
)

;; Read-only
(define-read-only (get-stake (user principal))
  (default-to u0 (map-get? StakedBalances user))
)

(define-read-only (get-stake-time (user principal))
  (map-get? StakeTimestamp user)
)

(define-read-only (get-total-staked)
  (var-get total-staked)
)
