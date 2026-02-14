;; Paystream - Streaming Payments Contract
;; Allows users to stream STX or tokens to a recipient over time

(define-constant err-invalid-amount (err u100))
(define-constant err-invalid-duration (err u101))
(define-constant err-stream-not-found (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-stream-finished (err u104))

(define-data-var next-stream-id uint u1)

(define-map streams 
    uint 
    {
        sender: principal,
        recipient: principal,
        balance: uint,
        rate-per-block: uint,
        start-block: uint,
        end-block: uint,
        last-claimed-block: uint
    }
)

(define-read-only (get-stream (stream-id uint))
    (map-get? streams stream-id)
)

(define-public (create-stream (recipient principal) (amount uint) (duration uint))
    (let
        (
            (stream-id (var-get next-stream-id))
            (start-block block-height)
            (end-block (+ block-height duration))
            (rate (/ amount duration))
        )
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (> duration u0) err-invalid-duration)
        
        ;; Transfer STX from sender to contract
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))

        ;; Create stream record
        (map-set streams stream-id {
            sender: tx-sender,
            recipient: recipient,
            balance: amount,
            rate-per-block: rate,
            start-block: start-block,
            end-block: end-block,
            last-claimed-block: start-block
        })

        (var-set next-stream-id (+ stream-id u1))
        (ok stream-id)
    )
)

(define-public (withdraw (stream-id uint))
    (let
        (
            (stream (unwrap! (map-get? streams stream-id) err-stream-not-found))
            (current-block block-height)
            (claim-end-block (if (> current-block (get end-block stream)) (get end-block stream) current-block))
            (blocks-passed (- claim-end-block (get last-claimed-block stream)))
            (amount-to-claim (* blocks-passed (get rate-per-block stream)))
        )
        (asserts! (or (is-eq tx-sender (get recipient stream)) (is-eq tx-sender (get sender stream))) err-unauthorized)
        (asserts! (> amount-to-claim u0) err-stream-finished)

        ;; Update stream state
        (map-set streams stream-id (merge stream {
            balance: (- (get balance stream) amount-to-claim),
            last-claimed-block: claim-end-block
        }))

        ;; Transfer claimed funds to recipient
        (as-contract (stx-transfer? amount-to-claim tx-sender (get recipient stream)))
    )
)
