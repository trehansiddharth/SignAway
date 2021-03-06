setup_psoc:
    setb pcs

    ret

; Writes 16-bit data to the PSoC
write_psoc:
    push acc

    ; Lower PCS
    clr pcs

    ; Write the opcode
    mov a, opcode
    lcall write_spi

    ; Write the data
    mov a, data
    lcall write_spi

    ; Raise PCS
    setb pcs

    pop acc
    ret
