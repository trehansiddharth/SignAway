.inc project.h.asm

.inc adns_9800.h.asm

.org 0000h
sjmp main

.org 0050h
main:
    ; Disable external interrupts
    clr ea

    ; Setup serial communication
    lcall setup_serial

    ; Initialize pins for the ADNS 9800
    lcall setup_adns

    ; Print welcome message
    lcall print
    .db 0ah, 0dh, "Welcome to the SignAway REPL!", 00h

    repl:
        ; Reinitialize stack pointer
        mov sp, #stack

        ; Print REPL prompt
        lcall print
        .db 0ah, 0dh, "> ", 0h

        ; Get the next command from the serial port
        lcall getcmd

        ; Go to the appropriate subroutine based on the command we get
        mov r2, a
        ljmp nway

        ; What to do in case of error:
        badcmd:
            lcall print
            .db 0ah, 0dh, "Bad command.", 00h
            ljmp repl

.inc minmon.lib.asm

jumtab:
   .dw badcmd             ; command '@' 00
   .dw badcmd             ; command 'a' 01
   .dw badcmd             ; command 'b' 02
   .dw badcmd             ; command 'c' 03
   .dw badcmd             ; command 'd' 04
   .dw badcmd             ; command 'e' 05
   .dw badcmd             ; command 'f' 06
   .dw badcmd             ; command 'g' 07
   .dw badcmd             ; command 'h' 08
   .dw badcmd             ; command 'i' 09
   .dw badcmd             ; command 'j' 0a
   .dw badcmd             ; command 'k' 0b
   .dw badcmd             ; command 'l' 0c
   .dw badcmd             ; command 'm' 0d
   .dw badcmd             ; command 'n' 0e
   .dw badcmd             ; command 'o' 0f
   .dw badcmd             ; command 'p' 10
   .dw badcmd             ; command 'q' 11
   .dw readrg             ; command 'r' 12 used
   .dw badcmd             ; command 's' 13
   .dw badcmd             ; command 't' 14
   .dw badcmd             ; command 'u' 15
   .dw badcmd             ; command 'v' 16
   .dw writrg             ; command 'w' 17 used
   .dw badcmd             ; command 'x' 18
   .dw badcmd             ; command 'y' 19
   .dw badcmd             ; command 'z' 1a

readrg:
    ; Get the address
    lcall getbyt
    mov address, a
    lcall prthex

    ; Read that register from the ADNS 9800
    lcall read_adns
    mov a, data
    lcall prthex

    ljmp repl

writrg:
    ; Get the address
    lcall getbyt
    mov address, a
    lcall prthex

    ; Something like an equal sign
    lcall getchr
    lcall sndchr

    ; Get the data to write
    lcall getbyt
    mov data, a
    lcall prthex

    ; Write that value to that register on the ADNS 9800
    lcall write_adns

    ljmp repl

.inc adns_9800.lib.asm

.inc serial.lib.asm

.inc util.lib.asm
