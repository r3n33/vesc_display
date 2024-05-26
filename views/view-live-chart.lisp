(def live-chart-values (list))

@const-start

; Pop from front of list, push to back of list
(define append-value
    (lambda (lst new-val max-length)
      (let ((updated-list (append lst (list new-val))))
        (if (> (length updated-list) max-length)
            (cdr updated-list)
            updated-list))))

(defun view-init-chart () {
    (def buf-chart-label (img-buffer 'indexed4 240 55))

    (def buf-chart (img-buffer 'indexed2 240 128))
    (def chart-value-index 0)
    (var chart-value-max 5)
    (var chart-labels (list "Duty Cycle" "Speed" "KW" "Angle" "Amps" "Battery SOC"))
    (txt-block-c buf-chart-label (list 0 1 2 3) 120 0 font24 (to-str (ix chart-labels chart-value-index)))
    (disp-render buf-chart-label 40 22 '(0x000000 0x4f514f 0x929491 0xfbfcfc))

    (view-init-menu)
    (defun on-btn-0-pressed () (def state-view-next (previous-view)))
    (defun on-btn-1-pressed () (if (> chart-value-index 0) {
        (setq chart-value-index (- chart-value-index 1))
        (img-clear buf-chart-label)
        (txt-block-c buf-chart-label (list 0 1 2 3) 120 0 font24 (to-str (ix chart-labels chart-value-index)))
        (disp-render buf-chart-label 40 22 '(0x000000 0x4f514f 0x929491 0xfbfcfc))
    }))
    (defun on-btn-2-pressed () (if (< chart-value-index chart-value-max) {
        (setq chart-value-index (+ chart-value-index 1))
        (img-clear buf-chart-label)
        (txt-block-c buf-chart-label (list 0 1 2 3) 120 0 font24 (to-str (ix chart-labels chart-value-index)))
        (disp-render buf-chart-label 40 22 '(0x000000 0x4f514f 0x929491 0xfbfcfc))
    }))
    (defun on-btn-3-pressed () (def state-view-next (next-view)))
    (view-draw-menu 'arrow-left 'arrow-down 'arrow-up 'arrow-right)
    (view-render-menu)
})

(defun view-draw-chart () {
    (var chart-items (list stats-duty stats-kmh stats-kw stats-angle-pitch stats-amps-now stats-battery-soc))

    (setq live-chart-values (append-value live-chart-values (ix chart-items chart-value-index) 30))
    (if (> (length live-chart-values) 10) {
        (img-clear buf-chart)
        (draw-live-chart buf-chart 0 0 240 128 1 1 live-chart-values)
    })
})

(defun view-render-chart () {
    (disp-render buf-chart 40 78 '(0x000000 0x0000ff))
})

(defun view-cleanup-chart () {
    (def buf-chart-label nil)
    (def buf-chart nil)
    (def live-chart-values (list))
})
