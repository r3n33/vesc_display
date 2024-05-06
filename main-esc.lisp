(import "pkg@://vesc_packages/lib_code_server/code_server.vescpkg" 'code-server)
(read-eval-program code-server)

(start-code-server)

(def buf-canid20 (array-create 8))
(def buf-canid21 (array-create 8))
(def buf-canid22 (array-create 8))
(def buf-canid23 (array-create 8))

(spawn (fn ()
        (loopwhile t
            (progn
                (select-motor 1)
                (bufset-i16 buf-canid20 0 (* (/ (- (get-vin) 12.0) 15.0) 1000))
                (bufset-i16 buf-canid20 2 (* (abs (get-duty)) 1000))
                (bufset-i16 buf-canid20 4 (* (abs (get-speed)) 3.6 10))
                (bufset-i16 buf-canid20 6 (* (get-current-in) (get-vin) 2 0.1))

                (if (> (get-bms-val 'bms-temp-adc-num) 0)
                    (bufset-i16 buf-canid21 0 (* (get-bms-val 'bms-temps-adc 0) 10))
                    (bufset-i16 buf-canid21 0 0)
                )
                (bufset-i16 buf-canid21 2 (* (get-temp-fet) 10))
                (bufset-i16 buf-canid21 4 (* (get-temp-mot) 10))
                (bufset-i16 buf-canid21 6 (* (ix (get-imu-rpy) 1) 10))

                (bufset-u16 buf-canid22 0 (to-i (get-wh)))
                (bufset-u16 buf-canid22 2 (to-i (get-wh-chg)))
                (bufset-u16 buf-canid22 4 (* (/ (get-dist-abs) 1000) 10))
                (bufset-u16 buf-canid22 6 (get-fault))

                (bufset-u16 buf-canid23 0 (to-i (stats 'stat-current-avg)))
                (bufset-u16 buf-canid23 2 (to-i (stats 'stat-current-max)))
                (bufset-i16 buf-canid23 4 (to-i (get-current)))
                ; TODO: 2 bytes available

                (can-send-sid 20 buf-canid20)
                (can-send-sid 21 buf-canid21)
                (can-send-sid 22 buf-canid22)
                (can-send-sid 23 buf-canid23)
                (sleep 0.1)
))))
