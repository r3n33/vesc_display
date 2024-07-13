(import "pkg@://vesc_packages/lib_code_server/code_server.vescpkg" 'code-server)
(read-eval-program code-server)

(start-code-server)

(def buf-canid20 (array-create 8))
(def buf-canid21 (array-create 8))
(def buf-canid22 (array-create 8))
(def buf-canid23 (array-create 8))
(def buf-canid24 (array-create 8))

(def buf-canid30 (array-create 8))
(def buf-canid31 (array-create 8))

@const-start

(spawn (fn ()
        (loopwhile t
            (progn
                (select-motor 1)
                (bufset-i16 buf-canid20 0 (* (get-batt) 1000))
                (bufset-i16 buf-canid20 2 (* (abs (get-duty)) 1000))
                (bufset-i16 buf-canid20 4 (* (abs (get-speed)) 3.6 10))
                (bufset-i16 buf-canid20 6 (* (get-current-in) (get-vin) 2 0.1))

                (if (> (get-bms-val 'bms-temp-adc-num) 0)
                    (bufset-i16 buf-canid21 0 (* (get-bms-val 'bms-temps-adc 0) 10))
                    (bufset-i16 buf-canid21 0 0)
                )
                (bufset-i16 buf-canid21 2 (* (get-temp-fet) 10))
                (bufset-i16 buf-canid21 4 (* (get-temp-mot) 10))
                (bufset-i16 buf-canid21 6 (* (ix (get-imu-rpy) 1) 100))

                (bufset-u16 buf-canid22 0 (* (get-wh) 10.0))
                (bufset-u16 buf-canid22 2 (* (get-wh-chg) 10.0))
                (bufset-u16 buf-canid22 4 (* (/ (get-dist-abs) 1000) 10))
                (bufset-u16 buf-canid22 6 (get-fault))

                (bufset-u16 buf-canid23 0 (to-i (stats 'stat-current-avg)))
                (bufset-u16 buf-canid23 2 (to-i (stats 'stat-current-max)))
                (bufset-i16 buf-canid23 4 (to-i (get-current)))
                (bufset-u16 buf-canid23 6 (to-i (conf-get 'si-battery-ah)))

                (bufset-u16 buf-canid24 0 (* (get-vin) 10))


                (sleep 0.1) ; 10 Hz
))))

; TODO: Fake indicator signals & highbeam
(def send-msg-30 false)
(spawn (fn () {
    ; Sending initial signal that would not have measured the Indicator Duration
    (bufset-u8 buf-canid30 0 1) ; L Indicator ON
    (bufset-u8 buf-canid30 1 1) ; R Indicator ON
    (bufset-u16 buf-canid30 2 0) ; Indicator ON milliseconds
    (bufset-u16 buf-canid30 4 0)
    (bufset-u16 buf-canid30 6 0)
    (setq send-msg-30 true)
    (sleep 0.65)

    (bufset-u8 buf-canid30 0 0) ; L Indicator OFF
    (bufset-u8 buf-canid30 1 0) ; R Indicator OFF
    (bufset-u16 buf-canid30 2 0) ; Indicator ON milliseconds
    (setq send-msg-30 true)
    (sleep 0.5)

    (var highbeam-active false)
    ; Sending indicator signals with measured Indicator Duration
    (loopwhile t
        (progn
            (bufset-u8 buf-canid30 0 1) ; L Indicator ON
            (bufset-u8 buf-canid30 1 1) ; R Indicator ON
            (bufset-u16 buf-canid30 2 650) ; Indicator ON milliseconds
            (if highbeam-active
                (bufset-u8 buf-canid30 4 1)
                (bufset-u8 buf-canid30 4 0)
            )
            (setq send-msg-30 true)
            (sleep 0.65)

            (bufset-u8 buf-canid30 0 0) ; L Indicator OFF
            (bufset-u8 buf-canid30 1 0) ; R Indicator OFF
            (bufset-u16 buf-canid30 2 650) ; Indicator ON milliseconds
            (setq send-msg-30 true)
            (sleep 0.5)

            (setq highbeam-active (not highbeam-active))

            (sleep 3.0)
    ))
}))

; TODO: Fake kickstand, drive mode and performance mode
(spawn (fn () (loopwhile t
    (progn
        ; Raise kickstand, leave in neutral
        (bufset-u8 buf-canid31 0 1) ; Kickstand Up
        (bufset-u8 buf-canid31 1 0) ; Drive Mode Inactive
        (bufset-u8 buf-canid31 2 0) ; Performance Mode ECO
        (sleep 3.0)

        ; Raise kickstand, Put in Drive Mode
        (bufset-u8 buf-canid31 0 1) ; Kickstand Up
        (bufset-u8 buf-canid31 1 1) ; Drive Mode Active
        (bufset-u8 buf-canid31 2 1) ; Performance Mode Normal
        (set-current-rel 0.2)
        (var start-time (systime))
        (loopwhile (< (secs-since start-time) 1.0) {
            (sleep 0.1)
        })
        (set-current-rel 0.0)
        (setq start-time (systime))
        (loopwhile (< (secs-since start-time) 2.0) {
            (sleep 0.1)
        })

        ; Lower kickstand, put in neutral
        (bufset-u8 buf-canid31 0 0) ; Kickstand Down
        (bufset-u8 buf-canid31 1 0) ; Drive Mode Inactive
        (bufset-u8 buf-canid31 2 2) ; Performance Mode Sport
        (sleep 3.0)
))))


(spawn (fn () (loopwhile t
    (progn
        (can-send-sid 20 buf-canid20)
        (can-send-sid 21 buf-canid21)
        (can-send-sid 22 buf-canid22)
        (can-send-sid 23 buf-canid23)
        (can-send-sid 24 buf-canid24)


        (can-send-sid 31 buf-canid31)
        (if send-msg-30 {
            (can-send-sid 30 buf-canid30)
            (setq send-msg-30 false)
        })
        (sleep 0.1) ; 10 Hz
))))
