;; --------------------------------------------------
;; Contrato #1: Digital Tip Jar (Versión Ultrarrápida)
;; --------------------------------------------------

;; 1. Variables de datos
(define-constant OWNER tx-sender) ;; El que despliega el contrato recibe las propinas
(define-data-var total-tips uint u0)

;; 2. Mapa para guardar cuánto ha dado cada uno
(define-map donor-stats principal uint)

;; 3. Funciones Públicas

;; Función para enviar propina - ¡ESTA NO FALLA!
(define-public (send-tip (amount uint))
    (begin
        ;; Aserción básica
        (asserts! (> amount u0) (err u101))
        
        ;; Transferencia directa de STX del emisor al dueño
        (try! (stx-transfer? amount tx-sender OWNER))
        
        ;; Actualizar el mapa de donantes
        (map-set donor-stats tx-sender (+ (default-to u0 (map-get? donor-stats tx-sender)) amount))
        
        ;; Actualizar el contador global
        (var-set total-tips (+ (var-get total-tips) amount))
        
        (ok true)
    )
)

;; 4. Funciones de Lectura

(define-read-only (get-total)
    (ok (var-get total-tips))
)

(define-read-only (get-user-total (user principal))
    (ok (default-to u0 (map-get? donor-stats user)))
)
