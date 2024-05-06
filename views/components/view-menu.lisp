(defun view-init-menu () {
    (def buf-menu (img-buffer 'indexed2 320 25))
})

(defun view-draw-menu (button-0 button-1 button-2 button-3) {
    (img-clear buf-menu) ; TODO: Determine if re-draw is necessary
    (var btn-1-center 115)
    (var btn-2-center 200)
    (var width 320)
    (var height 25)
    (img-line buf-menu 0 0 width 0 1 '(thickness 2))

    (if (eq button-0 'arrow-left)
        (draw-arrow-left buf-menu 10 6 18 14 1)
        (txt-block-l buf-menu 1 0 5 font15 button-0)
    )
    
    (txt-block-c buf-menu 1 btn-1-center 6 font15 button-1)
    (txt-block-c buf-menu 1 btn-2-center 6 font15 button-2)

    (if (eq button-3 'arrow-right)
        (draw-arrow-right buf-menu 310 6 18 14 1)
        (txt-block-r buf-menu 1 320 6 font15 button-3)
    )
})

(defun view-render-menu () {
    ;(var height 25)
    (disp-render buf-menu 0 (- 240 25) '(0x000000 0x0000ff)) ; alt menu bar color 0x898989
})

(defun view-cleanup-menu () {
    (def buf-menu nil)
})
