getcmd:
    lcall getchr           ; get the single-letter command
    clr   acc.5            ; make upper case
    lcall sndchr           ; echo command
    clr   C                ; clear the carry flag
    subb  a, #'@'          ; convert to command number
    jnc   cmdok1           ; letter command must be above '@'
    lcall badcmd
cmdok1:
    push  acc              ; save command number
    subb  a, #1Bh          ; command number must be 1Ah or less
    jc    cmdok2
    lcall badcmd           ; no need to pop acc since badpar
                          ; initializes the system
cmdok2:
    pop   acc              ; recall command number
    ret

nway:
    mov   dptr, #jumtab    ;point dptr at beginning of jump table
    mov   a, r2            ;load acc with monitor routine number
    rl    a                ;multiply by two.
    inc   a                ;load first vector onto stack
    movc  a, @a+dptr       ;         "          "
    push  acc              ;         "          "
    mov   a, r2            ;load acc with monitor routine number
    rl    a                ;multiply by two
    movc  a, @a+dptr       ;load second vector onto stack
    push  acc              ;         "          "
    ret                    ;jump to start of monitor routine
