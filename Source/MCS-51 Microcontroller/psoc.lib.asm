setup_psoc:
    setb pcs

    ret

write_psoc:
    push acc

    ; Lower PCS
    clr pcs

    ; Write the data
    mov a, data
    lcall write_spi

    ; Raise PCS
    setb pcs

    pop acc
    ret
