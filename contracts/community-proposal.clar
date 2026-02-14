;; Community Proposal - Lightweight Governance
;; Simple Yes/No voting mechanism for ecosystem signals.

(define-constant err-not-found (err u100))
(define-constant err-already-voted (err u101))

(define-data-var proposal-nonce uint u0)

(define-map proposals
    uint
    {
        title: (string-utf8 50),
        proposer: principal,
        yes-votes: uint,
        no-votes: uint,
        end-block: uint
    }
)

(define-map user-votes { proposal: uint, user: principal } bool)

(define-public (create-proposal (title (string-utf8 50)) (duration uint))
    (let
        (
            (id (var-get proposal-nonce))
        )
        (map-set proposals id {
            title: title,
            proposer: tx-sender,
            yes-votes: u0,
            no-votes: u0,
            end-block: (+ block-height duration)
        })
        (var-set proposal-nonce (+ id u1))
        (ok id)
    )
)

(define-public (vote (id uint) (vote-yes bool))
    (let
        (
            (proposal (unwrap! (map-get? proposals id) err-not-found))
        )
        (asserts! (is-none (map-get? user-votes { proposal: id, user: tx-sender })) err-already-voted)
        (asserts! (< block-height (get end-block proposal)) (err u102))
        
        (map-set proposals id (merge proposal {
            yes-votes: (if vote-yes (+ (get yes-votes proposal) u1) (get yes-votes proposal)),
            no-votes: (if (not vote-yes) (+ (get no-votes proposal) u1) (get no-votes proposal))
        }))
        
        (map-set user-votes { proposal: id, user: tx-sender } true)
        (ok true)
    )
)
