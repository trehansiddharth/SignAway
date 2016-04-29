; Change to 2051.h.asm to target 2051 microcontroller:
.inc 8051.h.asm

.org 000h
sjmp main

.org 003h
int0_isr:
	ljmp on_motion

.org 050h
main:
	; Setup the serial port
	lcall setup_serial
	
	; Configure external interrupt 0 to be on falling edge
	setb tcon.0
	
	; Enable external interrupt 0
	mov ie, #81h
	
	; Peace out
	main_loop:
		sjmp main_loop

on_motion:
	mov a, #42h
	lcall crlf
	lcall prthex
	
	reti
