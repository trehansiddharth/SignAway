; ABS(ACC) -> ACC
abs:
    ; Check if number is positive or negative
    jnb acc.7, abs_do_nothing

    ; Negate the number
    cpl a
    inc a

    abs_do_nothing:
    ; Return the number
    ret

; ABS(R1 R0) -> R1 R0
abs16:
    mov a, r1
    jnb acc.7, abs16_do_nothing

    ; Negate the number
    mov a, r0
    cpl a
    inc a
    mov r0, a

    mov a, r1
    cpl a
    mov r1, a

    abs16_do_nothing:
    ; Return the number
    ret

; R1 R0 + R3 R2 -> R1 R0
add16:
    mov a, r0
    add a, r2
    mov r0, a

    mov a, r1
    addc a, r3
    mov r1, a

    ret

; R1 R0 >= R3 R2 -> C
gtreq16:
	mov a, r1
	cjne a, 03h, gtreq16_exit
	mov a, r0
	cjne a, 02h, gtreq16_exit
	setb c
	gtreq16_exit:
		ret