;; --------------------------------------------------
;; Contrato #1: Digital Tip Jar (Reown Ready)
;; --------------------------------------------------

;; 1. Variables de datos
(define-data-var total-tips uint u0)
(define-data-var top-donor principal tx-sender)
(define-data-var max-tip uint u0)

;; 2. Mapas para estadísticas
(define-map donor-stats principal { total-sent: uint, last-tip: uint })

;; 3. Funciones Públicas

;; Enviar una propina (Transaction ready)
(define-public (send-tip (amount uint))
    (let (
        (sender tx-sender)
        (current-total (get total-sent (default-to { total-sent: u0, last-tip: u0 } (map-get? donor-stats sender))))
    )
        ;; Aserción: La propina debe ser mayor a 0
        (asserts! (> amount u0) (err u101))
        
        ;; Transferencia de STX al contrato (custodia)
        (try! (stx-transfer? amount sender (as-contract tx-sender)))
        
        ;; Actualizar estadísticas del donante
        (map-set donor-stats sender { 
            total-sent: (+ current-total amount), 
            last-tip: amount 
        })
        
        ;; Actualizar total global
        (var-set total-tips (+ (var-get total-tips) amount))
        
        ;; Comprobar si es el nuevo donante máximo
        (if (> amount (var-get max-tip))
            (begin
                (var-set max-tip amount)
                (var-set top-donor sender)
            )
            false
        )
        
        (print { event: "tip-received", donor: sender, amount: amount })
        (ok true)
    )
)

;; 4. Funciones de Lectura (Para AppKit UI)

(define-read-only (get-global-stats)
    {
        total: (var-get total-tips),
        record: (var-get max-tip),
        leader: (var-get top-donor)
    }
)

(define-read-only (get-my-stats (user principal))
    (default-to { total-sent: u0, last-tip: u0 } (map-get? donor-stats user))
)
