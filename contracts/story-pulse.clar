;; Story data structure
(define-map stories
  { story-id: uint }
  {
    creator: principal,
    title: (string-utf8 100),
    audio-url: (string-utf8 200),
    image-url: (string-utf8 200),
    likes: uint,
    tips-amount: uint,
    created-at: uint
  }
)

;; Data vars
(define-data-var story-counter uint u0)
(define-data-var platform-fee uint u50) ;; 5%

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-not-found (err u404))
(define-constant err-unauthorized (err u401))

;; Public functions
(define-public (create-story (title (string-utf8 100)) (audio-url (string-utf8 200)) (image-url (string-utf8 200)))
  (let
    (
      (story-id (+ (var-get story-counter) u1))
    )
    (map-set stories
      { story-id: story-id }
      {
        creator: tx-sender,
        title: title,
        audio-url: audio-url,
        image-url: image-url,
        likes: u0,
        tips-amount: u0,
        created-at: block-height
      }
    )
    (var-set story-counter story-id)
    (ok story-id)
  )
)

(define-public (like-story (story-id uint))
  (match (map-get? stories {story-id: story-id})
    story (begin
      (map-set stories
        {story-id: story-id}
        (merge story {likes: (+ (get likes story) u1)})
      )
      (ok true)
    )
    (err err-not-found)
  )
)

(define-public (tip-story (story-id uint) (amount uint))
  (match (map-get? stories {story-id: story-id})
    story (begin
      (try! (stx-transfer? amount tx-sender (get creator story)))
      (map-set stories
        {story-id: story-id}
        (merge story {tips-amount: (+ (get tips-amount story) amount)})
      )
      (ok true)
    )
    (err err-not-found)
  )
)
