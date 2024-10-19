;; ChainSource - Supply Chain Transparency Contract
;; Version 1.0

(define-data-var contract-owner principal tx-sender)

;; Product struct
(define-map products uint 
  { 
    id: uint,
    name: (string-utf8 100),
    manufacturer: principal,
    origin: (string-utf8 50),
    timestamp: uint,
    current-location: (string-utf8 100),
    status: (string-utf8 20)  ;; Fixed: Changed from string-ascii to string-utf8
  }
)

;; Initialize product counter
(define-data-var product-counter uint u0)

;; Add new product
(define-public (add-product (name (string-utf8 100)) 
                          (origin (string-utf8 50)) 
                          (location (string-utf8 100)))
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

;; Update product location
(define-public (update-location (product-id uint) 
                              (new-location (string-utf8 100)))
  (let ((product (unwrap! (map-get? products product-id) (err u1))))
    (map-set products product-id
      (merge product { current-location: new-location })
    )
    (ok true)
  )
)

;; Get product details
(define-read-only (get-product (product-id uint))
  (map-get? products product-id)
)