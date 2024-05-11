@const-symbol-strings

(def init-complete nil)
(loopwhile (not (main-init-done)) (sleep 0.1))

@const-start

(import "pkg::disp-text@://vesc_packages/lib_disp_ui/disp_ui.vescpkg" 'disp-text)
(read-eval-program disp-text)

(import "pkg::disp-button@://vesc_packages/lib_disp_ui/disp_ui.vescpkg" 'disp-button)
(read-eval-program disp-button)

(import "pkg::disp-gauges@://vesc_packages/lib_disp_ui/disp_ui.vescpkg" 'disp-gauges)
(read-eval-program disp-gauges)

(import "fonts/font_12_15_aa.bin" 'font15)
(import "fonts/font_15_18_aa.bin" 'font18)
;;(import "fonts/font_22_24.bin" 'font24)
(import "fonts/font_60_88_aa.bin" 'font88)
(import "fonts/font_77_128_aa.bin" 'font128)

(import "assets/speed-stripe-4c.bin" 'icon-stripe)
(import "assets/motor-4c.bin" 'icon-motor)
(import "assets/esc-4c.bin" 'icon-esc)
(import "assets/battery-4c.bin" 'icon-battery)
(import "assets/warning-4c.bin" 'icon-warning)
;;(import "assets/service-4c.bin" 'icon-service)

(import "lib/user-settings.lisp" 'code-user-settings)
(read-eval-program code-user-settings)

(import "lib/statistics.lisp" 'code-statistics)
(read-eval-program code-statistics)

(import "views/components/view-menu.lisp" 'code-view-menu)
(read-eval-program code-view-menu)

(import "views/view-dash-primary.lisp" 'code-view-dash-primary)
(read-eval-program code-view-dash-primary)

(import "views/view-speed-large.lisp" 'code-view-speed-large)
(read-eval-program code-view-speed-large)

(import "views/view-statistics.lisp" 'code-view-statistics)
(read-eval-program code-view-statistics)

(import "views/view-minigame.lisp" 'code-view-minigame)
(read-eval-program code-view-minigame)

(import "lib/input.lisp" 'code-input)
(read-eval-program code-input)

(import "lib/display-utils.lisp" 'code-display-utils)
(read-eval-program code-display-utils)

(import "lib/draw-utils.lisp" 'code-draw-utils)
(read-eval-program code-draw-utils)

(import "lib/communication.lisp" 'code-communication)
(read-eval-program code-communication)

@const-end

(display-init)

;(import "tests/display-tests.lisp" 'code-display-tests)
;(read-eval-program code-display-tests)

(def init-complete true)
