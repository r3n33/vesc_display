; Persistent settings
; Format: (label . (offset type))
(def eeprom-addrs '(
    (ver-code    . (0 i))
    (pf1-speed   . (1 f))
    (pf1-current . (2 f))
    (pf1-wattage . (3 i))
    (pf2-speed   . (4 f))
    (pf2-current . (5 f))
    (pf2-wattage . (6 i))
    (pf3-speed   . (7 f))
    (pf3-current . (8 f))
    (pf3-wattage . (9 i))
    (pf-active   . (10 i))
))

(defun print-settings ()
    (loopforeach it eeprom-addrs
        (print (list (first it) (read-setting (first it))))
))

(defun save-settings (  pf1-speed pf1-curent pf1-wattage
                        pf2-speed pf2-curent pf2-wattage
                        pf3-speed pf3-curent pf3-wattage
                        pf-active
)
    (progn
        (write-setting 'pf1-speed pf1-speed)
        (write-setting 'pf1-current pf1-curent)
        (write-setting 'pf1-wattage pf1-wattage)
        (write-setting 'pf2-speed pf2-speed)
        (write-setting 'pf2-current pf2-curent)
        (write-setting 'pf2-wattage pf2-wattage)
        (write-setting 'pf3-speed pf3-speed)
        (write-setting 'pf3-current pf3-curent)
        (write-setting 'pf3-wattage pf3-wattage)
        (write-setting 'pf-active pf-active)
        (print "Settings Saved!")
))

; Settings version
(def settings-version 42i32)

(defun read-setting (name)
    (let (
            (addr (first (assoc eeprom-addrs name)))
            (type (second (assoc eeprom-addrs name)))
        )
        (cond
            ((eq type 'i) (eeprom-read-i addr))
            ((eq type 'f) (eeprom-read-f addr))
            ((eq type 'b) (!= (eeprom-read-i addr) 0))
)))

(defun write-setting (name val)
    (let (
            (addr (first (assoc eeprom-addrs name)))
            (type (second (assoc eeprom-addrs name)))
        )
        (cond
            ((eq type 'i) (eeprom-store-i addr val))
            ((eq type 'f) (eeprom-store-f addr val))
            ((eq type 'b) (eeprom-store-i addr (if val 1 0)))
)))

(defun restore-settings ()
    (progn
        (write-setting 'pf1-speed 1.0)
        (write-setting 'pf1-current 1.0)
        (write-setting 'pf1-wattage 500)
        (write-setting 'pf2-speed 1.0)
        (write-setting 'pf2-current 1.0)
        (write-setting 'pf2-wattage 500)
        (write-setting 'pf3-speed 1.0)
        (write-setting 'pf3-current 1.0)
        (write-setting 'pf3-wattage 500)
        (write-setting 'pf-active 0)
        (write-setting 'ver-code settings-version)
        (print "Settings Restored!")
))

; Restore settings if version number does not match
; as that probably means something else is in eeprom
(if (not-eq (read-setting 'ver-code) settings-version) (restore-settings))
