(def settings-units '(kmh . "Km/h"))

(defun setting-units-cycle () {
    (match (car settings-units) 
        (kmh (def settings-units '(mph . "MPH")))
        (mph (def settings-units '(kmh . "Km/h")))
        (_ (print "Unexpected settings-units value"))
    )
})
