;; Test script for EarnWithAlee
;; Use with `clarinet console`

(contract-call? .proof-of-builder register-builder "test-builder")
(contract-call? .daily-check-in check-in)
(contract-call? .builder-sbt mint-sbt)
(contract-call? .treasury get-total-revenue)
