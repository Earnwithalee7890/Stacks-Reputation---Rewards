;; Stream Token (Implementation of SIP-010 for testing)
(impl-trait 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM.nft-trait.nft-trait)

(define-fungible-token stream-token)

(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-token-owner (err u101))

(define-public (transfer (amount uint) (sender principal) (recipient principal) (memo (optional (buff 34))))
    (begin
        (asserts! (is-eq tx-sender sender) err-not-token-owner)
        (try! (ft-transfer? stream-token amount sender recipient))
        (match memo to-print (print to-print) 0x)
        (ok true)
    )
)

(define-read-only (get-name)
    (ok "Stream Token")
)

(define-read-only (get-symbol)
    (ok "STRM")
)

(define-read-only (get-decimals)
    (ok u6)
)

(define-read-only (get-balance (who principal))
    (ok (ft-get-balance stream-token who))
)

(define-read-only (get-total-supply)
    (ok (ft-get-supply stream-token))
)

(define-read-only (get-token-uri)
    (ok none)
)

(define-public (mint (amount uint) (recipient principal))
    (begin
        (ft-mint? stream-token amount recipient)
    )
)

;; Mint initial supply to deployer
(begin
    (try! (ft-mint? stream-token u1000000000000 contract-owner))
)
