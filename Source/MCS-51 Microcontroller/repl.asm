; Change to 2051.h.asm to target 2051 microcontroller:
.inc 8051.h.asm

.org 000h
sjmp main

.org 003h
int0_isr:
	ljmp on_motion

.org 050h
main:
    ; Disable external interrupts
    clr ea

    ; Setup serial communication
    lcall setup_serial

    ; Initialize pins for the ADNS-9800
    lcall setup_adns

    ; Print welcome message
    lcall print
    .db 0ah, 0dh, "Welcome to the SignAway REPL!", 00h

    repl:
        ; Reinitialize stack pointer
        mov sp, #stack

		; Clear the error bit
		clr errorf

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
   .dw imageb             ; command 'i' 09 used
   .dw badcmd             ; command 'j' 0a
   .dw badcmd             ; command 'k' 0b
   .dw badcmd             ; command 'l' 0c
   .dw motbst             ; command 'm' 0d used
   .dw badcmd             ; command 'n' 0e
   .dw badcmd             ; command 'o' 0f
   .dw powrup             ; command 'p' 10 used
   .dw badcmd             ; command 'q' 11
   .dw readrg             ; command 'r' 12 used
   .dw shutdn             ; command 's' 13 used
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
	jb errorf, jump_badcmd
    mov address, a
    lcall prthex

    ; Read that register from the ADNS 9800
    lcall read_adns

	; Print the result
	lcall crlf
    mov a, data
    lcall prthex

    ljmp repl

writrg:
    ; Get the address
    lcall getbyt
	jb errorf, jump_badcmd
    mov address, a
    lcall prthex

    ; Something like an equal sign
    lcall getchr
    lcall sndchr

    ; Get the data to write
    lcall getbyt
	jb errorf, jump_badcmd
    mov data, a
    lcall prthex

    ; Write that value to that register on the ADNS 9800
    lcall write_adns

    ljmp repl

jump_badcmd:
	ljmp badcmd

powrup:
	lcall powerup_adns
	lcall print
	.db 0ah, 0dh, "ADNS-9800 powered up.", 00h

	ljmp repl

shutdn:
	lcall shutdown_adns
	lcall print
	.db 0ah, 0dh, "ADNS-9800 shut down.", 00h

	ljmp repl

imageb:
	lcall image_burst

	; Loop to output 900 pixel values to serial
    mov dptr, #image_store
	mov top_high, #image_store_top_high
	mov top_low, #image_store_top_low
	lcall print_burst

	ljmp repl

motbst:
	lcall motion_burst
	
	; Loop to output 14 register values to serial
	mov dptr, #motion_store
	mov top_high, #motion_store_top_high
	mov top_low, #motion_store_top_low
	lcall print_burst

	ljmp repl

print_burst:
	lcall crlf
	print_burst_loop:
		; Read the next incoming byte
		movx a, @dptr

		; Output to serial
		lcall prthex

		; Increment dptr
		inc dptr

		; Loop if necessary
		mov a, dpl
		cjne a, top_low, print_burst_loop
		mov a, dph
		cjne a, top_high, print_burst_loop
	ret

on_motion:
	setb b.0
	reti

.inc adns_9800.lib.asm

.inc spi.lib.asm

.inc psoc.lib.asm

.inc serial.lib.asm

.inc util.lib.asm
