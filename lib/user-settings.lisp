(def settings-units-speeds '(kmh . "Km/h"))
(def settings-units-temps '(celsius . "C"))

@const-start

(def km-to-mi 0.621371)
(defun c-to-f (c)
  (+ (* c 1.8) 32))

; Speeds and temps change together
(defun setting-units-cycle () {
    (match (car settings-units-speeds)
        (kmh {
            (def settings-units-speeds '(mph . "MPH"))
            (def settings-units-temps '(fahrenheit . "F"))
        })
        (mph {
            (def settings-units-speeds '(kmh . "Km/h"))
            (def settings-units-temps '(celsius . "C"))
        })
        (_ (print "Unexpected settings-units-speeds value"))
    )
})

; Alternatively a user can change only temps
(defun setting-units-cycle-temps () {
    (match (car settings-units-temps)
        (celsius (def settings-units-temps '(fahrenheit . "F")))
        (fahrenheit (def settings-units-temps '(celsius . "C")))
        (_ (print "Unexpected settings-units-temps value"))
    )
})
