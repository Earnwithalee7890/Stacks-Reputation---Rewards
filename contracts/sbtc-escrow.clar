;; Title: sBTC Bridge Escrow
;; Description: Escrow contract for sBTC <-> STX trustless swaps on Bitcoin L2
;; Tags: Stacks, Clarity, Bitcoin Layer 2, sBTC, Escrow, Bridge
;; Fee: 0.08 STX per escrow creation
;; Network: Stacks Mainnet
;; Clarity Version: 2
;;
;; Use Case:
;; - User A locks STX in escrow, specifying how much sBTC they want in return
;; - User B fills the escrow by providing sBTC (future integration)
;; - For now, this works as a trustless STX escrow with time-lock
;; - After expiry, creator can reclaim their STX

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_ALREADY_FILLED (err u102))
(define-constant ERR_NOT_EXPIRED (err u103))
(define-constant ERR_EXPIRED (err u104))
(define-constant ESCROW_FEE u80000) ;; 0.08 STX
(define-constant ESCROW_DURATION u720) ;; ~5 days

(define-data-var next-escrow-id uint u1)

(define-map Escrows
  uint
  {
    creator: principal,
    stx-locked: uint,
    sbtc-requested: uint,
    counterparty: (optional principal),
    created-at: uint,
    status: (string-ascii 10)
  }
)

;; @desc Create an escrow requesting sBTC for locked STX
(define-public (create-escrow (stx-amount uint) (sbtc-wanted uint))
  (let (
    (id (var-get next-escrow-id))
  )
    (asserts! (> stx-amount u0) (err u105))
    ;; Fee to treasury
    (try! (stx-transfer? ESCROW_FEE tx-sender .EarnWithAlee-Treasury))
    (try! (contract-call? .EarnWithAlee-Treasury record-fee tx-sender ESCROW_FEE))
    ;; Lock STX
    (try! (stx-transfer? stx-amount tx-sender (as-contract tx-sender)))
    (map-set Escrows id {
      creator: tx-sender,
      stx-locked: stx-amount,
      sbtc-requested: sbtc-wanted,
      counterparty: none,
      created-at: stacks-block-height,
      status: "open"
    })
    (var-set next-escrow-id (+ id u1))
    (print {action: "escrow-created", id: id, creator: tx-sender, stx: stx-amount, sbtc: sbtc-wanted})
    (ok id)
  )
)

;; @desc Reclaim STX from expired escrow
(define-public (reclaim-escrow (escrow-id uint))
  (let (
    (escrow (unwrap! (map-get? Escrows escrow-id) ERR_NOT_FOUND))
  )
    (asserts! (is-eq (get creator escrow) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status escrow) "open") ERR_ALREADY_FILLED)
    (asserts! (>= stacks-block-height (+ (get created-at escrow) ESCROW_DURATION)) ERR_NOT_EXPIRED)
    (try! (as-contract (stx-transfer? (get stx-locked escrow) (as-contract tx-sender) tx-sender)))
    (map-set Escrows escrow-id (merge escrow { status: "reclaimed" }))
    (print {action: "escrow-reclaimed", id: escrow-id})
    (ok true)
  )
)

;; Read-only
(define-read-only (get-escrow (escrow-id uint))
  (map-get? Escrows escrow-id)
)

(define-read-only (get-next-escrow-id)
  (var-get next-escrow-id)
)

;; Incremental refinement pass 12
