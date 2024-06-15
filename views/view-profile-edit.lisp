@const-start

; Level 0: Selecting which option to edit
(defun set-menu-select-option () {
    (defun on-btn-0-pressed () {
        (def state-view-next 'view-profile-select)
    })

    ; TODO: select previous option (wrap to end)
    ; TODO: select next option (wrap to start)

    (defun on-btn-3-pressed () {
        (setq view-profile-mode 'edit-option)
        (set-menu-edit-option)
    })

    ; Render menu
    (view-draw-menu "BACK" 'arrow-down 'arrow-up "EDIT")
    (view-render-menu)
})

; Level 1: Selecting value for current option being edited
(defun set-menu-edit-option () {
    (defun on-btn-0-pressed () {
        (setq view-profile-mode 'select-option)
        (set-menu-select-option)
    })

    ; TODO: decrease value
    ; TODO: increase value

    (defun on-btn-3-pressed () {
        ; TODO: save
        ; (write-setting 'name 'value)
    })
    ; Render menu
    (view-draw-menu "BACK" 'arrow-down 'arrow-up "SAVE")
    (view-render-menu)
})

(defun view-init-profile-edit () {
    (var buf-title (img-buffer 'indexed4 240 30))
    (txt-block-r buf-title (list 0 1 2 3) 240 0 font18 (to-str "Edit Profile 1"))
    (disp-render buf-title 80 4 '(0x000000 0x4f514f 0x929491 0xfbfcfc))

    (def view-profile-mode 'select-option)
    (set-menu-select-option)
})

(defun view-draw-profile-edit () {
    
})

(defun view-render-profile-edit () {
    
})

(defun view-cleanup-profile-edit () {
    
})
