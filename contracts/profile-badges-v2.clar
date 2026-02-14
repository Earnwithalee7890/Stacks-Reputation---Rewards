;; Profile Badges V2 - Achievement NFTs
;; Non-transferable badges for milestones (e.g., "100 Day Streak")

(impl-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-non-fungible-token profile-badge uint)
(define-data-var last-id uint u0)

(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

(define-map badge-metadata
    uint
    {
        name: (string-ascii 50),
        description: (string-ascii 100),
        recipient: principal
    }
)

;; Only the contract owner (admin) can mint badges
(define-public (mint (recipient principal) (name (string-ascii 50)) (description (string-ascii 100)))
    (let
        (
            (id (+ (var-get last-id) u1))
        )
        ;; In production, add auth check here: (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        
        (try! (nft-mint? profile-badge id recipient))
        
        (map-set badge-metadata id {
            name: name,
            description: description,
            recipient: recipient
        })
        
        (var-set last-id id)
        (ok id)
    )
)

;; Badges are Soulbound (non-transferable by users)
(define-public (transfer (id uint) (sender principal) (recipient principal))
    (err u403) ;; Forbidden
)

(define-read-only (get-last-token-id)
    (ok (var-get last-id))
)

(define-read-only (get-token-uri (id uint))
    (ok none)
)

(define-read-only (get-owner (id uint))
    (ok (nft-get-owner? profile-badge id))
)
