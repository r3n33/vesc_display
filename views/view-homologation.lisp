

@const-start

(defun view-init-homologation  () {
    (def buf-stripe-bg (img-buffer-from-bin icon-stripe))
    (def buf-stripe-fg (img-buffer 'indexed16 141 19))
    (def buf-stripe-top (img-buffer-from-bin icon-stripe-top))
    (def buf-arrow-l (img-buffer-from-bin icon-arrow-l))
    (def buf-arrow-r (img-buffer-from-bin icon-arrow-r))
    (img-blit buf-stripe-fg buf-stripe-top 0 0 -1)

    (def buf-warning-icon (img-buffer-from-bin icon-warning))

    (def buf-battery-a-sm (img-buffer 'indexed4 20 62))
    (def buf-battery-b-sm (img-buffer 'indexed4 20 62))
    (def buf-battery-a-sm-soc (img-buffer 'indexed4 20 50))
    (def buf-battery-b-sm-soc (img-buffer 'indexed4 20 50))
    
    (def buf-speed (img-buffer 'indexed4 179 90))
    (def buf-units (img-buffer 'indexed4 50 15))

    (def buf-blink-left (img-buffer-from-bin icon-blinker-left))
    (def buf-blink-right (img-buffer-from-bin icon-blinker-right))
    (def buf-cruise-control (img-buffer-from-bin icon-cruise-control))
    (def buf-lights (img-buffer-from-bin icon-lights))
    (def buf-highbeam (img-buffer-from-bin icon-highbeam))
    (def buf-kickstand (img-buffer-from-bin icon-kickstand))
    (def buf-neutral-mode (img-buffer-from-bin icon-neutral))
    (def buf-drive-mode (img-buffer-from-bin icon-drive))
    (def buf-performance-mode (img-buffer 'indexed4 50 20))

    (disp-render buf-blink-left 1 1 colors-dim-icon)
    (disp-render buf-blink-right (- 319 (first (img-dims buf-blink-right))) 1 colors-dim-icon)
    (disp-render buf-cruise-control 10 44 colors-dim-icon)
    (disp-render buf-lights 165 1 colors-green-icon)
    (disp-render buf-highbeam 104 1 colors-dim-icon)
    (disp-render buf-kickstand 270 116 colors-red-icon)
    (disp-render buf-warning-icon 190 50 colors-dim-icon)
    (disp-render buf-neutral-mode 270 172 colors-green-icon)

    ; Buffer used for L and R Indicator Animations
    (def buf-indicate-anim (img-buffer 'indexed4 62 18))

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

    (def view-previous-stats (list 'stats-kmh 'stats-battery-soc 'highbeam-on 'kickstand-down 'drive-mode 'performance-mode))

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
    ; Draw Speed
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

    ; Draw Batteries
    (if (not-eq (to-i (* 100 stats-battery-soc)) (second view-previous-stats)) {
        ; Update Battery %
        (img-clear buf-battery-a-sm)
        (img-clear buf-battery-b-sm)
        (var displayed-soc (* 100 stats-battery-soc))
        (if (< displayed-soc 0) (setq displayed-soc 0))

        ; Battery A
        (draw-battery-soc buf-battery-a-sm (first (img-dims buf-battery-a-sm)) (second (img-dims buf-battery-a-sm)) stats-battery-soc 1)
        (img-clear buf-battery-a-sm-soc)
        (txt-block-v buf-battery-a-sm-soc (list 0 1 2 3) (first (img-dims buf-battery-a-sm-soc)) (second (img-dims buf-battery-a-sm-soc)) font15 (str-merge "%" (str-from-n displayed-soc "%0.0f")))

        ; TODO: Fake Battery B Value
        (draw-battery-soc buf-battery-b-sm (first (img-dims buf-battery-b-sm)) (second (img-dims buf-battery-b-sm)) stats-battery-soc 1)
        (img-clear buf-battery-b-sm-soc)
        (txt-block-v buf-battery-b-sm-soc (list 0 1 2 3) (first (img-dims buf-battery-b-sm-soc)) (second (img-dims buf-battery-b-sm-soc)) font15 (str-merge "%" (str-from-n displayed-soc "%0.0f")))
    })

    ; TODO: Indicator testing
    (var colors-anim '(0x000000 0x000000 0x171717 0x00ff00))
    (var anim-pct 1.0)
    (if (> indicate-ms 0)
        (setq anim-pct (clamp01 (/ (secs-since indicator-timestamp) (/ indicate-ms 1000.0))))
    )
    (if indicate-l-on {
        (draw-turn-animation buf-indicate-anim 'left anim-pct)
        (disp-render buf-indicate-anim 38 11 colors-anim) ; Left side
        (disp-render buf-blink-left 1 1 colors-green-icon)
    } (disp-render buf-blink-left 1 1 colors-dim-icon))

    (if indicate-r-on {
        (draw-turn-animation buf-indicate-anim 'right anim-pct)
        (disp-render buf-indicate-anim 218 11 colors-anim) ; Right side
        (disp-render buf-blink-right (- 319 (first (img-dims buf-blink-right))) 1 colors-green-icon)
    } (disp-render buf-blink-right (- 319 (first (img-dims buf-blink-right))) 1 colors-dim-icon))

    ; Performance Mode
    (if (not-eq performance-mode (ix view-previous-stats 5)) {
        (match performance-mode
            (eco (txt-block-c buf-performance-mode (list 0 1 2 3) (/ (first (img-dims buf-performance-mode)) 2) 0 font18 (to-str "ECO")))
            (normal (txt-block-c buf-performance-mode (list 0 1 2 3) (/ (first (img-dims buf-performance-mode)) 2) 0 font18 (to-str "NML")))
            (sport (txt-block-c buf-performance-mode (list 0 1 2 3) (/ (first (img-dims buf-performance-mode)) 2) 0 font18 (to-str "SPT")))
        )
    })
})

(defun view-render-homologation () {

    ; Highbeam
    (if (not-eq highbeam-on (third view-previous-stats)) {
        (if highbeam-on
            (disp-render buf-highbeam 104 1 colors-blue-icon)
            (disp-render buf-highbeam 104 1 colors-dim-icon)
        )
    })

    ; Kickstand Area
    (if (not-eq kickstand-down (ix view-previous-stats 3)) {
        (if kickstand-down {
            ; TODO: Render Large batteries

            ; TODO: Temporarily clearing large speed
            {
                (disp-render buf-speed 0 130 '(0x0 0x0 0x0 0x0))
            }

            ; Clear small batteries
            (disp-render buf-battery-a-sm 262 92 '(0x0 0x0 0x0 0x0))
            (disp-render buf-battery-a-sm-soc 262 40 '(0x0 0x0 0x0 0x0))
            (disp-render buf-battery-b-sm 288 92 '(0x0 0x0 0x0 0x0))
            (disp-render buf-battery-b-sm-soc 288 40 '(0x0 0x0 0x0 0x0))

            ; Show kickstand down icon
            (disp-render buf-kickstand 270 116 colors-red-icon)
        } (disp-render buf-kickstand 270 116 '(0x0 0x0 0x0 0x0)))

        (setix view-previous-stats 0 'update-speed)
        (setix view-previous-stats 1 'update-battery-soc)
    })

    ; Speed Now
    (if (not kickstand-down)
        (if (not-eq stats-kmh (first view-previous-stats)) {
            (disp-render buf-speed 0 130 colors-white-icon)
            (disp-render buf-units 175 222 colors-white-icon)

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
    )

    ; Batteries (after processing kickstand-down)
    (if (not-eq (to-i (* 100 stats-battery-soc)) (second view-previous-stats)) {
        (var color 0x7f9a0d)
        (if (< stats-battery-soc 0.5)
            (setq color (lerp-color 0xe72a62 0xffa500 (ease-in-out-quint (* stats-battery-soc 2))))
            (setq color (lerp-color 0xffa500 0x7f9a0d (ease-in-out-quint (* (- stats-battery-soc 0.5) 2))))
        )

        (if (not kickstand-down) {
            (disp-render buf-battery-a-sm 262 92 `(0x000000 0xfbfcfc ,color 0x0000ff))
            (disp-render buf-battery-a-sm-soc 259 40 colors-white-icon)

            ; TODO: Fake Battery B Value
            (disp-render buf-battery-b-sm 288 92 `(0x000000 0xfbfcfc ,color 0x0000ff))
            (disp-render buf-battery-b-sm-soc 285 40 colors-white-icon)
        })
    })

    ; Drive Mode
    (if (not-eq drive-mode-active (ix view-previous-stats 4)) {
        (if drive-mode-active
            (disp-render buf-drive-mode 270 172 colors-white-icon)
            (disp-render buf-neutral-mode 270 172 colors-green-icon)
        )
    })

    ; Performance Mode
    (if (not-eq performance-mode (ix view-previous-stats 5)) {
        (disp-render buf-performance-mode 262 220 colors-white-icon)
    })

    ; Update stats for improved performance
    (def view-previous-stats (list
        stats-kmh
        (to-i (* 100 stats-battery-soc))
        highbeam-on
        kickstand-down
        drive-mode-active
        performance-mode
    ))

    ; Render Warning Icon
    (if (> (length stats-fault-codes-observed) 0) {
        (disp-render buf-warning-icon 190 50 '(0x000000 0xff0000 0x929491 0xfbfcfc))
    })
})

(defun view-cleanup-homologation () {
    (def buf-stripe-bg nil)
    (def buf-stripe-fg nil)
    (def buf-stripe-top nil)
    (def buf-arrow-l nil)
    (def buf-arrow-r nil)
    
    (def buf-warning-icon nil)

    (def buf-battery-a-sm nil)
    (def buf-battery-a-sm-soc nil)

    (def buf-battery-b-sm nil)
    (def buf-battery-b-sm-soc nil)

    (def buf-speed nil)
    (def buf-units nil)
})
