;; Title: CuratorChain - Community-Driven Quality Control Protocol
;;
;; Summary: A revolutionary blockchain-based content discovery platform that harnesses
;; collective intelligence to surface premium web content through economic incentives
;; and transparent community governance.
;;
;; Description: CuratorChain transforms how valuable information spreads across the 
;; internet by creating a merit-based ecosystem where:
;; - Knowledge contributors earn recognition and financial rewards for sharing gems
;; - Community validators build credibility through accurate content assessment  
;; - Spam and low-quality content gets naturally filtered out through democratic voting
;; - Financial incentives align individual contributions with collective benefit
;; - All curation decisions remain permanently auditable on the blockchain
;; - Topic-based organization ensures relevant content reaches the right audiences
;;
;; Built on Stacks for Bitcoin-grade security with smart contract flexibility.

;; CORE PROTOCOL CONFIGURATION

(define-constant PROTOCOL_ADMINISTRATOR tx-sender)

;; ERROR DEFINITIONS

(define-constant ERR_UNAUTHORIZED_ACCESS (err u100))
(define-constant ERR_INVALID_SUBMISSION (err u101))
(define-constant ERR_DUPLICATE_ENTRY (err u102))
(define-constant ERR_NONEXISTENT_ITEM (err u103))
(define-constant ERR_INADEQUATE_BALANCE (err u104))
(define-constant ERR_INVALID_TOPIC (err u105))
(define-constant ERR_INVALID_FLAG (err u106))
(define-constant ERR_OVERFLOW (err u107))
(define-constant ERR_INVALID_APPRAISAL (err u108))
(define-constant ERR_INVALID_ITEM_ID (err u109))

;; PROTOCOL PARAMETERS

(define-constant MIN_HYPERLINK_LENGTH u10)
(define-constant MAX_UINT u340282366920938463463374607431768211455)

;; DYNAMIC STATE VARIABLES

(define-data-var submission-charge uint u10)
(define-data-var aggregate-submissions uint u0)
(define-data-var content-topics (list 10 (string-ascii 20)) (list "Technology" "Science" "Art" "Politics" "Sports"))

;; DATA STORAGE STRUCTURES

;; Primary content registry with comprehensive metadata
(define-map curated-items
  { item-identifier: uint }
  {
    originator: principal,
    headline: (string-ascii 100),
    hyperlink: (string-ascii 200),
    topic: (string-ascii 20),
    publication-epoch: uint,
    appraisals: int,
    gratuities: uint,
    flags: uint,
  }
)

;; Individual user voting records per content item
(define-map participant-appraisals
  {
    participant: principal,
    item-identifier: uint,
  }
  { appraisal: int }
)

;; Community reputation tracking system
(define-map participant-credibility
  { participant: principal }
  { metric: int }
)

;; PRIVATE UTILITY FUNCTIONS

;; Verify content item existence in the registry
(define-private (item-exists (item-identifier uint))
  (is-some (map-get? curated-items { item-identifier: item-identifier }))
)

;; Filter helper for optional content items
(define-private (not-none (item (optional {
  originator: principal,
  headline: (string-ascii 100),
  hyperlink: (string-ascii 200),
  topic: (string-ascii 20),
  publication-epoch: uint,
  appraisals: int,
  gratuities: uint,
  flags: uint,
})))
  (is-some item)
)

;; Quality gate: only return items with positive community sentiment
(define-private (retrieve-item-if-valid (id uint))
  (match (map-get? curated-items { item-identifier: id })
    item (if (>= (get appraisals item) 0)
      (some item)
      none
    )
    none
  )
)

;; Generate bounded sequential ID list for batch operations
(define-private (enumerate (n uint))
  (let ((limit (if (> n u10)
      u10
      n
    )))
    (list
      (if (>= limit u1)
        u1
        u0
      )
      (if (>= limit u2)
        u2
        u0
      )
      (if (>= limit u3)
        u3
        u0
      )
      (if (>= limit u4)
        u4
        u0
      )
      (if (>= limit u5)
        u5
        u0
      )
      (if (>= limit u6)
        u6
        u0
      )
      (if (>= limit u7)
        u7
        u0
      )
      (if (>= limit u8)
        u8
        u0
      )
      (if (>= limit u9)
        u9
        u0
      )
      (if (>= limit u10)
        u10
        u0
      )
    )
  )
)

;; Utility to filter zero values from enumerated lists
(define-private (is-non-zero (n uint))
  (not (is-eq n u0))
)

;; PUBLIC CONTENT CURATION INTERFACE

