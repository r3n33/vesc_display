; lerp-color visualizer

; linearly interpolate between a and b by v.
; v is in range 0-1
(defun lerp (a b v)
    (+ (* (- 1 v) a) (* v b))
)

; Linearly interpolate between the two integer colors a and b by v.
; v is in the range 0.0 to 1.0.
(defun lerp-color (a b v) {
    (var a-rgb (color-split a))
    (var b-rgb (color-split b))

    (var r (to-i (lerp (ix a-rgb 0) (ix b-rgb 0) v)))
    (var g (to-i (lerp (ix a-rgb 1) (ix b-rgb 1) v)))
    (var b (to-i (lerp (ix a-rgb 2) (ix b-rgb 2) v)))

    (color-make r g b)
})

(defun ease-in-out-sine (x)
    (/ (- 1 (cos (* 3.14159 x))) 2)
)

(defun ease-in-out-quint (x)
    (if (< x 0.5)
        (* 16 x x x x x)
        (- 1 (/ (pow (+ (* -2.0 x) 2.0) 5) 2.0))
    )
)

(disp-load-st7789 7 6 10 20 8 40) ; Args: sda clock cs reset dc mhz
(disp-reset)
(ext-disp-orientation 3)
(disp-clear)
(set-io 3 1) ; enable display backlight

(def buf (img-buffer 'indexed2 (/ 320 100) 100))

(def start-time (systime))
(looprange i 0 100 {
    (var pos (/ i 100.0))
    (var color 0x7f9a0d)
    (if (< pos 0.5)
        (setq color (lerp-color 0xe70000 0xffff00 (* pos 2)))
        (setq color (lerp-color 0xffff00 0x00ff00 (* (- pos 0.5) 2)))
    )

    (img-clear buf 1)

    (disp-render buf (+ 10 (* (/ 320 100) i)) 70 `(0x0 ,color))
})

(print (str-from-n (secs-since start-time) "Lerp time: %0.4f seconds"))