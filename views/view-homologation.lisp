(def view-state-now (list))
(def view-state-previous (list))

@const-start

(defun spooky-light-glitch () {
    (var start-time (systime))
    (loopwhile (< (secs-since start-time) 2.5) {
        (disp-render buf-lights 165 1 colors-dim-icon)
        (sleep (/ (mod (rand) 200) 1000.0))
        (disp-render buf-lights 165 1 colors-green-icon)
        (sleep (/ (mod (rand) 200) 1000.0))
    })
})

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
    
    (def buf-speed (img-buffer 'indexed16 179 90))
    (def buf-units (img-buffer 'indexed4 50 15))

    (def buf-blink-left (img-buffer-from-bin icon-blinker-left))
    (def buf-blink-right (img-buffer-from-bin icon-blinker-right))
    (def buf-indicate-l-anim (img-buffer 'indexed4 62 18))
    (def buf-indicate-r-anim (img-buffer 'indexed4 62 18))
    (def buf-cruise-control (img-buffer-from-bin icon-cruise-control))
    (def buf-lights (img-buffer-from-bin icon-lights))
    (def buf-highbeam (img-buffer-from-bin icon-highbeam))
    (def buf-kickstand (img-buffer-from-bin icon-kickstand))
    (def buf-neutral-mode (img-buffer-from-bin icon-neutral))
    (def buf-drive-mode (img-buffer-from-bin icon-drive))
    (def buf-performance-mode (img-buffer 'indexed4 50 20))
    (def buf-charge-bolt (img-buffer-from-bin icon-charge-bolt))

    (disp-render buf-blink-left 1 1 colors-dim-icon)
    (disp-render buf-blink-right (- 319 (first (img-dims buf-blink-right))) 1 colors-dim-icon)
    (disp-render buf-cruise-control 10 44 colors-dim-icon)
    (disp-render buf-lights 165 1 colors-green-icon)
    (disp-render buf-highbeam 104 1 colors-dim-icon)
    (disp-render buf-kickstand 270 116 colors-red-icon)
    (disp-render buf-warning-icon 190 50 colors-dim-icon)
    (disp-render buf-neutral-mode 270 172 colors-green-icon)

    (if btn-3-pressed (spooky-light-glitch))

    (view-init-menu)
    (defun on-btn-0-long-pressed () {
        (hw-sleep)
    })
    (defun on-btn-2-pressed () {
        (setting-units-cycle)
        (setix view-state-previous 0 'stats-kmh) ; Re-draw units

    })
    (defun on-btn-2-long-pressed () {
        (setting-units-cycle-temps)

    })
    (defun on-btn-3-pressed () (def state-view-next (next-view)))

    (def view-state-now (list
        stats-kmh
        (to-i (* 100 stats-battery-soc))
        highbeam-on
        kickstand-down
        drive-mode-active
        performance-mode
        indicate-l-on
        indicate-r-on
    ))
    (def view-state-previous (list 'stats-kmh 'stats-battery-soc 'highbeam-on 'kickstand-down 'drive-mode 'performance-mode 'indicate-l-on 'indicate-r-on))

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

    ; Update state before buffering new content
    (def view-state-now (list
        stats-kmh
        (to-i (* 100 stats-battery-soc))
        highbeam-on
        kickstand-down
        drive-mode-active
        performance-mode
        indicate-l-on
        indicate-r-on
    ))

    ; Ensure re-draw between kickstand states
    (if (not-eq (ix view-state-now 3) (ix view-state-previous 3)) {
        (setix view-state-previous 0 'update-speed)
        (setix view-state-previous 1 'update-battery-soc)
    })

    ; Draw Speed
    (if (not-eq (ix view-state-now 0) (first view-state-previous)) {
        ; Update Speed
        (img-clear buf-units)
        (draw-units buf-units 0 0 (list 0 1 2 3) font15)

        (img-clear buf-speed)
        (var speed-now (match (car settings-units-speeds)
            (kmh (ix view-state-now 0))
            (mph (* (ix view-state-now 0) km-to-mi))
            (_ (print "Unexpected settings-units-speeds value"))
        ))
        (txt-block-c buf-speed (list 0 1 2 3) 87 0 font88 (str-from-n speed-now "%0.0f"))

        ; Update Speed Arrow
        (var arrow-x-max (- 141 24))
        (var arrow-x (if (> stats-kmh-max 0.0)
            (* arrow-x-max (/ (ix view-state-now 0) stats-kmh-max))
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
    (if (not-eq (ix view-state-now 1) (second view-state-previous)) {
        ; Update Battery %
        (img-clear buf-battery-a-sm)
        (img-clear buf-battery-b-sm)
        (var soc-now (/ (ix view-state-now 1) 100.0))
        (var displayed-soc (ix view-state-now 1))
        (if (< displayed-soc 0) (setq displayed-soc 0))

        ; Battery A
        (draw-battery-vertical buf-battery-a-sm (first (img-dims buf-battery-a-sm)) (second (img-dims buf-battery-a-sm)) soc-now 1)
        (img-clear buf-battery-a-sm-soc)
        (txt-block-v buf-battery-a-sm-soc (list 0 1 2 3) (first (img-dims buf-battery-a-sm-soc)) (second (img-dims buf-battery-a-sm-soc)) font15 (str-merge "%" (str-from-n displayed-soc "%d")))

        ; TODO: Fake Battery B Value
        (draw-battery-vertical buf-battery-b-sm (first (img-dims buf-battery-b-sm)) (second (img-dims buf-battery-b-sm)) soc-now 1)
        (img-clear buf-battery-b-sm-soc)
        (txt-block-v buf-battery-b-sm-soc (list 0 1 2 3) (first (img-dims buf-battery-b-sm-soc)) (second (img-dims buf-battery-b-sm-soc)) font15 (str-merge "%" (str-from-n displayed-soc "%d")))

        ; TODO: Large batteries
        (if (ix view-state-now 3) {
            (img-clear buf-speed)
            (draw-battery-horizontal buf-speed 18 0 130 27 soc-now 1 1 4)
            (draw-battery-horizontal buf-speed 18 47 130 27 soc-now 1 1 4)

            ; TODO: If charging show charge icon
            ;(img-blit buf-speed buf-charge-bolt 55 4 0)
            (img-blit buf-speed buf-charge-bolt 55 51 0)

            (txt-block-l buf-speed '(0 1 2 3) 20 28 font18 (str-merge (str-from-n displayed-soc "%d") "%"))
            ; TODO: If charging draw charge time remaining
            ;(if (< displayed-soc 100) (txt-block-r buf-speed '(0 1 2 3) 160 28 font18 (str-merge "2h10m")))

            ; TODO: Fake Battery B Value
            (txt-block-l buf-speed '(0 1 2 3) 20 74 font18 (str-merge (str-from-n displayed-soc "%d") "%"))
            ; TODO: If charging draw charge time remaining
            (if (< displayed-soc 100) (txt-block-r buf-speed '(0 1 2 3) 160 74 font18 (str-merge "1h28m")))
        })
    })

    ; Indicators
    (var anim-pct 1.0)
    (if (> indicate-ms 0)
        (setq anim-pct (clamp01 (/ (secs-since indicator-timestamp) (/ indicate-ms 1000.0))))
    )
    (if (ix view-state-now 6) (draw-turn-animation buf-indicate-l-anim 'left anim-pct))
    (if (ix view-state-now 7) (draw-turn-animation buf-indicate-r-anim 'right anim-pct))

    ; Indicator Left Completed
    (if (not-eq (ix view-state-now 6) (ix view-state-previous 6)) {
        (if (not (ix view-state-now 6)) (draw-turn-animation buf-indicate-l-anim 'left 1.0))
    })

    ; Indicator Right Completed
    (if (not-eq (ix view-state-now 7) (ix view-state-previous 7)) {
        (if (not (ix view-state-now 7)) (draw-turn-animation buf-indicate-r-anim 'right 1.0))
    })

    ; Performance Mode
    (if (not-eq (ix view-state-now 5) (ix view-state-previous 5)) {
        (match (ix view-state-now 5)
            (eco (txt-block-c buf-performance-mode (list 0 1 2 3) (/ (first (img-dims buf-performance-mode)) 2) 0 font18 (to-str "ECO")))
            (normal (txt-block-c buf-performance-mode (list 0 1 2 3) (/ (first (img-dims buf-performance-mode)) 2) 0 font18 (to-str "NML")))
            (sport (txt-block-c buf-performance-mode (list 0 1 2 3) (/ (first (img-dims buf-performance-mode)) 2) 0 font18 (to-str "SPT")))
        )
    })
})

(defun view-render-homologation () {

    (var colors-anim '(0x000000 0x000000 0x171717 0x00ff00))

    ; Indicator Left
    (if (ix view-state-now 6) (disp-render buf-indicate-l-anim 38 11 colors-anim))
    (if (not-eq (ix view-state-now 6) (ix view-state-previous 6)) {
        (if (ix view-state-now 6)
            (disp-render buf-blink-left 1 1 colors-green-icon)
            {
                (disp-render buf-blink-left 1 1 colors-dim-icon)
                (disp-render buf-indicate-l-anim 38 11 colors-anim)
            }
        )
    })

    ; Indicator Right
    (if (ix view-state-now 7) (disp-render buf-indicate-r-anim 218 11 colors-anim))
    (if (not-eq (ix view-state-now 7) (ix view-state-previous 7)) {
        (if (ix view-state-now 7)
            (disp-render buf-blink-right (- 319 (first (img-dims buf-blink-right))) 1 colors-green-icon)
            {
                (disp-render buf-blink-right (- 319 (first (img-dims buf-blink-right))) 1 colors-dim-icon)
                (disp-render buf-indicate-r-anim 218 11 colors-anim)
            }
        )
    })

    ; Highbeam
    (if (not-eq (ix view-state-now 2) (third view-state-previous)) {
        (if (ix view-state-now 2)
            (disp-render buf-highbeam 104 1 colors-blue-icon)
            (disp-render buf-highbeam 104 1 colors-dim-icon)
        )
    })

    ; Kickstand
    (if (not-eq (ix view-state-now 3) (ix view-state-previous 3)) {
        (if (ix view-state-now 3) {
            ; Render Speed buffer containing Large Batteries
            (disp-render buf-speed 0 130 colors-white-icon)
            (disp-render buf-units 175 222 '(0x0 0x0 0x0 0x0)) ; Hide Speed Units

            ; Clear small batteries
            (disp-render buf-battery-a-sm 262 92 '(0x0 0x0 0x0 0x0))
            (disp-render buf-battery-a-sm-soc 262 40 '(0x0 0x0 0x0 0x0))
            (disp-render buf-battery-b-sm 288 92 '(0x0 0x0 0x0 0x0))
            (disp-render buf-battery-b-sm-soc 288 40 '(0x0 0x0 0x0 0x0))

            ; Show kickstand down icon
            (disp-render buf-kickstand 270 116 colors-red-icon)
        } {
            (disp-render buf-kickstand 270 116 '(0x0 0x0 0x0 0x0)) ; Hide kickstand
            (disp-render buf-units 175 222 colors-white-icon) ; Show Speed Units
        })

        (setix view-state-previous 0 'update-speed)
        (setix view-state-previous 1 'update-battery-soc)
    })

    ; Speed Now
    (if (not (ix view-state-now 3))
        (if (not-eq (ix view-state-now 0) (first view-state-previous)) {
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
    (if (not-eq (ix view-state-now 1) (second view-state-previous)) {
        (var color 0x7f9a0d)
        (if (< stats-battery-soc 0.5)
            (setq color (lerp-color 0xe72a62 0xffa500 (ease-in-out-quint (* stats-battery-soc 2))))
            (setq color (lerp-color 0xffa500 0x7f9a0d (ease-in-out-quint (* (- stats-battery-soc 0.5) 2))))
        )

        (if (ix view-state-now 3)
            ; Render speed buffer containing large battiers when parked
            (disp-render buf-speed 0 130 `(0x000000 0x4f514f 0x929491 0xfbfcfc ,color))
            ; Render small batteries
            {
                (disp-render buf-battery-a-sm 262 92 `(0x000000 0xfbfcfc ,color 0x0000ff))
                (disp-render buf-battery-a-sm-soc 259 40 colors-white-icon)

                ; TODO: Fake Battery B Value
                (disp-render buf-battery-b-sm 288 92 `(0x000000 0xfbfcfc ,color 0x0000ff))
                (disp-render buf-battery-b-sm-soc 285 40 colors-white-icon)
            }
        )
    })

    ; Drive Mode
    (if (not-eq (ix view-state-now 4) (ix view-state-previous 4)) {
        (if (ix view-state-now 4)
            (disp-render buf-drive-mode 270 172 colors-white-icon)
            (disp-render buf-neutral-mode 270 172 colors-green-icon)
        )
    })

    ; Performance Mode
    (if (not-eq (ix view-state-now 5) (ix view-state-previous 5)) {
        (disp-render buf-performance-mode 262 220 colors-white-icon)
    })

    ; Update stats for improved performance
    (def view-state-previous (list
        (ix view-state-now 0)
        (ix view-state-now 1)
        (ix view-state-now 2)
        (ix view-state-now 3)
        (ix view-state-now 4)
        (ix view-state-now 5)
        (ix view-state-now 6)
        (ix view-state-now 7)
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
