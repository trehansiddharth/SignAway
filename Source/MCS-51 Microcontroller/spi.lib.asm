write_spi:
    push 00h

    ; Set up the loop so it only runs 8 times (one for each bit of the data in acc)
    mov r0, #08h
    write_adns_loop:
        ; Get the next bit in acc (from MSB to LSB)
        rl a
        push acc
        jnb acc.0, write_bit_not_set

        ; Run SCLK low and MOSI high
        write_bit_set:
            mov a, ctrl
            anl a, sclk_low
            orl a, mosi_high
            sjmp write_resume

        ; Run SCLK low and MOSI low
        write_bit_not_set:
            mov a, ctrl
            anl a, sclk_low
            anl a, mosi_low
            sjmp write_resume

        write_resume:
            ; Write new SCLK and MOSI
            mov ctrl, a

            ; Set SCLK high
            orl a, sclk_high
            mov ctrl, a

            pop acc
            djnz r0, write_adns_loop

    pop 00h
    ret

read_spi:
    push 00h

	; Set MOSI low so the chip doesn't think we're writing to it
	clr mosi

    ; Set up the loop so it only runs 8 times (one for each bit of the data in acc)
    mov r0, #08h
    read_adns_loop:

        ; Shift to the next digit
        rl a
        push acc

        ; Set SCLK low
        mov a, sclk_low
        anl ctrl, a

        ; Set SCLK high
        mov a, sclk_high
        orl ctrl, a

        ; Get the next bit from the control register (from MSB to LSB)
        pop acc
        jnb miso, read_bit_not_set

        ; Set acc.0
        read_bit_set:
            setb acc.0
            sjmp read_resume

        ; Clear acc.0
        read_bit_not_set:
            clr acc.0
            sjmp read_resume

        read_resume:
            djnz r0, read_adns_loop

    pop 00h
    ret
