;; Title: Builder Soulbound Token (SBT)
;; Description: Non-transferable NFT representing verified builder status
;; Tags: Stacks, Clarity, Bitcoin Layer 2, SBT, NFT, SIP-009
;; Fee: 0.07 STX per mint
;; Network: Stacks Mainnet
;; Clarity Version: 2

(impl-trait .nft-trait.nft-trait)

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_TRANSFERABLE (err u101))
(define-constant ERR_ALREADY_MINTED (err u102))
(define-constant MINT_FEE u70000) ;; 0.07 STX

(define-non-fungible-token builder-sbt uint)
(define-data-var last-token-id uint u0)
(define-map MintedBy principal uint)

;; @desc Mint your Soulbound Token (one per wallet)
(define-public (mint-sbt)
  (let (
    (token-id (+ (var-get last-token-id) u1))
  )
    (asserts! (is-none (map-get? MintedBy tx-sender)) ERR_ALREADY_MINTED)
    (try! (stx-transfer? MINT_FEE tx-sender .treasury))
    (try! (contract-call? .treasury record-fee tx-sender MINT_FEE))
    (try! (nft-mint? builder-sbt token-id tx-sender))
    (map-set MintedBy tx-sender token-id)
    (var-set last-token-id token-id)
    (print {action: "mint-sbt", user: tx-sender, token-id: token-id})
    (ok token-id)
  )
)

;; @desc SIP-009: Transfer blocked — SBTs are non-transferable
(define-public (transfer (id uint) (sender principal) (recipient principal))
  ERR_NOT_TRANSFERABLE
)

;; SIP-009 Read-only
(define-read-only (get-last-token-id)
  (ok (var-get last-token-id))
)

(define-read-only (get-token-uri (id uint))
  (ok none)
)

(define-read-only (get-owner (id uint))
  (ok (nft-get-owner? builder-sbt id))
)

(define-read-only (get-token-by-owner (owner principal))
  (map-get? MintedBy owner)
)
