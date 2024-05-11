@const-start

(defun view-init-statistics () {
    (var radius 95)
    (var x-offs 10)
    (var y-offs 10)

    ; Quarter guage buffer (re-used for each quadrant to save memory)
    (def buf-gauge (img-buffer 'indexed16 radius radius))
    (def buf-efficiency (img-buffer 'indexed2 92 55))
    (def buf-trip (img-buffer 'indexed2 92 55))
    (def buf-range (img-buffer 'indexed2 92 55))

    (defun on-btn-0-pressed () {
        (def state-view-next 'view-speed-large)
    })

    (defun on-btn-3-pressed () {
        (def state-view-next 'view-minigame)
    })

    ; Render menu
    (view-draw-menu 'arrow-left nil nil 'arrow-right)
    (view-render-menu)

    ; Render gauge background
    (var img (img-buffer 'indexed2 (* radius 2) 2))
    (img-line img 0 0 (* radius 2) 0 1 '(thickness 2))
    (disp-render img x-offs (+ (+ y-offs radius) 2) '(0x000000 0x1b1b1b))
    (var img (img-buffer 'indexed2 2 (* radius 2)))
    (img-line img 0 0 0 (* radius 2) 1 '(thickness 2))
    (disp-render img (+ (+ x-offs radius) 2) y-offs '(0x000000 0x1b1b1b))

    ; Watch for value changes
    (def view-previous-stats (list 'stats-amps-now 'stats-wh 'stats-wh-chg 'stats-km))
})

(defun view-draw-statistics () {
    ;stats-amps-now
    ;stats-wh
    ;stats-wh-chg
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

    (var radius 95)
    (var padding 6)
    (var x-offs 10)
    (var y-offs 10)

    (if (not-eq stats-amps-now (first view-previous-stats)) {
        ; Max Amps Regen
        (img-clear buf-gauge)
        (draw-gauge-quadrant buf-gauge radius radius radius 1 2 17 0 (if (and (< stats-amps-now 0) (> stats-amps-max 0)) (/ (to-float (abs stats-amps-now)) stats-amps-max) 0) true true nil 4)
        (txt-block-r buf-gauge 3 radius 52 font18 (list (if (< stats-amps-now 0) (str-from-n stats-amps-now "%dA") "0A") (str-from-n stats-amps-now-min "%dA")))
        (disp-render buf-gauge x-offs y-offs '(0x000000 0x0000ff 0x1b1b1b 0xfbfcfc 0x4f4f4f))

        ; Max Amps
        (img-clear buf-gauge)
        (draw-gauge-quadrant buf-gauge 0 radius radius 1 2 17 1 (if (and (> stats-amps-now 0) (> stats-amps-max 0)) (/ (to-float stats-amps-now) stats-amps-max) 0.0) nil true (if (> stats-amps-max 0) (/ (to-float stats-amps-avg) stats-amps-max) 0) 4)
        (txt-block-l buf-gauge 3 4 52 font18 (list (if (> stats-amps-now 0) (str-from-n stats-amps-now "%dA") "0A") (str-from-n stats-amps-now-max "%dA")))
        (disp-render buf-gauge (+ padding (+ x-offs radius)) y-offs '(0x000000 0x00d8ff 0x1b1b1b 0xfbfcfc 0x4f4f4f))
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
        (txt-block-l buf-gauge 3 4 4 font18 (list wh-out-str "out"))
        (disp-render buf-gauge (+ padding (+ x-offs radius)) (+ padding (+ y-offs radius)) '(0x000000 0xfbd00a 0x1b1b1b 0xfbfcfc))

        ; Watt Hours Regenerated
        (img-clear buf-gauge)
        (draw-gauge-quadrant buf-gauge radius 0 radius 1 2 17 3 (if (> stats-wh-chg 0) (/ stats-wh-chg (+ stats-wh stats-wh-chg)) 0) nil nil nil nil)
        (var wh-in-str (cond
            ((< stats-wh-chg 10.0) (str-from-n stats-wh-chg "%0.1fWh"))
            ((< stats-wh-chg 1000.0) (str-from-n (to-i stats-wh-chg) "%dWh"))
            (_ (str-from-n (/ stats-wh-chg 1000)"%0.1fkWh"))
        ))
        (txt-block-r buf-gauge 3 radius 4 font18 (list wh-in-str "in"))
        (disp-render buf-gauge x-offs (+ padding (+ y-offs radius)) '(0x000000 0x97bf0d 0x1b1b1b 0xfbfcfc))
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
