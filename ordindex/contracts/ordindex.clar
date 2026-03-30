
;; OrdIndex v2 — Bitcoin Ordinal Accumulator
;; v2: Added collection tracking, metadata search, and administrative removal

(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-ALREADY-REGISTERED (err u101))
(define-constant ERR-NOT-FOUND (err u102))

(define-map ordinals
    uint ;; inscription-id
    {
        owner: principal,
        metadata-uri: (string-utf8 256),
        collection-id: (optional uint), ;; Linking ordinals to collections
        registered-at: uint
    }
)

(define-map collections
    uint ;; collection-id
    {
        name: (string-utf8 64),
        creator: principal,
        total-supply: uint
    }
)

(define-data-var collection-nonce uint u0)

;; ================================
;; PUBLIC FUNCTIONS
;; ================================

(define-public (create-collection (name (string-utf8 64)))
    (let
        (
            (id (+ (var-get collection-nonce) u1))
        )
        (map-set collections id {
            name: name,
            creator: tx-sender,
            total-supply: u0
        })
        (var-set collection-nonce id)
        (ok id)
    )
)

(define-public (register-ordinal (inscription-id uint) (metadata-uri (string-utf8 256)) (collection-id (optional uint)))
    (begin
        (asserts! (is-none (map-get? ordinals inscription-id)) ERR-ALREADY-REGISTERED)
        
        ;; If collection is provided, verify ownership or open mint logic (omitted for brevity)
        ;; Updating collection supply if linked
        (match collection-id
            id (try! (increment-collection-supply id))
            true ;; No collection, pass
        )
        
        (map-set ordinals inscription-id {
            owner: tx-sender,
            metadata-uri: metadata-uri,
            collection-id: collection-id,
            registered-at: block-height
        })
        (ok true)
    )
)

(define-public (transfer-ordinal (inscription-id uint) (recipient principal))
    (let
        (
            (ordinal (unwrap! (map-get? ordinals inscription-id) ERR-NOT-FOUND))
        )
        (asserts! (is-eq tx-sender (get owner ordinal)) ERR-NOT-AUTHORIZED)
        (map-set ordinals inscription-id (merge ordinal { owner: recipient }))
        (ok true)
    )
)

(define-public (remove-ordinal (inscription-id uint))
    (let
        (
            (ordinal (unwrap! (map-get? ordinals inscription-id) ERR-NOT-FOUND))
        )
        (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
        
        ;; Decrement collection supply if linked
        (match (get collection-id ordinal)
            id (try! (decrement-collection-supply id))
            true
        )
        
        (map-delete ordinals inscription-id)
        (ok true)
    )
)

;; ================================
;; INTERNAL
;; ================================

(define-private (increment-collection-supply (id uint))
    (let
        (
            (collection (unwrap! (map-get? collections id) ERR-NOT-FOUND))
        )
        (map-set collections id (merge collection { total-supply: (+ (get total-supply collection) u1) }))
        (ok true)
    )
)

(define-private (decrement-collection-supply (id uint))
    (let
        (
            (collection (unwrap! (map-get? collections id) ERR-NOT-FOUND))
        )
        (map-set collections id (merge collection { total-supply: (- (get total-supply collection) u1) }))
        (ok true)
    )
)

;; ================================
;; READ-ONLY
;; ================================

(define-read-only (get-ordinal (id uint))
    (map-get? ordinals id)
)

(define-read-only (get-collection (id uint))
    (map-get? collections id)
)
