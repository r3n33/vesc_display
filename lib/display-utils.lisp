(if config-homologation-enable {
    (def state-view 'view-homologation)
    (def state-view-next 'view-homologation)
} {
    (def state-view 'view-main)
    (def state-view-next 'view-main)
})

(def state-view-previous state-view)

(def fps 0.0)

@const-start

(defun display-init () {
    (disp-load-st7789 7 6 10 20 8 40) ; Args: sda clock cs reset dc mhz
    (disp-reset)
    (ext-disp-orientation 3)
    (disp-clear)
    (sleep 0.1) ; Small delay to ensure display is clear before backlight activation
    (set-io 3 1) ; enable display backlight
})

(def views (list 'view-main 'view-homologation 'view-speed-large 'view-statistics 'view-bms 'view-live-chart 'view-profile-select 'view-profile-edit 'view-minigame))

(defun next-view () (match state-view
    (view-main 'view-speed-large)
    (view-homologation 'view-speed-large)
    (view-speed-large 'view-statistics)
    (view-statistics (if (> (get-bms-val 'bms-cell-num) 0) 'view-bms 'view-live-chart))
    (view-bms 'view-live-chart)
    (view-live-chart (if config-profiles-enable
        'view-profile-select
        'view-speed-large))
    (view-profile-select nil)
    (_ nil)
))

(defun previous-view () (match state-view
    (view-homologation nil)
    (view-speed-large (if config-homologation-enable 'view-homologation 'view-main))
    (view-statistics 'view-speed-large)
    (view-bms 'view-statistics)
    (view-live-chart (if (> (get-bms-val 'bms-cell-num) 0) 'view-bms 'view-statistics))
    (view-profile-select 'view-live-chart)
    (_ nil)
))

(defun init-current-view () {
    (match state-view
        (view-homologation (view-init-homologation))
        (view-main (view-init-main))
        (view-bms (view-init-bms))
        (view-speed-large (view-init-speed-large))
        (view-statistics (view-init-statistics))
        (view-live-chart (view-init-chart))
        (view-profile-select (view-init-profile-select))
        (view-profile-edit (view-init-profile-edit))
        (view-minigame (view-init-minigame))
        (_ (print "state-view is unknown"))
    )
})

(defun select-current-view () {
    (if (and (not-eq state-view-next nil) (not-eq state-view-next state-view)) {
        
        (cleanup-current-view)
        (input-cleanup-on-pressed)

        (disp-clear)

        (def state-view-previous state-view)
        (def state-view state-view-next)
        (def state-view-next nil)

        (init-current-view)
    })
})

(defun draw-current-view () {
    (match state-view
        (view-homologation (view-draw-homologation))
        (view-main (view-draw-main))
        (view-bms (view-draw-bms))
        (view-speed-large (view-draw-speed-large))
        (view-statistics (view-draw-statistics))
        (view-live-chart (view-draw-chart))
        (view-profile-select (view-draw-profile-select))
        (view-profile-edit (view-draw-profile-edit))
        (view-minigame (view-draw-minigame))
        (_ (print "state-view is unknown"))
    )
})
(defun render-current-view () {
    (match state-view
        (view-homologation (view-render-homologation))
        (view-main (view-render-main))
        (view-bms (view-render-bms))
        (view-speed-large (view-render-speed-large))
        (view-statistics (view-render-statistics))
        (view-live-chart (view-render-chart))
        (view-profile-select (view-render-profile-select))
        (view-profile-edit (view-render-profile-edit))
        (view-minigame (view-render-minigame))
        (_ (print "state-view is unknown"))
    )
})

(defun cleanup-current-view () {
    (match state-view
        (view-homologation (view-cleanup-homologation))
        (view-main (view-cleanup-main))
        (view-bms (view-cleanup-bms))
        (view-speed-large (view-cleanup-speed-large))
        (view-statistics (view-cleanup-statistics))
        (view-live-chart (view-cleanup-chart))
        (view-profile-select (view-cleanup-profile-select))
        (view-profile-edit (view-cleanup-profile-edit))
        (view-minigame (view-cleanup-minigame))
        (_ (print "state-view is unknown"))
    )
})

(defun display-thread () {
    (var frame-ms 0.0)
    (var last-frame-time (systime))

    (loopwhile (not init-complete) {
        (sleep 0.1)
    })

    (init-current-view)

    (loopwhile t {
        (var start (systime))

        (select-current-view)
        (draw-current-view)
        (render-current-view)

        (var smoothing 0.1)
        (setq frame-ms (+ (* (* (secs-since start) 1000) smoothing) (* frame-ms (- 1.0 smoothing))))
        (var frame-seconds (secs-since last-frame-time))
        (if (> frame-seconds 0.0)
            (setq fps (+ (* (/ 1.0 frame-seconds) smoothing) (* fps (- 1.0 smoothing))))
        )
        (setq last-frame-time (systime))

        (var elapsed (secs-since start))
        (var secs (- 0.04 elapsed)) ; 40 ms (25fps maximum)
        (sleep (if (< secs 0.0) 0 secs))
    })
})

(if config-error-recovery
    (spawn (fn () (loopwhile t {
        (print "Starting display-thread")
        (spawn-trap display-thread)
        (recv   ((exit-error (? tid) (? e))
                    (print (str-merge "display-thread error: " (to-str e)))
                )
                ((exit-ok (? tid) (? v)) 'ok))
        (sleep 1.0)
    })))
    (spawn display-thread)
)
