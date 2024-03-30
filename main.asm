.model small
.stack 100h
.data
    head_x dw 0Ah
    head_y dw 0Ah 
    head_size dw 06h 
    body_x dw 25 dup (?)
    body_y dw 25 dup (?)
    body_size dw 0
    key_pressed db 'd'
    prev_key db ?
    time_now db 00h
    food_x dw 05h
    food_y dw 04h
    
    strScore db 'Score:'
    strScore_s equ $-strScore 

.code
    mov ax, @data
    mov ds, ax 
    mov es, ax 
    main:
        mov ax, 0013h
        int 10h
        mov ah, 0Bh
        mov bx, 0000h
        int 10h
        mov si, offset body_x
        mov di, offset body_y 
        mov word ptr [ds:si], 0Ah
        mov word ptr [ds:di], 0Ah
        call rng 
        game_loop:
            call input
            call draw
            call write_score
            call move
            call cls
            jmp game_loop
        
        ret    
    write_score:
        mov ax, 1300h ; interrupt for write string
        mov bx, 000Fh ; set page number and color of string
   
        mov dh, 0 ; row
        mov dl, 0 ; col
        mov cx, strScore_s ; size of string
        mov bp, offset strScore ; string in es:bp 
        int 10h

        mov ah, 02h         ; place cursor beside score string
        mov dl, 7
        int 10h
        
        mov ax, body_size   ; convert score to decimal
        aaa                 ; ah = tenths  |  al = ones
        mov dx, ax          
        add dh, '0'         ; convert to ascii
        add dl, '0'
        push dx

        mov ah, 09h         
        mov al, dh
        mov bx, 000Fh
        mov cx, 1
        int 10h             ; write tenths place

        mov ah, 02h         ; place cursor beside tenths place
        mov dh, 0           
        mov dl, 8
        int 10h

        pop dx
        mov ah, 09h
        mov al, dl
        int 10h             ; write ones place 
        ret

    cls: ; clears the screen
        mov ah, 07h          ; Scroll up function
        mov al, 0            ; Number of lines to scroll
        mov cx, 0
        mov dx, 9090
        mov bh, 00h          ; Clear entire screen
        int 10h
        ret
    draw:
        mov cx, head_x
        mov dx, head_y
        
        ;draw_head:
        ;    mov ax, 0c0fh
        ;    mov bh, 00h
        ;    int 10h             ; draw pixel

        ;    inc cx              
        ;    mov ax, cx
        ;    sub ax, head_x 
        ;    cmp ax, head_size
        ;    jle draw_head       ; check x axis

        ;    mov cx, head_x
        ;    inc dx 

        ;    mov ax, dx
        ;    sub ax, head_y
        ;    cmp ax, head_size 
        ;    jle draw_head       ; check y axis
        
        mov si, offset body_x
        mov di, offset body_y 
        mov bp, 0
        
        ;cmp body_size, 0  ; only draw body if body_size > 0
        ;je food

        body: 
            mov cx, [ds:si+bp]
            mov dx, [ds:di+bp]
        draw_body:
            mov ax, 0c0fh
            mov bh, 00h
            int 10h             ; draw pixel

            inc cx              
            mov ax, cx
            sub ax, [ds:si+bp] 
            cmp ax, head_size
            jle draw_body       ; check x axis

            mov cx, [ds:si+bp]
            inc dx 

            mov ax, dx
            sub ax, [ds:di+bp]
            cmp ax, head_size 
            jle draw_body    

            add bp, 2
            mov ax, body_size
            mov bx, 2
            mul bx 
            cmp bp, ax
            jle body

        food:
            mov cx, food_x
            mov dx, food_y    
        draw_food:
            mov ax, 0c04h
            mov bh, 00h
            int 10h   

            inc cx 
            mov ax, cx
            sub ax, food_x 
            cmp ax, head_size 
            jle draw_food 
            
            mov cx, food_x
            inc dx 
            mov ax, dx 
            sub ax, food_y
            cmp ax, head_size 
            jle draw_food 
        
        ret 
    
    input:
        mov ah, 01h ; get user input
        int 16h
    
        jz stop

        mov ah, 00h
        int 16h
        
        cmp al, '2' ; check if escape key
        jne update ; update key_pressed if not 2 
        mov ah, 4ch
        int 21h

        update:
            mov ah, key_pressed
            mov prev_key, ah
            mov key_pressed, al
           
    stop: ret 

    rng:
        mov ax, 25173
        mul word ptr food_x
        add ax, 13849
        mov food_x, ax

        mov ax, 25173
        mul word ptr food_y
        add ax, 13849
        mov food_y, bx
        ret
    
    move:
        mov ah, 2ch ; get system time
        int 21h
        cmp dl, time_now
        je move
        mov time_now, dl

        mov si, offset body_x 
        mov di, offset body_y

        ;mov cx, head_x
        ;mov dx, head_y
        ;mov [ds:si], cx
        ;mov [ds:di], dx
        mov bp, 2
        body_move: ; while moving, transfer the value of the head to the body
            mov ax, [ds:si+bp-2]
            mov [ds:si+bp], ax             ;0 
            mov ax, [ds:di+bp-2]
            mov [ds:di+bp], ax
            add bp, 2
            mov ax, body_size
            mov bx, 2
            mul bx
            cmp bp, ax
            jl body_move
        
        mov ax, head_size
        cmp key_pressed, 'w'
        je move_up 
        cmp key_pressed, 'a' 
        je move_left
        cmp key_pressed, 's'
        je move_down 
        cmp key_pressed, 'd'
        je move_right
        jmp ignore
        move_up:
            cmp prev_key, 's'
            je ignore
            sub word ptr [ds:di], ax 
            jmp collision 
        move_down: 
            cmp prev_key, 'w'
            je ignore
            add word ptr [ds:di], ax
            jmp collision 
        move_left: 
            cmp prev_key, 'd'
            je ignore
            sub word ptr [ds:si], ax
            jmp collision 
        move_right: 
            cmp prev_key, 'a'
            je ignore
            add word ptr [ds:si], ax 
            jmp collision
        ignore:
            mov ah, prev_key
            mov key_pressed, ah
        
        collision:      ; checks for collision with fruit
            mov cx, word ptr [ds:si]
            mov dx, word ptr [ds:di]
            mov ah, 0dh
            mov bh, 00h
            int 10h 

            cmp al, 04h
            jne return 
            mov ax, body_size
            inc ax 
            mov body_size, ax
            call rng 
            
        return: ret

end