;; Ordindex - Bitcoin Ordinals Registry
;; Maps Bitcoin Inscription IDs to Stacks Principals

(define-constant err-inscription-already-registered (err u100))
(define-constant err-not-found (err u101))

(define-map registry 
    (buff 64) ;; Inscription ID (hash)
    {
        owner: principal,
        registered-at: uint,
        metadata: (string-utf8 256)
    }
)

(define-read-only (get-inscription-owner (inscription-id (buff 64)))
    (map-get? registry inscription-id)
)

(define-public (register-inscription (inscription-id (buff 64)) (metadata (string-utf8 256)))
    (begin
        (asserts! (is-none (map-get? registry inscription-id)) err-inscription-already-registered)
        
        (map-set registry inscription-id {
            owner: tx-sender,
            registered-at: block-height,
            metadata: metadata
        })
        
        (ok true)
    )
)