;; Submit valuable content for community evaluation and potential rewards
(define-public (contribute-item
    (headline (string-ascii 100))
    (hyperlink (string-ascii 200))
    (topic (string-ascii 20))
  )
  (let ((item-identifier (+ (var-get aggregate-submissions) u1)))
    ;; Validate content submission requirements
    (asserts!
      (and
        (>= (len headline) u1)
        (>= (len hyperlink) MIN_HYPERLINK_LENGTH)
        (>= (len topic) u1)
      )
      ERR_INVALID_SUBMISSION
    )

    ;; Prevent overflow in item counting
    (asserts! (> item-identifier (var-get aggregate-submissions)) ERR_OVERFLOW)

    ;; Ensure topic exists in approved categories
    (asserts! (is-some (index-of (var-get content-topics) topic))
      ERR_INVALID_TOPIC
    )

    ;; Verify submitter can pay submission fee
    (asserts! (>= (stx-get-balance tx-sender) (var-get submission-charge))
      ERR_INADEQUATE_BALANCE
    )

    ;; Process submission fee payment
    (try! (stx-transfer? (var-get submission-charge) tx-sender PROTOCOL_ADMINISTRATOR))

    ;; Register new content item in the system
    (map-set curated-items { item-identifier: item-identifier } {
      originator: tx-sender,
      headline: headline,
      hyperlink: hyperlink,
      topic: topic,
      publication-epoch: stacks-block-height,
      appraisals: 0,
      gratuities: u0,
      flags: u0,
    })

    ;; Update global submission counter
    (var-set aggregate-submissions item-identifier)

    ;; Emit creation event for indexing
    (print {
      type: "new-item",
      item-identifier: item-identifier,
      originator: tx-sender,
    })

    (ok item-identifier)
  )
)

;; Community voting mechanism with reputation consequences
(define-public (appraise-item
    (item-identifier uint)
    (appraisal int)
  )
  (let (
      (previous-appraisal (default-to 0
        (get appraisal
          (map-get? participant-appraisals {
            participant: tx-sender,
            item-identifier: item-identifier,
          })
        )))
      (target-item (unwrap! (map-get? curated-items { item-identifier: item-identifier })
        ERR_NONEXISTENT_ITEM
      ))
      (appraiser-standing (default-to { metric: 0 }
        (map-get? participant-credibility { participant: tx-sender })
      ))
    )
    ;; Verify target content exists
    (asserts! (item-exists item-identifier) ERR_NONEXISTENT_ITEM)

    ;; Enforce binary voting system (upvote/downvote only)
    (asserts! (or (is-eq appraisal 1) (is-eq appraisal -1)) ERR_INVALID_APPRAISAL)

    ;; Record user's vote on this specific item
    (map-set participant-appraisals {
      participant: tx-sender,
      item-identifier: item-identifier,
    } { appraisal: appraisal }
    )

    ;; Update item's aggregate community sentiment
    (map-set curated-items { item-identifier: item-identifier }
      (merge target-item { appraisals: (+ (get appraisals target-item) (- appraisal previous-appraisal)) })
    )

    ;; Adjust voter's reputation based on participation
    (map-set participant-credibility { participant: tx-sender } { metric: (+ (get metric appraiser-standing) appraisal) })

    ;; Log voting activity for transparency
    (print {
      type: "appraisal",
      item-identifier: item-identifier,
      appraiser: tx-sender,
      appraisal: appraisal,
    })

    (ok true)
  )
)

;; Direct monetary appreciation system for exceptional content
(define-public (reward-originator
    (item-identifier uint)
    (gratuity-amount uint)
  )
  (let ((target-item (unwrap! (map-get? curated-items { item-identifier: item-identifier })
      ERR_NONEXISTENT_ITEM
    )))
    ;; Validate reward target exists
    (asserts! (item-exists item-identifier) ERR_NONEXISTENT_ITEM)

    ;; Confirm sender has sufficient funds
    (asserts! (>= (stx-get-balance tx-sender) gratuity-amount)
      ERR_INADEQUATE_BALANCE
    )

    ;; Update reward tracking before transfer
    (map-set curated-items { item-identifier: item-identifier }
      (merge target-item { gratuities: (+ (get gratuities target-item) gratuity-amount) })
    )

    ;; Execute STX transfer to content creator
    (try! (stx-transfer? gratuity-amount tx-sender (get originator target-item)))

    ;; Log reward transaction
    (print {
      type: "reward",
      item-identifier: item-identifier,
      from: tx-sender,
      to: (get originator target-item),
      amount: gratuity-amount,
    })

    (ok true)
  )
)

;; Community-driven content quality control mechanism
(define-public (flag-item (item-identifier uint))
  (let ((target-item (unwrap! (map-get? curated-items { item-identifier: item-identifier })
      ERR_NONEXISTENT_ITEM
    )))
    ;; Validate flagging target exists
    (asserts! (item-exists item-identifier) ERR_NONEXISTENT_ITEM)

    ;; Prevent self-flagging to avoid gaming
    (asserts! (not (is-eq (get originator target-item) tx-sender))
      ERR_INVALID_FLAG
    )

    ;; Increment flag counter for moderation tracking
    (map-set curated-items { item-identifier: item-identifier }
      (merge target-item { flags: (+ (get flags target-item) u1) })
    )

    ;; Record flagging event for transparency
    (print {
      type: "flag",
      item-identifier: item-identifier,
      flagger: tx-sender,
    })

    (ok true)
  )
)