;; Define NFT token
(define-non-fungible-token story-nft uint)

;; Token metadata
(define-map token-metadata
  { token-id: uint }
  {
    title: (string-utf8 100),
    creator: principal,
    uri: (string-utf8 200)
  }
)

;; Mint NFT for story
(define-public (mint-story-nft (story-id uint) (title (string-utf8 100)) (uri (string-utf8 200)))
  (let
    ((token-exists (nft-get-owner? story-nft story-id)))
    (asserts! (is-none token-exists) (err u401))
    (try! (nft-mint? story-nft story-id tx-sender))
    (map-set token-metadata
      { token-id: story-id }
      {
        title: title,
        creator: tx-sender,
        uri: uri
      }
    )
    (ok true)
  )
)
