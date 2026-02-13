;; Title: ProofOfBuilder Treasury
;; Description: Central vault collecting all protocol fees and tracking user spend for rewards
;; Tags: Stacks, Clarity, Bitcoin Layer 2, DeFi Treasury
;; Network: Stacks Mainnet
;; Clarity Version: 2

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))

;; Track total fees spent by each user across the ecosystem
(define-map TotalSpent principal uint)
;; Only authorized contracts can record fees
(define-map AuthorizedContracts principal bool)
;; Total protocol revenue counter
(define-data-var total-revenue uint u0)

;; @desc Authorize a contract to record fees (Owner Only)
(define-public (set-authorized-contract (contract principal) (authorized bool))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (ok (map-set AuthorizedContracts contract authorized))
  )
)

;; @desc Record fee from an authorized contract
(define-public (record-fee (user principal) (amount uint))
  (let (
    (current-total (default-to u0 (map-get? TotalSpent user)))
  )
    (asserts! (default-to false (map-get? AuthorizedContracts contract-caller)) ERR_UNAUTHORIZED)
    (var-set total-revenue (+ (var-get total-revenue) amount))
    (map-set TotalSpent user (+ current-total amount))
    (print {action: "record-fee", user: user, amount: amount, total: (+ current-total amount)})
    (ok true)
  )
)

;; @desc Distribute rewards to top builders (Owner Only)
(define-public (withdraw-for-rewards (amount uint) (recipient principal))
  (begin
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (try! (as-contract (stx-transfer? amount (as-contract tx-sender) recipient)))
    (print {action: "reward-sent", recipient: recipient, amount: amount})
    (ok true)
  )
)

;; Read-only functions
(define-read-only (get-total-spent (user principal))
  (default-to u0 (map-get? TotalSpent user))
)

(define-read-only (is-authorized (contract principal))
  (default-to false (map-get? AuthorizedContracts contract))
)

(define-read-only (get-total-revenue)
  (var-get total-revenue)
)
