;; SIP-009 NFT Trait
;; Standard trait definition for NFTs on the Stacks blockchain
;; Tags: Stacks, Clarity, Bitcoin Layer 2

(define-trait nft-trait
  (
    (get-last-token-id () (response uint uint))
    (get-token-uri (uint) (response (optional (string-utf8 256)) uint))
    (get-owner (uint) (response (optional principal) uint))
    (transfer (uint principal principal) (response bool uint))
  )
)
