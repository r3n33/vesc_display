@const-end

; ID 20
(def stats-battery-soc 0)
(def stats-duty 0)
(def stats-kmh 0)
(def stats-kw 0)
; ID 21
(def stats-temp-battery 0)
(def stats-temp-esc 0)
(def stats-temp-motor 0)
(def stats-angle-pitch 0)
; ID22
(def stats-wh 0)
(def stats-wh-chg 0)
(def stats-km 0)
(def stats-fault-code 0)
; ID23
(def stats-amps-avg 0)
(def stats-amps-max 0)
(def stats-amps-now 0)

; Computed Statistics (resettable)
(def stats-reset-now nil)
(def stats-kmh-max 0)
(def stats-kw-max 0)
(def stats-temp-battery-max 0)
(def stats-temp-esc-max 0)
(def stats-temp-motor-max 0)
(def stats-amps-now-min 0)
(def stats-fault-codes-observed (list))

@const-start

(defun stats-reset-max () {
    (def stats-reset-now true)
})

(defunret list-find (haystack needle) {
    (var i 0)
    (loopwhile (< i (length haystack)) {
        (if (eq needle (ix haystack i)) (return i))
        (setq i (+ i 1))
    })
    (return nil)
})

(defun thread-stats () {
    (loopwhile t {
        (sleep 0.05)
        (if stats-reset-now {
            (def stats-kmh-max 0)
            (def stats-kw-max 0)
    
            (def stats-reset-now nil)
        })
    
        ; Max Speed
        (if (> stats-kmh stats-kmh-max) (def stats-kmh-max stats-kmh))
    
        ; Max KW
        (if (> stats-kw stats-kw-max) (def stats-kw-max stats-kw))

        ; Max Temps
        (if (> stats-temp-battery stats-temp-battery-max) (def stats-temp-battery-max stats-temp-battery))
        (if (> stats-temp-esc stats-temp-esc-max) (def stats-temp-esc-max stats-temp-esc))
        (if (> stats-temp-motor stats-temp-motor-max) (def stats-temp-motor-max stats-temp-motor))

        ; Min Amps Observed (Max Regen Amps)
        (if (> stats-amps-now-min stats-amps-now) (def stats-amps-now-min stats-amps-now))

        ; Fault Codes
        (if (> stats-fault-code 0) {
            ; Check if fault-code is already in list
            (if (not (list-find stats-fault-codes-observed stats-fault-code)) {
                (setq stats-fault-codes-observed (append stats-fault-codes-observed (list stats-fault-code)))
            })
        })
    })
})

(spawn thread-stats)
