;; ChainSource - Supply Chain Transparency Contract with RBAC
;; Version 1.1

(define-constant ERR-NOT-AUTHORIZED (err u100))
(define-constant ERR-INVALID-ROLE (err u101))
(define-constant ERR-NOT-FOUND (err u102))

;; Role definitions
(define-data-var contract-owner principal tx-sender)

(define-map roles principal 
  {
    role: (string-utf8 20),
    is-active: bool
  }
)

;; Product struct
(define-map products uint 
  { 
    id: uint,
    name: (string-utf8 100),
    manufacturer: principal,
    origin: (string-utf8 50),
    timestamp: uint,
    current-location: (string-utf8 100),
    status: (string-utf8 20)
  }
)

(define-data-var product-counter uint u0)

;; Role management functions
(define-private (is-contract-owner)
  (is-eq tx-sender (var-get contract-owner))
)

(define-private (check-role (address principal) (required-role (string-utf8 20)))
  (match (map-get? roles address)
    role (and 
          (is-eq (get role role) required-role)
          (get is-active role))
    false
  )
)

(define-public (assign-role (address principal) (new-role (string-utf8 20)))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (ok (map-set roles address { role: new-role, is-active: true }))
  )
)

(define-public (revoke-role (address principal))
  (begin
    (asserts! (is-contract-owner) ERR-NOT-AUTHORIZED)
    (ok (map-set roles address 
      (merge (default-to { role: u"", is-active: false } (map-get? roles address))
        { is-active: false })))
  )
)

;; Product management functions
(define-public (add-product (name (string-utf8 100)) 
                          (origin (string-utf8 50)) 
                          (location (string-utf8 100)))
  (begin
    (asserts! (check-role tx-sender u"manufacturer") ERR-NOT-AUTHORIZED)
    (let ((product-id (var-get product-counter)))
      (map-set products product-id
        {
          id: product-id,
          name: name,
          manufacturer: tx-sender,
          origin: origin,
          timestamp: block-height,
          current-location: location,
          status: u"created"
        }
      )
      (var-set product-counter (+ product-id u1))
      (ok product-id)
    )
  )
)

(define-public (update-location (product-id uint) 
                              (new-location (string-utf8 100)))
  (begin
    (asserts! (or 
      (check-role tx-sender u"transporter")
      (check-role tx-sender u"manufacturer")) ERR-NOT-AUTHORIZED)
    (match (map-get? products product-id)
      product (ok (map-set products product-id
                  (merge product { current-location: new-location })))
      ERR-NOT-FOUND)
  )
)

;; Get product details (public read-only)
(define-read-only (get-product (product-id uint))
  (map-get? products product-id)
)

;; Get role information (public read-only)
(define-read-only (get-role (address principal))
  (map-get? roles address)
)