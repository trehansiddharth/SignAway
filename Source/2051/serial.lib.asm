setup_serial:
    mov   tmod, #20h
    mov   tcon, #41h
    mov   th1,  #0fdh
    mov   scon, #50h
    ret

sndchr:
    clr scon.1
    mov sbuf, a
    txloop:
        jnb scon.1, txloop
    ret

getchr:
    jnb ri, getchr
    mov a,  sbuf
    anl a,  #7fh
    clr ri
    ret
