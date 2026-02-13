;; Title: Proof Of Builder Registry
;; Description: On-chain identity linking GitHub profiles to Stacks addresses
;; Tags: Stacks, Clarity, Bitcoin Layer 2, Identity, DID
;; Fee: 0.05 STX per registration
;; Network: Stacks Mainnet
;; Clarity Version: 2

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_ALREADY_REGISTERED (err u101))
(define-constant ERR_NOT_FOUND (err u404))
(define-constant REGISTRATION_FEE u50000) ;; 0.05 STX

(define-map BuilderProfiles
  principal
  {
    github: (string-ascii 40),
    reputation: uint,
    joined-at: uint,
    verified: bool
  }
)

(define-data-var total-builders uint u0)

;; @desc Register as a builder with your GitHub handle
(define-public (register-builder (github-handle (string-ascii 40)))
  (begin
    (asserts! (is-none (map-get? BuilderProfiles tx-sender)) ERR_ALREADY_REGISTERED)
    (try! (stx-transfer? REGISTRATION_FEE tx-sender .treasury))
    (try! (contract-call? .treasury record-fee tx-sender REGISTRATION_FEE))
    (map-set BuilderProfiles tx-sender {
      github: github-handle,
      reputation: u0,
      joined-at: stacks-block-height,
      verified: false
    })
    (var-set total-builders (+ (var-get total-builders) u1))
    (print {action: "register", user: tx-sender, github: github-handle})
    (ok true)
  )
)

;; @desc Update reputation score (Owner or authorized contract only)
(define-public (update-reputation (builder principal) (points uint) (add bool))
  (let (
    (profile (unwrap! (map-get? BuilderProfiles builder) ERR_NOT_FOUND))
  )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set BuilderProfiles builder
      (merge profile {
        reputation: (if add
          (+ (get reputation profile) points)
          (if (>= (get reputation profile) points)
            (- (get reputation profile) points)
            u0))
      })
    )
    (print {action: "reputation-update", builder: builder, points: points, add: add})
    (ok true)
  )
)

;; @desc Verify a builder (Owner only)
(define-public (verify-builder-profile (builder principal))
  (let (
    (profile (unwrap! (map-get? BuilderProfiles builder) ERR_NOT_FOUND))
  )
    (asserts! (is-eq tx-sender CONTRACT_OWNER) ERR_UNAUTHORIZED)
    (map-set BuilderProfiles builder (merge profile { verified: true }))
    (ok true)
  )
)

;; Read-only
(define-read-only (get-builder (builder principal))
  (map-get? BuilderProfiles builder)
)

(define-read-only (get-total-builders)
  (var-get total-builders)
)
