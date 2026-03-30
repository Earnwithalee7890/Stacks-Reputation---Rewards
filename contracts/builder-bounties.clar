;; Title: Builder Bounties
;; Description: On-chain bounty board for open-source Stacks contributions
;; Tags: Stacks, Clarity, Bitcoin Layer 2, Bounties, Open Source
;; Fee: 0.06 STX per bounty creation
;; Network: Stacks Mainnet
;; Clarity Version: 2
;;
;; How it works:
;; - Project owners post bounties with STX rewards
;; - Builders submit work and get approved by the poster
;; - STX is released from escrow to the builder
;; - 0.06 STX creation fee goes to protocol treasury

(define-constant CONTRACT_OWNER tx-sender)
(define-constant ERR_UNAUTHORIZED (err u100))
(define-constant ERR_NOT_FOUND (err u101))
(define-constant ERR_ALREADY_CLAIMED (err u102))
(define-constant ERR_INVALID (err u103))
(define-constant BOUNTY_FEE u60000) ;; 0.06 STX

(define-data-var next-bounty-id uint u1)

(define-map Bounties
  uint
  {
    poster: principal,
    reward: uint,
    description: (string-ascii 100),
    claimer: (optional principal),
    status: (string-ascii 10)
  }
)

;; @desc Post a bounty with STX reward
(define-public (post-bounty (reward uint) (description (string-ascii 100)))
  (let (
    (id (var-get next-bounty-id))
  )
    (asserts! (> reward u0) ERR_INVALID)
    ;; Fee to treasury
    (try! (stx-transfer? BOUNTY_FEE tx-sender .EarnWithAlee-Treasury))
    (try! (contract-call? .EarnWithAlee-Treasury record-fee tx-sender BOUNTY_FEE))
    ;; Lock reward
    (try! (stx-transfer? reward tx-sender (as-contract tx-sender)))
    (map-set Bounties id {
      poster: tx-sender,
      reward: reward,
      description: description,
      claimer: none,
      status: "open"
    })
    (var-set next-bounty-id (+ id u1))
    (print {action: "bounty-posted", id: id, poster: tx-sender, reward: reward})
    (ok id)
  )
)

;; @desc Claim a bounty (builder submits work)
(define-public (claim-bounty (bounty-id uint))
  (let (
    (bounty (unwrap! (map-get? Bounties bounty-id) ERR_NOT_FOUND))
  )
    (asserts! (is-eq (get status bounty) "open") ERR_ALREADY_CLAIMED)
    (map-set Bounties bounty-id (merge bounty { claimer: (some tx-sender), status: "claimed" }))
    (print {action: "bounty-claimed", id: bounty-id, claimer: tx-sender})
    (ok true)
  )
)

;; @desc Approve and release bounty reward (poster only)
(define-public (approve-bounty (bounty-id uint))
  (let (
    (bounty (unwrap! (map-get? Bounties bounty-id) ERR_NOT_FOUND))
    (claimer (unwrap! (get claimer bounty) ERR_NOT_FOUND))
  )
    (asserts! (is-eq (get poster bounty) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status bounty) "claimed") ERR_INVALID)
    (try! (as-contract (stx-transfer? (get reward bounty) (as-contract tx-sender) claimer)))
    (map-set Bounties bounty-id (merge bounty { status: "completed" }))
    (print {action: "bounty-approved", id: bounty-id, claimer: claimer, reward: (get reward bounty)})
    (ok true)
  )
)

;; @desc Cancel bounty and reclaim funds (poster only, if unclaimed)
(define-public (cancel-bounty (bounty-id uint))
  (let (
    (bounty (unwrap! (map-get? Bounties bounty-id) ERR_NOT_FOUND))
  )
    (asserts! (is-eq (get poster bounty) tx-sender) ERR_UNAUTHORIZED)
    (asserts! (is-eq (get status bounty) "open") ERR_ALREADY_CLAIMED)
    (try! (as-contract (stx-transfer? (get reward bounty) (as-contract tx-sender) tx-sender)))
    (map-set Bounties bounty-id (merge bounty { status: "cancelled" }))
    (ok true)
  )
)

;; Read-only
(define-read-only (get-bounty (bounty-id uint))
  (map-get? Bounties bounty-id)
)

(define-read-only (get-next-bounty-id)
  (var-get next-bounty-id)
)

;; Incremental refinement pass 1
