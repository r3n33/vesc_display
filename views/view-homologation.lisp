@const-start

(defun view-init-homologation  () {
    (def buf-stripe-bg (img-buffer-from-bin icon-stripe))
    (def buf-stripe-fg (img-buffer 'indexed16 141 19))
    (def buf-stripe-top (img-buffer-from-bin icon-stripe-top))
    (def buf-arrow-l (img-buffer-from-bin icon-arrow-l))
    (def buf-arrow-r (img-buffer-from-bin icon-arrow-r))
    (img-blit buf-stripe-fg buf-stripe-top 0 0 -1)

    (def buf-warning-icon (img-buffer-from-bin icon-warning))

    (def buf-battery (img-buffer 'indexed4 42 120))
    (def buf-battery-soc (img-buffer 'indexed4 50 20))
    
    (def buf-speed (img-buffer 'indexed4 179 90))
    (def buf-units (img-buffer 'indexed4 50 15))

    (def buf-blink-left (img-buffer-from-bin icon-blinker-left))
    (def buf-blink-right (img-buffer-from-bin icon-blinker-right))
    (def buf-cruise-control (img-buffer-from-bin icon-cruise-control))
    (def buf-lights (img-buffer-from-bin icon-lights))
    (def buf-highbeam (img-buffer-from-bin icon-highbeam))
    (def buf-kickstand (img-buffer-from-bin icon-kickstand))

    (var colors-red-icon '(0x000000 0x570001 0xa70001 0xfd0303))
    (var colors-green-icon '(0x000000 0x005400 0x00b800 0x00ff00))
    (var colors-blue-icon '(0x000000 0x020040 0x000077 0x1d00e8))
    (var colors-dim-icon '(0x000000 0x090909 0x101010 0x171717))

    (disp-render buf-blink-left 1 1 colors-green-icon)
    (disp-render buf-blink-right (- 319 (first (img-dims buf-blink-right))) 1 colors-dim-icon)
    (disp-render buf-cruise-control 10 44 colors-dim-icon)
    (disp-render buf-lights 165 1 colors-green-icon)
    (disp-render buf-highbeam 104 1 colors-blue-icon)
    (disp-render buf-kickstand 265 116 colors-red-icon)

    (def test-blink-on true)
    (def test-blink-anim-time (systime))
    (def test-blink-anim-duration 0.75)
    (def buf-blink-anim (img-buffer 'indexed4 62 18))
    (var colors-anim '(0x000000 0x000000 0x171717 0x00ff00))
    (draw-turn-animation buf-blink-anim 'left (clamp01 (/ (secs-since test-blink-anim-time) test-blink-anim-duration)))
    (disp-render buf-blink-anim 38 11 colors-anim) ; Left side

    (view-init-menu)
    (defun on-btn-0-long-pressed () {
        (hw-sleep)
    })
    (defun on-btn-2-pressed () {
        (setting-units-cycle)
        (setix view-previous-stats 0 'stats-kmh) ; Re-draw units

    })
    (defun on-btn-2-long-pressed () {
        (setting-units-cycle-temps)

    })
    (defun on-btn-3-pressed () (def state-view-next (next-view)))

    (def view-previous-stats (list 'stats-kmh 'stats-battery-soc))

    (disp-render buf-stripe-bg 5 93
        '(
            0x000000
            0x1d9af7 ; top fg
            0x1574b6 ; 2
            0x0e5179 ; 3
            0x143e59 ; 4
            0x0e222f ; 5
            0x00c7ff ; bottom fg
            0x10b2e6 ; 7
            0x1295bf ; 8
            0x0984ac ; 9
            0x007095 ; a
            0x0e5179 ; b
            0x08475c ; c
            0x143e59 ; d
            0x0e222f ; e
        ))
    (def buf-stripe-bg nil)
})

(defun view-draw-homologation () {
    (if (not-eq stats-kmh (first view-previous-stats)) {
        ; Update Speed
        (img-clear buf-units)
        (draw-units buf-units 0 0 (list 0 1 2 3) font15)

        (img-clear buf-speed)
        (var speed-now (match (car settings-units-speeds)
            (kmh stats-kmh)
            (mph (* stats-kmh km-to-mi))
            (_ (print "Unexpected settings-units-speeds value"))
        ))
        (txt-block-c buf-speed (list 0 1 2 3) 87 0 font88 (str-from-n speed-now "%0.0f"))

        ; Update Speed Arrow
        (var arrow-x-max (- 141 24))
        (def arrow-x (if (> stats-kmh-max 0.0)
            (* arrow-x-max (/ stats-kmh stats-kmh-max))
            0
        ))
        (img-blit buf-stripe-fg buf-stripe-top 0 0 -1)
        (if (> arrow-x 0) {
            ; Fill area behind arrow
            (img-rectangle buf-stripe-fg 0 0 arrow-x 19 1 '(filled))
        })
        (img-blit buf-stripe-fg buf-arrow-l arrow-x 0 -1)
        (img-blit buf-stripe-fg buf-arrow-r (+ arrow-x 12) 0 -1)
    })
    (if (not-eq (to-i (* 100 stats-battery-soc)) (second view-previous-stats)) {
        ; Update Battery %
        (img-clear buf-battery)
        (var displayed-soc (* 100 stats-battery-soc))
        (if (< displayed-soc 0) (setq displayed-soc 0))
        (draw-battery-soc buf-battery 38 (second (img-dims buf-battery)) stats-battery-soc)

        (img-clear buf-battery-soc)
        (txt-block-c buf-battery-soc (list 0 1 2 3) (/ (first (img-dims buf-battery-soc)) 2) 0 font15 (str-merge (str-from-n displayed-soc "%0.0f") "%"))
    })

    (var colors-green-icon '(0x000000 0x005400 0x00b800 0x00ff00))
    (var colors-dim-icon '(0x000000 0x090909 0x101010 0x171717))
    (var colors-anim '(0x000000 0x000000 0x171717 0x00ff00))
    (var anim-pct (clamp01 (/ (secs-since test-blink-anim-time) test-blink-anim-duration)))
    (draw-turn-animation buf-blink-anim 'left anim-pct)
    (disp-render buf-blink-anim 38 11 colors-anim) ; Left side

    (draw-turn-animation buf-blink-anim 'right anim-pct)
    (disp-render buf-blink-anim 218 11 colors-anim) ; Right side

    (if (eq anim-pct 1.0) {
        ; Alternate indicator illumination
        (if test-blink-on {
            (disp-render buf-blink-left 1 1 colors-dim-icon)
            (disp-render buf-blink-right (- 319 (first (img-dims buf-blink-right))) 1 colors-dim-icon)
            (def test-blink-on false)
        } {
            (disp-render buf-blink-left 1 1 colors-green-icon)
            (disp-render buf-blink-right (- 319 (first (img-dims buf-blink-right))) 1 colors-green-icon)
            (def test-blink-on true)
        })
        ; Reset animation time
        (def test-blink-anim-time (systime))
    })
})

(defun view-render-homologation () {
    (var colors-text-aa '(0x000000 0x4f514f 0x929491 0xfbfcfc))
    (if (not-eq stats-kmh (first view-previous-stats)) {
        (disp-render buf-speed 0 130 colors-text-aa)
        (disp-render buf-units 175 222 colors-text-aa)

        (disp-render buf-stripe-fg 5 93
            '(
                0x000000
                0x1d9af7 ; top fg
                0x1574b6 ; 2
                0x0e5179 ; 3
                0x143e59 ; 4
                0x0e222f ; 5
                0x00c7ff ; bottom fg
                0x10b2e6 ; 7
                0x1295bf ; 8
                0x0984ac ; 9
                0x007095 ; a
                0x0e5179 ; b
                0x08475c ; c
                0x143e59 ; d
                0x0e222f ; e
            ))
    })
    
    (if (not-eq (to-i (* 100 stats-battery-soc)) (second view-previous-stats)) {
        (var color 0x7f9a0d)
        (if (< stats-battery-soc 0.5)
            (setq color (lerp-color 0xe72a62 0xffa500 (ease-in-out-quint (* stats-battery-soc 2))))
            (setq color (lerp-color 0xffa500 0x7f9a0d (ease-in-out-quint (* (- stats-battery-soc 0.5) 2))))
        )
        ;(disp-render buf-battery 265 120 `(0x000000 0xfbfcfc ,color 0x0000ff))
        ;(disp-render buf-battery-soc 261 100 colors-text-aa)
    })

    (def view-previous-stats (list stats-kmh (to-i (* 100 stats-battery-soc))))

    (if (> (length stats-fault-codes-observed) 0) {
        (disp-render buf-warning-icon 206 71 '(0x000000 0xff0000 0x929491 0xfbfcfc))
    })
})

(defun view-cleanup-homologation () {
    (def buf-stripe-bg nil)
    (def buf-stripe-fg nil)
    (def buf-stripe-top nil)
    (def buf-arrow-l nil)
    (def buf-arrow-r nil)
    
    (def buf-warning-icon nil)

    (def buf-battery nil)

    (def buf-speed nil)
    (def buf-units nil)
})
