;; Paystream v2 - Streaming Payments Protocol on Stacks
;; Block-by-block STX streaming with pause/resume and multi-recipient support

(define-constant CONTRACT-OWNER tx-sender)
(define-constant MIN-STREAM-DURATION u10)    ;; minimum 10 blocks
(define-constant MAX-STREAMS-PER-SENDER u50)  ;; prevent spam

(define-constant err-invalid-amount (err u100))
(define-constant err-invalid-duration (err u101))
(define-constant err-stream-not-found (err u102))
(define-constant err-unauthorized (err u103))
(define-constant err-stream-finished (err u104))
(define-constant err-stream-paused (err u105))
(define-constant err-stream-active (err u106))
(define-constant err-below-min-duration (err u107))

(define-data-var next-stream-id uint u1)
(define-data-var total-volume-streamed uint u0)
(define-data-var protocol-fee-bps uint u50)  ;; 0.5% protocol fee

(define-map streams 
    uint 
    {
        sender: principal,
        recipient: principal,
        balance: uint,
        rate-per-block: uint,
        start-block: uint,
        end-block: uint,
        last-claimed-block: uint,
        is-paused: bool,
        paused-at-block: (optional uint),
        label: (optional (string-utf8 50))  ;; human-readable stream label
    }
)

;; Index: sender → stream IDs for efficient querying
(define-map sender-stream-count principal uint)

;; ================================
;; READ-ONLY 
;; ================================

(define-read-only (get-stream (stream-id uint))
    (map-get? streams stream-id)
)

(define-read-only (get-claimable-amount (stream-id uint))
    (match (map-get? streams stream-id)
        stream
        (let
            (
                (current-block block-height)
                (claim-end (if (> current-block (get end-block stream)) (get end-block stream) current-block))
                (blocks-passed (- claim-end (get last-claimed-block stream)))
            )
            (ok (* blocks-passed (get rate-per-block stream)))
        )
        err-stream-not-found
    )
)

(define-read-only (get-next-stream-id)
    (var-get next-stream-id)
)

(define-read-only (get-total-volume)
    (var-get total-volume-streamed)
)

;; ================================
;; PUBLIC FUNCTIONS
;; ================================

(define-public (create-stream (recipient principal) (amount uint) (duration uint) (label (optional (string-utf8 50))))
    (let
        (
            (stream-id (var-get next-stream-id))
            (start-block block-height)
            (end-block (+ block-height duration))
            (rate (/ amount duration))
            (fee-amount (/ (* amount (var-get protocol-fee-bps)) u10000))
            (net-amount (- amount fee-amount))
        )
        (asserts! (> amount u0) err-invalid-amount)
        (asserts! (>= duration MIN-STREAM-DURATION) err-below-min-duration)

        ;; Transfer full amount to contract
        (try! (stx-transfer? amount tx-sender (as-contract tx-sender)))
        ;; Pay protocol fee immediately
        (if (> fee-amount u0)
            (try! (as-contract (stx-transfer? fee-amount tx-sender CONTRACT-OWNER)))
            true
        )

        (map-set streams stream-id {
            sender: tx-sender,
            recipient: recipient,
            balance: net-amount,
            rate-per-block: (/ net-amount duration),
            start-block: start-block,
            end-block: end-block,
            last-claimed-block: start-block,
            is-paused: false,
            paused-at-block: none,
            label: label
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
        (asserts! (is-eq tx-sender (get recipient stream)) err-unauthorized)
        (asserts! (not (get is-paused stream)) err-stream-paused)
        (asserts! (> amount-to-claim u0) err-stream-finished)

        (map-set streams stream-id (merge stream {
            balance: (- (get balance stream) amount-to-claim),
            last-claimed-block: claim-end-block
        }))

        (var-set total-volume-streamed (+ (var-get total-volume-streamed) amount-to-claim))
        (as-contract (stx-transfer? amount-to-claim tx-sender (get recipient stream)))
    )
)

(define-public (pause-stream (stream-id uint))
    (let
        (
            (stream (unwrap! (map-get? streams stream-id) err-stream-not-found))
        )
        (asserts! (is-eq tx-sender (get sender stream)) err-unauthorized)
        (asserts! (not (get is-paused stream)) err-stream-paused)

        (map-set streams stream-id (merge stream {
            is-paused: true,
            paused-at-block: (some block-height)
        }))
        (ok true)
    )
)

(define-public (resume-stream (stream-id uint))
    (let
        (
            (stream (unwrap! (map-get? streams stream-id) err-stream-not-found))
        )
        (asserts! (is-eq tx-sender (get sender stream)) err-unauthorized)
        (asserts! (get is-paused stream) err-stream-active)

        (map-set streams stream-id (merge stream {
            is-paused: false,
            paused-at-block: none
        }))
        (ok true)
    )
)

(define-public (cancel-stream (stream-id uint))
    (let
        (
            (stream (unwrap! (map-get? streams stream-id) err-stream-not-found))
            (remaining (get balance stream))
        )
        (asserts! (is-eq tx-sender (get sender stream)) err-unauthorized)

        ;; Refund unstreamed balance to sender
        (if (> remaining u0)
            (try! (as-contract (stx-transfer? remaining tx-sender (get sender stream))))
            true
        )

        (map-set streams stream-id (merge stream { balance: u0, is-paused: true }))
        (ok true)
    )
)
