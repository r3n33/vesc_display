@const-start

(defun view-init-statistics () {
    (var buf-size 104)
    (var spacing 8)
    (var x-offs 0)
    (var y-offs 0)

    ; Quarter guage buffer (re-used for each quadrant to save memory)
    (def buf-gauge (img-buffer 'indexed16 buf-size buf-size))
    (def buf-efficiency (img-buffer 'indexed2 92 55))
    (def buf-trip (img-buffer 'indexed2 92 55))
    (def buf-range (img-buffer 'indexed2 92 55))

    (defun on-btn-0-pressed () {
        (def state-view-next 'view-speed-large)
    })

    ; Render menu
    (view-draw-menu 'arrow-left nil nil nil)
    (view-render-menu)

    ; Render gauge background
    (var img (img-buffer 'indexed2 (* buf-size 2) 2))
    (img-line img spacing 0 (- (* buf-size 2) spacing -1) 0 1 '(thickness 2))
    (disp-render img (+ x-offs 2) (+ y-offs buf-size 2) '(0x000000 0x1b1b1b))

    (var img (img-buffer 'indexed2 2 (* buf-size 2)))
    (img-line img 0 spacing 0 (- (* buf-size 2) spacing -1) 1 '(thickness 2))
    (disp-render img (+ x-offs buf-size 2) (+ y-offs 2) '(0x000000 0x1b1b1b))

    ; Watch for value changes
    (def view-previous-stats (list 'stats-amps-now 'stats-wh 'stats-wh-chg 'stats-km))
})

(defun view-draw-statistics () {
    ; Drawing 3 boxes on right
    (if (not-eq stats-km (ix view-previous-stats 3)) {
        (img-clear buf-efficiency)
        (img-clear buf-trip)
        (img-clear buf-range)

        (def whkm 0)
        (if (> stats-km 0.0) (setq whkm (/ (- stats-wh stats-wh-chg) stats-km)))
        (txt-block-l buf-efficiency 1 0 0 font18 (list "Wh/km" (if (> whkm 10.0)
            (str-from-n (to-i whkm) "%d")
            (str-from-n whkm "%0.2f")
        )))

        (txt-block-l buf-trip 1 0 0 font18 (list "Trip" (str-from-n stats-km (if (> stats-km 99.9) "%0.0fkm" "%0.1fkm"))))

        ; Calculate range
        (var ah-remaining (* stats-battery-ah stats-battery-soc))
        (var wh-remaining (* ah-remaining stats-vin))
        (var range-remaining 0)
        (if (> whkm 0) (setq range-remaining (/ wh-remaining whkm))) 
        (txt-block-l buf-range 1 0 0 font18 (list "Range" (if (> range-remaining 10.0)
            (str-from-n (to-i range-remaining) "%dkm")
            (str-from-n range-remaining "%0.1fkm")
        )))
    })
})

(defun view-render-statistics () {
    (var buf-size 104)
    (var spacing 8)
    (var radius 94)
    (var padding 8)
    (var x-offs 0)
    (var y-offs 0)

    (if (not-eq stats-amps-now (first view-previous-stats)) {
        ; Max Amps Regen
        (img-clear buf-gauge)
        (draw-gauge-quadrant buf-gauge buf-size buf-size radius 1 2 17 0 (if (and (< stats-amps-now 0) (< stats-amps-now-min 0)) (/ (to-float (abs stats-amps-now)) (abs stats-amps-now-min)) 0) true (< stats-amps-now 1) nil 4)
        (txt-block-r buf-gauge 3 buf-size 64 font18 (list (if (< stats-amps-now 0) (str-from-n stats-amps-now "%dA") "0A") (str-from-n stats-amps-now-min "%dA")))
        (disp-render buf-gauge x-offs y-offs '(0x000000 0x0000ff 0x1b1b1b 0xfbfcfc 0x4f4f4f))

        ; Max Amps
        (img-clear buf-gauge)
        (draw-gauge-quadrant buf-gauge 0 buf-size radius 1 2 17 1 (if (and (> stats-amps-now 0) (> stats-amps-now-max 0)) (/ (to-float stats-amps-now) stats-amps-now-max) 0.0) nil (> stats-amps-now -1) (if (> stats-amps-now-max 0) (/ (to-float stats-amps-avg) stats-amps-now-max) 0) 4)
        (txt-block-l buf-gauge 3 0 64 font18 (list (if (> stats-amps-now 0) (str-from-n stats-amps-now "%dA") "0A") (str-from-n stats-amps-now-max "%dA")))
        (disp-render buf-gauge (+ spacing padding (+ x-offs radius)) y-offs '(0x000000 0x00d8ff 0x1b1b1b 0xfbfcfc 0x4f4f4f))
    })
    (if (or 
            (not-eq stats-wh (second view-previous-stats))
            (not-eq stats-wh-chg (third view-previous-stats))
        ) {
        ; Watt Hours Consumed
        (img-clear buf-gauge)
        (draw-gauge-quadrant buf-gauge 0 0 radius 1 2 17 2 (if (> stats-wh 0) (/ stats-wh (+ stats-wh stats-wh-chg)) 0) true nil nil nil)
        (var wh-out-str (cond
            ((< stats-wh 10.0) (str-from-n stats-wh "%0.1fWh"))
            ((< stats-wh 1000.0) (str-from-n (to-i stats-wh) "%dWh"))
            (_ (str-from-n (/ stats-wh 1000) "%0.1fkWh"))
        ))
        (txt-block-l buf-gauge 3 0 0 font18 (list wh-out-str "out"))
        (disp-render buf-gauge (+ spacing padding (+ x-offs radius)) (+ spacing padding (+ y-offs radius)) '(0x000000 0xfbd00a 0x1b1b1b 0xfbfcfc))

        ; Watt Hours Regenerated
        (img-clear buf-gauge)
        (draw-gauge-quadrant buf-gauge buf-size 0 radius 1 2 17 3 (if (> stats-wh-chg 0) (/ stats-wh-chg (+ stats-wh stats-wh-chg)) 0) nil nil nil nil)
        (var wh-in-str (cond
            ((< stats-wh-chg 10.0) (str-from-n stats-wh-chg "%0.1fWh"))
            ((< stats-wh-chg 1000.0) (str-from-n (to-i stats-wh-chg) "%dWh"))
            (_ (str-from-n (/ stats-wh-chg 1000)"%0.1fkWh"))
        ))
        (txt-block-r buf-gauge 3 buf-size 0 font18 (list wh-in-str "in"))
        (disp-render buf-gauge x-offs (+ spacing padding (+ y-offs radius)) '(0x000000 0x97bf0d 0x1b1b1b 0xfbfcfc))
    })


    (if (not-eq stats-km (ix view-previous-stats 3)) {
        (disp-render buf-efficiency 215 12 '(0x000000 0xfbfcfc))

        (disp-render buf-trip 215 84 '(0x000000 0xfbfcfc))

        (disp-render buf-range 215 158 '(0x000000 0xfbfcfc))
    })
    
    (def view-previous-stats (list stats-amps-now stats-wh stats-wh-chg stats-km))
})

(defun view-cleanup-statistics () {
    (def buf-gauge nil)
    (def buf-efficiency nil)
    (def buf-trip nil)
    (def buf-range nil)
})
