@const-start

(defun view-init-profile-select () {
    ; TODO: temporary until eeprom is ready
    (def profile-active 0)

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
        (if (eq profile-active 0)
            (setq profile-active 2)
            (setq profile-active (- profile-active 1))
        )
        (print profile-active)
        (def view-animation-start (systime))
        (def view-animation-pct 0.0)
    })

    (defun on-btn-2-pressed () {
        (if (eq profile-active 2)
            (setq profile-active 0)
            (setq profile-active (+ profile-active 1))
        )
        (print profile-active)
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

        (var posb (rot-point-origin 70 0 0))
        (var posa (rot-point-origin 70 0 90))
        (var posc (rot-point-origin 70 0 180))

        (var active-box-size '(120 90))
        (var inactive-box-size '(80 60))

        (img-rectangle buf-profiles
            (+ (- (ix posa 0) (/ (first active-box-size) 2)) 120)
            (+ (ix posa 1) 10)
            (first active-box-size)
            (second active-box-size)
            3
            '(filled)
            '(rounded 10)
        )

        (txt-block-c buf-profiles
            '(0 1 2 3)
            (+ (ix posa 0) 120)
            (+ (ix posa 1) 40)
            font24
            (str-from-n (+ profile-active 1) "%d")
        )

        (img-rectangle buf-profiles
            (+ (- (ix posb 0) (/ (first inactive-box-size) 2)) 120)
            (+ (ix posb 1) 10)
            (first inactive-box-size)
            (second inactive-box-size)
            2
            '(filled)
            '(rounded 2)
        )

        (img-rectangle buf-profiles
            (+ (- (ix posc 0) (/ (first inactive-box-size) 2)) 120)
            (+ (ix posc 1) 10)
            (first inactive-box-size)
            (second inactive-box-size)
            2
            '(filled)
            '(rounded 2)
        )

        ;(img-circle buf-profiles (+ (ix posa 0) 140) (+ (ix posa 1) 20) 8 (if (eq profile-active 0) 3 0) '(filled))
        ;(img-circle buf-profiles (+ (ix posb 0) 140) (+ (ix posb 1) 20) 8 (if (eq profile-active 1) 3 0) '(filled))
        ;(img-circle buf-profiles (+ (ix posc 0) 140) (+ (ix posc 1) 20) 8 (if (eq profile-active 2) 3 0) '(filled))
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
