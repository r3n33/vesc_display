(defun view-init-dash-primary  () {
    (def buf-stripe-bg (img-buffer 'indexed4 246 147))
    (img-blit buf-stripe-bg (img-buffer-from-bin icon-stripe) 0 0 -1)
    (def buf-motor-icon (img-buffer 'indexed4 48 31))
    (img-blit buf-motor-icon (img-buffer-from-bin icon-motor) 0 0 -1)
    (def buf-esc-icon (img-buffer 'indexed4 56 31))
    (img-blit buf-esc-icon (img-buffer-from-bin icon-esc) 0 0 -1)
    (def buf-battery-icon (img-buffer 'indexed4 42 31))
    (img-blit buf-battery-icon (img-buffer-from-bin icon-battery) 0 0 -1)
    (def buf-warning-icon (img-buffer 'indexed4 46 41))
    (img-blit buf-warning-icon (img-buffer-from-bin icon-warning) 0 0 -1)

    (def buf-motor-val (img-buffer 'indexed2 (first (img-dims buf-motor-icon)) 20))
    (def buf-esc-val (img-buffer 'indexed2 (first (img-dims buf-esc-icon)) 20))
    (def buf-battery-val (img-buffer 'indexed2 (first (img-dims buf-battery-icon)) 20))

    (def buf-incline (img-buffer 'indexed2 120 35))
    (def buf-battery (img-buffer 'indexed4 42 140))
    
    (def buf-speed (img-buffer 'indexed2 179 90))
    (def buf-units (img-buffer 'indexed2 50 25))

    (view-init-menu)
    (defun on-btn-2-pressed () {
        (setting-units-cycle)
        (setix view-previous-stats 0 'stats-kmh) ; Re-draw units
    })
    (defun on-btn-3-pressed () {
        (def state-view-next 'view-speed-large)
    })

    (def view-previous-stats (list 'stats-kmh 'stats-battery-soc 'stats-temp-battery 'stats-temp-esc 'stats-temp-motor 'stats-angle-pitch))

    (view-draw-menu nil nil "UNITS" 'arrow-right)
    (view-render-menu)
    (disp-render buf-stripe-bg 5 68 '(0x000000 0x1e9af3 0x22c7ff 0x22c7ff))
    (def buf-stripe-bg nil)
    (disp-render buf-motor-icon 8 10 '(0x000000 0x4f514f 0x929491 0xfbfcfc))
    (disp-render buf-esc-icon 64 10 '(0x000000 0x4f514f 0x929491 0xfbfcfc))
    (disp-render buf-battery-icon 126 10 '(0x000000 0x4f514f 0x929491 0xfbfcfc))
})

(defun view-draw-dash-primary () {
    (if (not-eq stats-kmh (first view-previous-stats)) {
        ; Update Speed
        (img-clear buf-units)
        (draw-units buf-units 0 0 1 font15)

        (img-clear buf-speed)
        (var speed-now (match (car settings-units) 
            (kmh stats-kmh)
            (mph (* stats-kmh 0.621371))
            (_ (print "Unexpected settings-units value"))
        ))
        (txt-block-c buf-speed 1 87 0 font88 (str-from-n speed-now "%0.0f"))
    })
    (if (not-eq (to-i (* 100 stats-battery-soc)) (second view-previous-stats)) {
        ; Update Battery %
        (img-clear buf-battery)
        (var displayed-soc (* 100 stats-battery-soc))
        (if (< displayed-soc 0) (setq displayed-soc 0))
        (draw-battery-soc buf-battery 38 140 font15 (to-i displayed-soc))
    })

    (if (not-eq stats-temp-battery (ix view-previous-stats 2)) {
        (img-clear buf-battery-val)
        (txt-block-c buf-battery-val 1 (/ (first (img-dims buf-battery-icon)) 2) 0 font18 (str-from-n (to-i stats-temp-battery) "%dC"))
    })
    (if (not-eq stats-temp-esc (ix view-previous-stats 3)) {
        (img-clear buf-esc-val)
        (txt-block-c buf-esc-val 1 (/ (first (img-dims buf-esc-icon)) 2) 0 font18 (str-from-n (to-i stats-temp-esc) "%dC"))
    })
    (if (not-eq stats-temp-motor (ix view-previous-stats 4)) {
        (img-clear buf-motor-val)
        (txt-block-c buf-motor-val 1 (/ (first (img-dims buf-motor-icon)) 2) 0 font18 (str-from-n (to-i stats-temp-motor) "%dC"))
    })

    (if (not-eq stats-angle-pitch (ix view-previous-stats 5)) {
        (img-clear buf-incline)
        (var hill-grade (* (tan (abs stats-angle-pitch)) 100))
        (txt-block-l buf-incline 1 0 13 font18 (str-merge (str-from-n (to-i hill-grade) "%d") "%"))

        (var font-w (bufget-u8 font18 1))
        (var buf-height (second (img-dims buf-incline)))
        (var angle-displayed (* (abs stats-angle-pitch) 57.2958))
        (if (> angle-displayed 45.0) (setq angle-displayed 45.0))
        (img-line buf-incline (* font-w 2) ; x1
            (- buf-height 1) ;y1 at bottom
            (first (img-dims buf-incline)) ;x2 at right end
            (- (- buf-height 1) (* (- buf-height 1) (/ angle-displayed 45.0 ))) ;y2 is max buf-height
            1
        )
    })
})

(defun view-render-dash-primary () {
    (if (not-eq stats-kmh (first view-previous-stats)) {
        (disp-render buf-speed 0 105 '(0x000000 0xfbfcfc))
        (disp-render buf-units 175 187 '(0x000000 0xf4f7f9))
    })
    
    (if (not-eq (to-i (* 100 stats-battery-soc)) (second view-previous-stats)) {
        (var color 0x7f9a0d)
        (if (< stats-battery-soc 0.5)
            (setq color (lerp-color 0xe72a62 0xffa500 (ease-in-out-quint (* stats-battery-soc 2))))
            (setq color (lerp-color 0xffa500 0x7f9a0d (ease-in-out-quint (* (- stats-battery-soc 0.5) 2))))
        )
        (disp-render buf-battery 265 75 `(0x000000 0xfbfcfc ,color 0x0000ff))
    })

    (if (not-eq stats-temp-motor (ix view-previous-stats 4)) {
        (disp-render buf-motor-val 8 44 '(0x000000 0xfbfcfc))
    })
    (if (not-eq stats-temp-battery (ix view-previous-stats 2)) {
        (disp-render buf-battery-val 126 44 '(0x000000 0xfbfcfc))
    })
    (if (not-eq stats-temp-esc (ix view-previous-stats 3)) {
        (disp-render buf-esc-val 64 44 '(0x000000 0xfbfcfc))
    })

    (if (not-eq stats-angle-pitch (ix view-previous-stats 5)) {
        (disp-render buf-incline 188 4 '(0x000000 0xfbfcfc))
    })

    (def view-previous-stats (list stats-kmh (to-i (* 100 stats-battery-soc)) stats-temp-battery stats-temp-esc stats-temp-motor stats-angle-pitch))

    (if (> (length stats-fault-codes-observed) 0) {
        (disp-render buf-warning-icon 206 46 '(0x000000 0xff0000 0x929491 0xfbfcfc))
    })
})

(defun view-cleanup-dash-primary () {
    (def buf-stripe-bg nil)
    (def buf-motor-icon nil)
    (def buf-esc-icon nil)
    (def buf-battery-icon nil)
    (def buf-warning-icon nil)
    (def buf-motor-val nil)
    (def buf-esc-val nil)
    (def buf-battery-val nil)
    (def buf-battery nil)
    (def buf-speed nil)
    (def buf-units nil)
})
