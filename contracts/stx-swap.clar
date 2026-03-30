;; Title: STX-USDC Micro Swap
;; Description: Simple on-chain STX/USDC OTC swap desk for builders
;; Tags: Stacks, Clarity, Bitcoin Layer 2, DeFi, Swap, USDC
;; Fee: 0.05 STX per swap order
;; Network: Stacks Mainnet
;; Clarity Version: 2
;;
;; How it works:
;; - Sellers list STX at a price (in micro-USDC per STX)
;; - Buyers fill orders by sending USDC and receiving STX
;; - Protocol takes 0.05 STX listing fee (sent to treasury)
;; - Uses SIP-010 USDC token on Stacks

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_INSUFFICIENT (err u102))
(define-constant ERR_EXPIRED (err u103))
(define-constant LISTING_FEE u50000) ;; 0.05 STX
(define-constant ORDER_EXPIRY u1008) ;; ~7 days in blocks

(define-data-var next-order-id uint u1)
(define-data-var total-volume uint u0)

(define-map SwapOrders
  uint
  {
    seller: principal,
    stx-amount: uint,
    price-per-stx: uint,
    created-at: uint,
    filled: bool
  }
)

;; @desc Create a sell order for STX
(define-public (create-sell-order (stx-amount uint) (price-per-stx uint))
  (let (
    (order-id (var-get next-order-id))
  )
    (asserts! (> stx-amount u0) ERR_INSUFFICIENT)
    ;; Listing fee to treasury
    (try! (stx-transfer? LISTING_FEE tx-sender .EarnWithAlee-Treasury))
    (try! (contract-call? .EarnWithAlee-Treasury record-fee tx-sender LISTING_FEE))
    ;; Lock the STX in the contract
    (try! (stx-transfer? stx-amount tx-sender (as-contract tx-sender)))
    (map-set SwapOrders order-id {
      seller: tx-sender,
      stx-amount: stx-amount,
      price-per-stx: price-per-stx,
      created-at: stacks-block-height,
      filled: false
    })
    (var-set next-order-id (+ order-id u1))
    (print {action: "create-order", id: order-id, seller: tx-sender, stx-amount: stx-amount, price: price-per-stx})
    (ok order-id)
  )
)

;; @desc Cancel an unfilled order and reclaim STX
(define-public (cancel-order (order-id uint))
  (let (
    (order (unwrap! (map-get? SwapOrders order-id) ERR_NOT_FOUND))
  )
    (asserts! (is-eq (get seller order) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (not (get filled order)) ERR_NOT_FOUND)
    (try! (as-contract (stx-transfer? (get stx-amount order) (as-contract tx-sender) tx-sender)))
    (map-set SwapOrders order-id (merge order { filled: true }))
    (print {action: "cancel-order", id: order-id})
    (ok true)
  )
)

;; Read-only
(define-read-only (get-order (order-id uint))
  (map-get? SwapOrders order-id)
)

(define-read-only (get-next-order-id)
  (var-get next-order-id)
)

(define-read-only (get-total-volume)
  (var-get total-volume)
)

;; Incremental refinement pass 13
