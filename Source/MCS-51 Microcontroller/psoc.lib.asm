setup_psoc:
    setb pcs

    ret

; Writes 16-bit data to the PSoC
write_psoc:
    push acc

    ; Lower PCS
    clr pcs

    ; Write the data
    mov a, r1
    lcall write_spi

    mov a, r0
    lcall write_spi

    ; Raise PCS
    setb pcs

    pop acc
    ret
