;; Bitcoin Ordinal Marketplace V2
;; Enforces royalties on-chain for SIP-009 NFTs

(use-trait nft-trait 'SP2PABAF9FTAJYNFZH93XENAJ8FVY99RRM50D2JG9.nft-trait.nft-trait)

(define-constant err-not-found (err u100))
(define-constant err-unauthorized (err u101))
(define-constant err-listing-expired (err u102))

(define-map listings
    { contract: principal, id: uint }
    {
        seller: principal,
        price: uint,
        royalty-percent: uint, ;; e.g., 500 = 5%
        royalty-address: principal
    }
)

(define-public (list-asset (nft-contract <nft-trait>) (id uint) (price uint) (royalty-percent uint) (royalty-address principal))
    (let
        (
            (contract-principal (contract-of nft-contract))
        )
        ;; Verify ownership
        (asserts! (is-eq (some tx-sender) (unwrap! (contract-call? nft-contract get-owner id) err-not-found)) err-unauthorized)
        
        ;; Transfer NFT to escrow (this contract)
        (try! (contract-call? nft-contract transfer id tx-sender (as-contract tx-sender)))
        
        (map-set listings { contract: contract-principal, id: id }
            {
                seller: tx-sender,
                price: price,
                royalty-percent: royalty-percent,
                royalty-address: royalty-address
            }
        )
        (ok true)
    )
)

(define-public (buy-asset (nft-contract <nft-trait>) (id uint))
    (let
        (
            (contract-principal (contract-of nft-contract))
            (listing (unwrap! (map-get? listings { contract: contract-principal, id: id }) err-not-found))
            (price (get price listing))
            (royalty-amount (/ (* price (get royalty-percent listing)) u10000))
            (seller-amount (- price royalty-amount))
        )
        ;; Pay royalty
        (if (> royalty-amount u0)
            (try! (stx-transfer? royalty-amount tx-sender (get royalty-address listing)))
            true
        )
        
        ;; Pay seller
        (try! (stx-transfer? seller-amount tx-sender (get seller listing)))
        
        ;; Transfer NFT to buyer
        (try! (as-contract (contract-call? nft-contract transfer id (as-contract tx-sender) tx-sender)))
        
        ;; Remove listing
        (map-delete listings { contract: contract-principal, id: id })
        (ok true)
    )
)
