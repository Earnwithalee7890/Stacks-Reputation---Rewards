;; Title: Project Verifier
;; Description: On-chain verification of builder contributions by projects
;; Tags: Stacks, Clarity, Bitcoin Layer 2, Verification, Credentials
;; Fee: 0.10 STX per verification
;; Network: Stacks Mainnet
;; Clarity Version: 2

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant VERIFICATION_FEE u100000) ;; 0.10 STX

(define-map Verifications {project: principal, builder: principal} bool)
(define-data-var total-verifications uint u0)

;; @desc Verify a builder's contribution on-chain
(define-public (verify-builder (builder principal))
  (begin
    (try! (stx-transfer? VERIFICATION_FEE tx-sender .treasury))
    (try! (contract-call? .treasury record-fee tx-sender VERIFICATION_FEE))
    (map-set Verifications {project: tx-sender, builder: builder} true)
    (var-set total-verifications (+ (var-get total-verifications) u1))
    (print {action: "verify", project: tx-sender, builder: builder})
    (ok true)
  )
)

;; @desc Revoke a verification
(define-public (revoke-verification (builder principal))
  (begin
    (map-delete Verifications {project: tx-sender, builder: builder})
    (print {action: "revoke", project: tx-sender, builder: builder})
    (ok true)
  )
)

;; Read-only
(define-read-only (is-verified (project principal) (builder principal))
  (default-to false (map-get? Verifications {project: project, builder: builder}))
)

(define-read-only (get-total-verifications)
  (var-get total-verifications)
)
