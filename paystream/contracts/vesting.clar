;; Vesting Contract
;; Allows linear vesting of tokens for team members or advisors

(define-constant err-not-owner (err u100))
(define-constant err-no-tokens (err u101))

(define-data-var vesting-start-block uint u0)

(define-map schedules
    principal
    {
        total-amount: uint,
        claimed-amount: uint,
        duration-blocks: uint
    }
)

(define-public (set-schedule (beneficiary principal) (amount uint) (duration uint))
    (begin
        (map-set schedules beneficiary {
            total-amount: amount,
            claimed-amount: u0,
            duration-blocks: duration
        })
        (ok true)
    )
)

(define-public (claim)
    (let
        (
            (schedule (unwrap! (map-get? schedules tx-sender) err-no-tokens))
            (vested (calculate-vested (get total-amount schedule) (get duration-blocks schedule)))
            (claimable (- vested (get claimed-amount schedule)))
        )
        (asserts! (> claimable u0) err-no-tokens)
        
        (map-set schedules tx-sender (merge schedule {
            claimed-amount: (+ (get claimed-amount schedule) claimable)
        }))
        
        (as-contract (stx-transfer? claimable tx-sender tx-sender))
    )
)

(define-read-only (calculate-vested (total uint) (duration uint))
    (if (>= block-height (+ (var-get vesting-start-block) duration))
        total
        (/ (* total (- block-height (var-get vesting-start-block))) duration)
    )
)
