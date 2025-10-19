;; title: Tradition-Registry
;; version: 1.0.0
;; summary: A registry for communities to log cultural practices and traditions
;; description: Allows communities to register, document, and preserve cultural practices to prevent loss over generations

;; constants
(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-TRADITION-EXISTS (err u101))
(define-constant ERR-TRADITION-NOT-FOUND (err u102))
(define-constant ERR-INVALID-INPUT (err u103))

;; data vars
(define-data-var tradition-counter uint u0)

;; data maps
(define-map traditions 
  uint 
  {
    name: (string-ascii 100),
    description: (string-ascii 500),
    community: (string-ascii 50),
    creator: principal,
    created-at: uint,
    preserved: bool
  }
)

(define-map community-traditions 
  (string-ascii 50) 
  (list 100 uint)
)

;; public functions
(define-public (register-tradition (name (string-ascii 100)) (description (string-ascii 500)) (community (string-ascii 50)))
  (let ((tradition-id (+ (var-get tradition-counter) u1))
        (current-block block-height))
    (asserts! (> (len name) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    (asserts! (> (len community) u0) ERR-INVALID-INPUT)

    (map-set traditions tradition-id {
      name: name,
      description: description,
      community: community,
      creator: tx-sender,
      created-at: current-block,
      preserved: true
    })

    (let ((current-traditions (default-to (list) (map-get? community-traditions community))))
      (map-set community-traditions community (unwrap! (as-max-len? (append current-traditions tradition-id) u100) ERR-INVALID-INPUT))
    )

    (var-set tradition-counter tradition-id)
    (ok tradition-id)
  )
)

(define-public (update-tradition (tradition-id uint) (description (string-ascii 500)))
  (let ((tradition (unwrap! (map-get? traditions tradition-id) ERR-TRADITION-NOT-FOUND)))
    (asserts! (is-eq (get creator tradition) tx-sender) ERR-NOT-AUTHORIZED)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)

    (map-set traditions tradition-id (merge tradition { description: description }))
    (ok true)
  )
)

;; read only functions
(define-read-only (get-tradition (tradition-id uint))
  (map-get? traditions tradition-id)
)

(define-read-only (get-community-traditions (community (string-ascii 50)))
  (map-get? community-traditions community)
)

(define-read-only (get-tradition-count)
  (var-get tradition-counter)
)

(define-read-only (get-tradition-by-community-and-name (community (string-ascii 50)) (target-name (string-ascii 100)))
  (let ((tradition-ids (default-to (list) (map-get? community-traditions community))))
    (get result (find-tradition-by-name tradition-ids target-name))
  )
)

;; private functions
(define-private (find-tradition-by-name (tradition-ids (list 100 uint)) (target-name (string-ascii 100)))
  (fold check-tradition-name-match tradition-ids { target-name: target-name, result: none })
)

(define-private (check-tradition-name-match 
  (tradition-id uint) 
  (acc { target-name: (string-ascii 100), result: (optional uint) }))
  (if (is-some (get result acc))
    acc
    (let ((tradition (map-get? traditions tradition-id)))
      (if (and (is-some tradition) 
               (is-eq (get name (unwrap-panic tradition)) (get target-name acc)))
        { target-name: (get target-name acc), result: (some tradition-id) }
        acc
      )
    )
  )
)
