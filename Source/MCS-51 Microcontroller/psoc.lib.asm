setup_psoc:
    setb pcs

send_psoc:
    ; Send the opcode
    mov ctrl, opcode
    clr pcs
    setb pcs

    ; Wait for the PSoC to process it
    mov scratch, #40h
    lcall delay

    ; Send the data
    mov ctrl, data
    clr pcs
    setb pcs

    ret
