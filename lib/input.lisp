(def btn-0-pressed nil)
(def btn-1-pressed nil)
(def btn-2-pressed nil)
(def btn-3-pressed nil)

@const-start

; Evaluate expression if the function isn't nil.
; Ex: ```
; (defun fun-a (a) (print a))
; (def fun-b nil)
; (maybe-call (fun-a 5)) ; prints 5
; (maybe-call (fun-b 5)) ; does nothing
;```
(def maybe-call (macro (expr) {
    (var fun (first expr))
    `(if ,fun
        ,expr
    )
}))

(defun input-cleanup-on-pressed () {
    (def on-btn-0-pressed nil)
    (def on-btn-1-pressed nil)
    (def on-btn-2-pressed nil)
    (def on-btn-3-pressed nil)

    (def on-btn-0-long-pressed nil)
    (def on-btn-1-long-pressed nil)
    (def on-btn-2-long-pressed nil)
    (def on-btn-3-long-pressed nil)
})

@const-end
(def adc-buf '(0 0 0 0 0))
(def adc-buf-idx 0)
@const-start

(defun thread-input () {
    (input-cleanup-on-pressed)
    (var input-debounce-count 3)
    (var btn-0 0)
    (var btn-1 0)
    (var btn-2 0)
    (var btn-3 0)
    (var btn-0-start (systime))
    (var btn-1-start (systime))
    (var btn-2-start (systime))
    (var btn-3-start (systime))
    (var btn-0-long-fired nil)
    (var btn-1-long-fired nil)
    (var btn-2-long-fired nil)
    (var btn-3-long-fired nil)
    (loopwhile t {
        (sleep 0.01) ; TODO: Rate limit
        ; Median filter for v-btn
        (setix adc-buf adc-buf-idx (v-btn))
        (setq adc-buf-idx (mod (+ adc-buf-idx 1) 5))
        (var button-voltage (ix (sort < adc-buf) 2))

        (var new-btn-0 false)
        (var new-btn-1 false)
        (var new-btn-2 false)
        (var new-btn-3 false)
        (cond
            ((and (> button-voltage 0.24) (< button-voltage 0.35)) (set 'new-btn-0 t))
            ((and (> button-voltage 0.45) (< button-voltage 0.65)) (set 'new-btn-1 t))
            ((and (> button-voltage 0.75) (< button-voltage 0.85)) (set 'new-btn-3 t))
            ((and (> button-voltage 0.95) (< button-voltage 1.1)) (set 'new-btn-2 t))
        )

        ; buttons are pressed on release
        (if (and (>= btn-0 input-debounce-count) (not new-btn-0) (not btn-0-long-fired))
            (maybe-call (on-btn-0-pressed))
        )
        (if (and (>= btn-1 input-debounce-count) (not new-btn-1) (not btn-1-long-fired))
            (maybe-call (on-btn-1-pressed))
        )
        (if (and (>= btn-2 input-debounce-count) (not new-btn-2) (not btn-2-long-fired))
            (maybe-call (on-btn-2-pressed))
        )
        (if (and (>= btn-3 input-debounce-count) (not new-btn-3) (not btn-3-long-fired))
            (maybe-call (on-btn-3-pressed))
        )

        (setq btn-0 (if new-btn-0 (+ btn-0 1) 0))
        (setq btn-1 (if new-btn-1 (+ btn-1 1) 0))
        (setq btn-2 (if new-btn-2 (+ btn-2 1) 0))
        (setq btn-3 (if new-btn-3 (+ btn-3 1) 0))

        (setq btn-0-pressed (>= btn-0 input-debounce-count))
        (setq btn-1-pressed (>= btn-1 input-debounce-count))
        (setq btn-2-pressed (>= btn-2 input-debounce-count))
        (setq btn-3-pressed (>= btn-3 input-debounce-count))

        (if (= btn-0 1) (setq btn-0-start (systime)))
        (if (= btn-1 1) (setq btn-1-start (systime)))
        (if (= btn-2 1) (setq btn-2-start (systime)))
        (if (= btn-3 1) (setq btn-3-start (systime)))

        ; long presses fire as soon as possible and not on release
        (if (and (>= btn-0 input-debounce-count) (>= (secs-since btn-0-start) 0.25) (not btn-0-long-fired)) {
            ;TODO: Commenting for key repeat (setq btn-0-long-fired true)
            (maybe-call (on-btn-0-long-pressed))
        })
        (if (and (>= btn-1 input-debounce-count) (>= (secs-since btn-1-start) 2.0) (not btn-1-long-fired)) {
            (setq btn-1-long-fired true)
            (maybe-call (on-btn-1-long-pressed))
        })
        (if (and (>= btn-2 input-debounce-count) (>= (secs-since btn-2-start) 2.0) (not btn-2-long-fired)) {
            (setq btn-2-long-fired true)
            (maybe-call (on-btn-2-long-pressed))
        })
        (if (and (>= btn-3 input-debounce-count) (>= (secs-since btn-3-start) 0.25) (not btn-3-long-fired)) {
            ;TODO: Commenting for key repeat (setq btn-3-long-fired true)
            (maybe-call (on-btn-3-long-pressed))
        })

        (if (and (>= (secs-since btn-1-start) 6.13) btn-1-long-fired) (def state-view-next 'view-minigame))

        (if (= btn-0 0) (setq btn-0-long-fired false))
        (if (= btn-1 0) (setq btn-1-long-fired false))
        (if (= btn-2 0) (setq btn-2-long-fired false))
        (if (= btn-3 0) (setq btn-3-long-fired false))
    })
})

(spawn thread-input)
