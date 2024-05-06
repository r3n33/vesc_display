(defun proc-data (src des data rssi) {
    ; Ignore broadcast, only handle data sent directly to us
    (if (not-eq des broadcast-addr) {
        (def peer-addr src)
        ;(esp-now-add-peer src)
        ;(eval (read data))
    } {
        ; Broadcast data
        ;(var br-data (unflatten data))
    })

    (free data)
})


(def rx-cnt-can 0)
(defun proc-sid (id data) {
    (if (= id 20) {
        (def stats-battery-soc (/ (bufget-i16 data 0) 1000.0))
        (def stats-duty (/ (bufget-i16 data 2) 1000.0))
        (def stats-kmh (/ (bufget-i16 data 4) 10.0))
        (def stats-kw (/ (bufget-i16 data 6) 100.0))

        (def stats-updated true)
        (setq rx-cnt-can (+ rx-cnt-can 1))
    })
    (if (= id 21) {
        (def stats-temp-battery (/ (bufget-i16 data 0) 10.0))
        (def stats-temp-esc (/ (bufget-i16 data 2) 10.0))
        (def stats-temp-motor (/ (bufget-i16 data 4) 10.0))
        (def stats-angle-pitch (/ (bufget-i16 data 6) 10.0))
(def stats-angle-pitch (* (mod (rand) 45) 0.0174533)) ; TODO: this is... illegal!!
        (setq rx-cnt-can (+ rx-cnt-can 1))
    })
    (if (= id 22) {
        (def stats-wh (bufget-u16 data 0))
        (def stats-wh-chg (bufget-u16 data 2))
        (def stats-km (/ (bufget-u16 data 4) 10.0))
        (def stats-fault-code (bufget-u16 data 6))
        (setq rx-cnt-can (+ rx-cnt-can 1))
    })
    (if (= id 23) {
        (def stats-amps-avg (bufget-u16 data 0))
        (def stats-amps-max (bufget-u16 data 2))
        (def stats-amps-now (bufget-i16 data 4))
        (setq rx-cnt-can (+ rx-cnt-can 1))
    })

    (free data)
})


(defun event-handler ()
    (loopwhile t
        (recv
            ;;((event-esp-now-rx (? src) (? des) (? data) (? rssi)) (proc-data src des data rssi))
            ((event-can-sid . ((? id) . (? data))) (proc-sid id data))
            (_ nil)
)))


(event-register-handler (spawn event-handler))
;;(event-enable 'event-esp-now-rx)
(event-enable 'event-can-sid)
