@const-start

(defun view-init-settings () {
    (def view-settings-index -1)
    (def view-settings-index-next 0)
    (def view-settings-index-editing -1)

    (def buf-bike (img-buffer 'indexed16 161 97))
    (img-blit buf-bike (img-buffer-from-bin icon-bike) 0 0 -1)
    (def buf-settings-opt0 (img-buffer 'indexed4 290 25))
    (def buf-settings-opt1 (img-buffer 'indexed4 290 25))
    (def buf-settings-opt2 (img-buffer 'indexed4 290 25))
    (def buf-settings-opt3 (img-buffer 'indexed4 290 25))
    (def buf-settings-submenu (img-buffer 'indexed4 130 25))
    (txt-block-l buf-settings-submenu (list 0 1 2 3) 0 0 font24 (to-str "Save"))

    ; TODO: Get latest settings from ESC

    (defun on-btn-0-pressed () {
        (def state-view-next (previous-view))
    })
    (defun on-btn-1-pressed () {
        ; Move menu up
        (if (< view-settings-index 5)
            (setq view-settings-index-next (+ view-settings-index 1))
        )
    })
    (defun on-btn-2-pressed () {
        ; Move menu down
        (if (> view-settings-index 0)
            (setq view-settings-index-next (- view-settings-index 1))
        )
    })
    (defun on-btn-3-pressed () {
        ; TODO: Accept current value or save to ESC depending on view-settings-index
        (match view-settings-index
            (0 nil)
            (1 nil)
            (2 nil)
            (3 nil)
            (4 {
                ; TODO: Save settings to ESC
                ; Return to initial view
                (def state-view-next 'view-dash-primary)
            })
        )
    })

    ; Render menu
    (view-draw-menu 'arrow-left 'arrow-down 'arrow-up "ENTER")
    (view-render-menu)

    (disp-render buf-bike 134 116 '(0x000000 0x080905 0x0f0f0c 0x1a1817 0x23201f 0x2b2726))
})

(defun view-draw-settings () {
    (if (not-eq view-settings-index view-settings-index-next) {
        ; TODO: Show latest values received from ESC
        (txt-block-l buf-settings-opt0 (list 0 1 2 3) 0 0 font24 (to-str "Wheel: 605mm"))
        (txt-block-l buf-settings-opt1 (list 0 1 2 3) 0 0 font24 (to-str "Batt : 100A"))
        (txt-block-l buf-settings-opt2 (list 0 1 2 3) 0 0 font24 (to-str "Batt : 16S"))
        (txt-block-l buf-settings-opt3 (list 0 1 2 3) 0 0 font24 (to-str "Motor: Stock"))

        ; Update Bike Overlay
        (img-blit buf-bike (img-buffer-from-bin icon-bike) 0 0 -1)
        (var color-ix 6)
        (match view-settings-index-next
            (0 (img-circle buf-bike 134 69 25 color-ix '(thickness 3)))
            (1 (img-rectangle buf-bike 69 23 12 28 color-ix '(filled) '(rounded 4)))
            (2 (img-rectangle buf-bike 69 23 12 28 color-ix '(filled) '(rounded 4)))
            (3 (img-circle buf-bike 82 62 9 color-ix '(thickness 3)))
        )
    })
})

(defun view-render-settings () {
    (if (not-eq view-settings-index view-settings-index-next) {
        (var next view-settings-index-next)
        (var colors-menu '( 0x000000 0x4f514f 0x929491 0xfbfcfc))
        (var colors-menu-selected '( 0x000000 0x113f60 0x1e659a 0x1d9aed))

        (disp-render buf-settings-opt0 5 5 (if (= next 0) colors-menu-selected colors-menu))
        (disp-render buf-settings-opt1 5 30 (if (= next 1) colors-menu-selected colors-menu))
        (disp-render buf-settings-opt2 5 55 (if (= next 2) colors-menu-selected colors-menu))
        (disp-render buf-settings-opt3 5 80 (if (= next 3) colors-menu-selected colors-menu))
        (disp-render buf-settings-submenu 15 150 (if (= next 4) colors-menu-selected colors-menu))

        (disp-render buf-bike 134 116
            '(  0x000000 0x080905 0x0f0f0c 0x1a1817 0x23201f 0x2b2726
                0x1d9aed
            ))

        (setq view-settings-index view-settings-index-next)
    })
})

(defun view-cleanup-settings () {
    (def buf-bike nil)
    (def buf-settings-opt0 nil)
    (def buf-settings-opt1 nil)
    (def buf-settings-opt2 nil)
    (def buf-settings-opt3 nil)
    (def buf-settings-submenu nil)
})
