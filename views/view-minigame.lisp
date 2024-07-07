@const-start

(defun init-multiplayer () {
    (def my-addr (get-mac-addr))
    (def broadcast-addr '(255 255 255 255 255 255))
    (def host-id (+
        (ix my-addr 0)
        (ix my-addr 1)
        (ix my-addr 2)
        (ix my-addr 3)
        (ix my-addr 4)
        (ix my-addr 5)
    ))
    (def peer-id -1)
    (def is-connected false)
    (def peer-connected false)
    (def min-rssi -70)

    (event-enable 'event-esp-now-rx)

    (esp-now-start)
    (esp-now-add-peer broadcast-addr) ; Add broadcast address as peer
})

(defun send-code (str)
    (def esp-send-res (if (esp-now-send peer-addr str) 1 0))
)

(defun send-gamedata () {
    (if (> host-id peer-id) {
        ; Device with higher ID is in control
        (send-code (flatten (list paddle-x ball-x ball-x-rate ball-y ball-y-rate)))
    } (send-code (str-from-n paddle-x "(def paddle-peer-x %d)")))
})

(defun rx-gamedata (flat-data) {
    (var value-list (unflatten flat-data))
    ;(print (list "host values" value-list))
    (if (eq (type-of value-list) 'type-list) {
        (def ball-x-old ball-x)
        (def ball-y-old ball-y)
        (disp-render buf-ball ball-x-old ball-y-old '(0x000000 0x000000)) ; Clear old position
        
        (def paddle-peer-x (ix value-list 0))
        (def ball-x (ix value-list 1))
        (def ball-x-rate (ix value-list 2))
        (def ball-y (ix value-list 3))
        (def ball-y-rate (ix value-list 4))

        (disp-render buf-ball ball-x ball-y '(0x000000 0xfbfcfc)) ; Draw new position
    } (eval (read flat-data)))
})

; ESP-NOW RX Handler
(defun proc-data (src des data rssi) {
    (if (and (eq des broadcast-addr) (not is-connected)) {
        (if (> rssi min-rssi) {
            ; Handle broadcast data
            (def peer-addr src)
            (def peer-id (+
                (ix peer-addr 0)
                (ix peer-addr 1)
                (ix peer-addr 2)
                (ix peer-addr 3)
                (ix peer-addr 4)
                (ix peer-addr 5)
            ))
            (esp-now-add-peer src)
            (def peer-connected true)
            (eval (read data))
        } (print rssi))
    })
    (if (eq des my-addr) {
        ; Handle data sent directly to us
        (def esp-rx-rssi rssi)
        (if (> host-id peer-id)
            (eval (read data))
            (rx-gamedata data)
        )
    })
    (free data)
})

(defun view-init-minigame () {
    (init-multiplayer)

    (def buf-game-over (img-buffer 'indexed4 196 60))
    (def game-score 0)
    (def game-seconds 0)
    (def game-start-time (systime))

    (def paddle-peer-x 0)
    (def paddle-peer-y 42)
    (def buf-paddle-peer (img-buffer 'indexed2 320 10))

    (def game-over nil)
    (def ball-size 9)
    (def buf-ball (img-buffer 'indexed2 (+ ball-size 1) (+ ball-size 1)))
    (def ball-x (mod (rand) 319))
    (def ball-x-rate 0.8)
    (def ball-y (+ paddle-peer-y ball-size (mod (rand) 20)))
    (def ball-y-rate 1.0)
    
    (def ball-x-old ball-x)
    (def ball-y-old ball-y)

    (img-rectangle buf-ball 0 0 ball-size ball-size 1 `(rounded ,(- (/ ball-size 2) 1)) '(filled))

    (def buf-paddle (img-buffer 'indexed2 320 10))
    (def paddle-x 0)
    (def paddle-y 200)
    (def paddle-width 40)

    (view-init-menu)
    (defun on-btn-0-pressed () {
        (if (> (- paddle-x 3) 0) (setq paddle-x (- paddle-x 3)))
    })
    (defun on-btn-0-repeat-press () {
        (if (> paddle-x 0) (setq paddle-x (- paddle-x 1)))
    })

    (defun on-btn-1-pressed () {
        ; Reset Game
        ; (disp-clear)
        ; (view-render-menu)
        ; (def game-over false)
        ; (def ball-x (mod (rand) 319))
        ; (def ball-x-rate 0.8)
        ; (def ball-y (+ paddle-peer-y ball-size (mod (rand) 20)))
        ; (def ball-y-rate 1.0)
        ; (img-clear buf-game-over)
        ; (def game-score 0)
        ; (def game-start-time (systime))

        (if is-connected {
            ; Remove peer and disconnect
            (esp-now-del-peer peer-addr)
            (def is-connected false)
        })

        ; Connect to peer and start game
        (loopwhile (not is-connected) {
            (print "Looking for peer")
            (esp-now-send broadcast-addr "(print \"Peer is ready to play\")")
            (if peer-connected
                (if (esp-now-send peer-addr "(def is-connected true)")
                    (def is-connected true)
                )
            )
            (sleep 1.0)
        })
    })
    (defun on-btn-2-pressed () {
        (def state-view-next 'view-dash-primary)
    })
    (defun on-btn-3-pressed () {
        (if (< (+ paddle-x paddle-width 3) 320) (setq paddle-x (+ paddle-x 3)))
    })
    (defun on-btn-3-repeat-press () {
        (if (< (+ paddle-x paddle-width) 320) (setq paddle-x (+ paddle-x 1)))
    })

    ; Render Menu
    (view-draw-menu 'arrow-left "PLAY" "EXIT" 'arrow-right)
    (view-render-menu)
})

(defunret view-draw-minigame () {
    (if (not is-connected) {
        (sleep 1)
        (print "not connected")
        (return)
    })

    (if game-over {
        (txt-block-c buf-game-over (list 0 1 2 3) (/ (first (img-dims buf-game-over)) 2) 6 font15 (list
            (to-str "Game Over")
            (str-merge (str-from-n game-score "%d point") (if (not-eq game-score 1) "s" ""))
            (str-merge (str-from-n game-seconds "%d second") (if (not-eq game-seconds 1) "s" ""))
        ))
        (return)
    })

    (if (> host-id peer-id) {
        ; Calculate all of the things
        ;; Handle Ball
        (def ball-x-old ball-x)
        (def ball-y-old ball-y)
        (setq ball-x (+ ball-x ball-x-rate))
        (setq ball-y (+ ball-y ball-y-rate))

        ; Bounds check
        (if (or 
            (<= ball-x 2)
            (>= (+ ball-x ball-size) 318)
        ) (setq ball-x-rate (* ball-x-rate -1.0)))
        (if (< ball-y 1) (setq ball-y-rate (* ball-y-rate -1.0)))


        ; Out of bounds detection
        (if (> (+ ball-y ball-size) paddle-y) {
            ; (print "game over")
            ; (def game-over true)
            ; (def game-seconds (to-i (secs-since game-start-time)))
            ; (return)
            (setq ball-y-rate (* ball-y-rate -1.0))
        })

        ; Paddle detection
        ;if ball-y + ball-size >= paddle-y 
        ; & ball-x + 0.5 ball-size > paddle-x && < paddle-x + paddle-width
        (if (and (>= (+ ball-y ball-size) paddle-y)
                (and (> (+ ball-x (* 0.5 ball-size)) paddle-x) ; center of ball after paddle-x start
                    (< (+ ball-x (* 0.5 ball-size)) (+ paddle-x paddle-width)) ; center of ball before paddle-x + paddle-width
                )
            )
            {
                (var max-rate-x-abs 2)
                ; Adjust speed
                (if (< (abs ball-y-rate) 10) (setq ball-y-rate (+ ball-y-rate 0.2 )))
                ; Adjust direction
                (setq ball-y-rate (* ball-y-rate -1.0))

                ; Random angle
                ;(setq ball-x-rate (+ ball-x-rate (* (- (mod (rand) 200) 100) 0.01)))
                ; Set angle based on input angle vs paddle position
                ;
                ; Where did the ball touch?
                (var ball-x-touch-pos (+ ball-x (* 0.5 ball-size)))
                (var ball-paddle-pos (/ (- ball-x-touch-pos paddle-x) paddle-width))
                (print (list "ball hit x "  ball-x-touch-pos "paddle pos" paddle-x "calc" ball-paddle-pos))


                (setq ball-x-rate (* (- (* ball-paddle-pos 2) 1 ) (* ball-y-rate -1)))
                (print (list "xrate" ball-x-rate))
                
            }
        )

        ; Peer Paddle detection
        ;if ball-y <= paddle-peer-y + paddle-height
        ; & ball-x + 0.5 ball-size > paddle-peer-x && < paddle-peer-x + paddle-width
        (if (and (<= ball-y (+ paddle-peer-y 8))
                (and (> (+ ball-x (* 0.5 ball-size)) paddle-peer-x) ; center of ball after paddle-peer-x start
                    (< (+ ball-x (* 0.5 ball-size)) (+ paddle-peer-x paddle-width)) ; center of ball before paddle-peer-x + paddle-width
                )
            )
            {
                (var max-rate-x-abs 2)
                ; Adjust speed
                (if (< (abs ball-y-rate) 10) (setq ball-y-rate (+ ball-y-rate 0.2 )))
                ; Adjust direction
                (setq ball-y-rate (* ball-y-rate -1.0))

                ; Random angle
                ;(setq ball-x-rate (+ ball-x-rate (* (- (mod (rand) 200) 100) 0.01)))
                ; Set angle based on input angle vs paddle position
                ;
                ; Where did the ball touch?
                (var ball-x-touch-pos (+ ball-x (* 0.5 ball-size)))
                (var ball-paddle-pos (/ (- ball-x-touch-pos paddle-peer-x) paddle-width))
                (print (list "ball hit peer x "  ball-x-touch-pos "paddle pos" paddle-peer-x "calc" ball-paddle-pos))


                (setq ball-x-rate (* (- (* ball-paddle-pos 2) 1 ) (* ball-y-rate -1)))
                (print (list "xrate" ball-x-rate))
                
            }
        )
    } {
        ; Take it easy and enjoy your host

    })

    ;; Handle paddle
    (img-clear buf-paddle)
    (img-rectangle buf-paddle paddle-x 0 paddle-width 8 1 '(rounded 3) '(filled))
    (img-clear buf-paddle-peer)
    (img-rectangle buf-paddle-peer paddle-peer-x 0 paddle-width 8 1 '(rounded 3) '(filled))
    
    ;; Send game data to peer
    (send-gamedata)
})

(defun view-render-minigame () {
    (if (not game-over) {

        (if (> host-id peer-id) {
            (disp-render buf-paddle 0 paddle-y '(0x000000 0xfbfcfc))
            (disp-render buf-paddle-peer 0 paddle-peer-y '(0x000000 0xfbfcfc))

            (disp-render buf-ball ball-x-old ball-y-old '(0x000000 0x000000)) ; Clear old position
            (disp-render buf-ball ball-x ball-y '(0x000000 0xfbfcfc))
        } {
            (disp-render buf-paddle 0 paddle-peer-y '(0x000000 0xfbfcfc))
            (disp-render buf-paddle-peer 0 paddle-y '(0x000000 0xfbfcfc))
        })

    } (disp-render buf-game-over (- 160 (/ (first (img-dims buf-game-over)) 2)) (+ paddle-peer-y 42) '(0x000000 0x4f514f 0x929491 0xfbfcfc)))
})

(defun view-cleanup-minigame () {
    (def buf-paddle nil)
    (def buf-paddle-peer nil)
    (def buf-game-over nil)
    (def buf-ball nil)
})
