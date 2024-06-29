@const-start

(defun view-init-profile-select () {
    (def profile-active (read-setting 'pf-active))

    (var buf-title (img-buffer 'indexed4 240 30))
    (txt-block-r buf-title (list 0 1 2 3) 240 0 font18 (to-str "Select Profile"))
    (disp-render buf-title 80 4 '(0x000000 0x4f514f 0x929491 0xfbfcfc))


    (def profile-previous nil) ; Track last selection
    (def buf-profiles (img-buffer 'indexed4 240 180))
    (def view-animation-pct 1.0)

    (defun on-btn-0-pressed () {
        (def state-view-next (previous-view))
    })

    (defun on-btn-1-pressed () {
        (if (eq profile-active 0i32)
            (setq profile-active 2i32)
            (setq profile-active (- profile-active 1))
        )
        (write-setting 'pf-active profile-active)
        ;(print profile-active)
        (def view-animation-start (systime))
        (def view-animation-pct 0.0)
    })

    (defun on-btn-2-pressed () {
        (if (eq profile-active 2i32)
            (setq profile-active 0i32)
            (setq profile-active (+ profile-active 1))
        )
        (write-setting 'pf-active profile-active)
        ;(print profile-active)
        (def view-animation-start (systime))
        (def view-animation-pct 0.0)
    })

    (defun on-btn-3-pressed () {
        (def state-view-next 'view-profile-edit)
    })

    ; Render menu
    (view-draw-menu 'arrow-left 'arrow-down 'arrow-up "EDIT")
    (view-render-menu)
})

(defun view-draw-profile-select () {
    (if (not-eq profile-active profile-previous) {
        ;(print "draw profile")
        (img-clear buf-profiles)

        (if (< view-animation-pct 1.0) {
            (var animation-seconds 0.5)
            (def view-animation-pct (/ (secs-since view-animation-start) animation-seconds))
        })

        ; Background
        (var box-size '(240 180))
        (img-rectangle buf-profiles
            0
            0
            (first box-size)
            (second box-size)
            3
            '(thickness 2)
            '(rounded 10)
        )

        ; Profile Number
        (txt-block-c buf-profiles
            '(0 1 2 3)
            120
            5
            font24
            (str-from-n (+ profile-active 1) "%d")
        )

        (draw-vertical-bar buf-profiles 20 30 40 120 '(1 3) (match profile-active
            (0i32 (read-setting 'pf1-speed))
            (1i32 (read-setting 'pf2-speed))
            (_ (read-setting 'pf3-speed))
        ))

        (txt-block-c buf-profiles
            '(0 1 2 3)
            40
            160
            font15
            (to-str "Speed")
        )

        (draw-vertical-bar buf-profiles 100 30 40 120 '(1 3) (match profile-active
            (0i32 (read-setting 'pf1-break))
            (1i32 (read-setting 'pf2-break))
            (_ (read-setting 'pf3-break))
        ))

        (txt-block-c buf-profiles
            '(0 1 2 3)
            120
            160
            font15
            (to-str "Break")
        )

        (draw-vertical-bar buf-profiles 180 30 40 120 '(1 3) (match profile-active
            (0i32 (read-setting 'pf1-accel))
            (1i32 (read-setting 'pf2-accel))
            (_ (read-setting 'pf3-accel))
        ))

        (txt-block-c buf-profiles
            '(0 1 2 3)
            200
            160
            font15
            (to-str "Accel")
        )
    })
})

(defun view-render-profile-select () {
    (if (not-eq profile-active profile-previous) {
        ;(print "render profile")

        (disp-render buf-profiles 40 30 '(0x000000 0x4f514f 0x929491 0xfbfcfc))

        (if (>= view-animation-pct 1.0)
            (setq profile-previous profile-active)
        )
    })
})

(defun view-cleanup-profile-select () {
    (def buf-profiles nil)
})
