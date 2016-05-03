; Change to 2051.h.asm to target 2051 microcontroller:
.inc 8051.h.asm

.org 000h
sjmp main

.org 003h
ext0_isr:
	ljmp on_button_press

.org 00bh
t0_isr:
	ljmp on_timer_tick

.org 013h
ext1_isr:
	ljmp on_psoc_request

.org 050h
main:
	; Setup the serial port
	lcall setup_serial

	; Setup and power up the ADNS-9800 chip
	lcall setup_adns
	lcall powerup_adns

	; Configure timer 0 so that it's in 16-bit mode
	mov tmod, #01h

	; Configure external interrupt 0 and external interrupt 1 to be on falling edge, and start timer 0
	mov tcon, #15h

	; Enable external interrupt 0, external interrupt 1, and timer 0 interrupt
	mov ie, #8dh

	; Peace out
	main_loop:
		sjmp main_loop

on_timer_tick:
	push acc
	push 00h
	push 01h

	; Read the motion register
	mov address, #02h
	lcall read_adns

	lcall delay_r

	; Read the DELTA_X_* registers
	mov address, #03h
	lcall read_adns
	mov a, data

	lcall delay_r

	inc address
	lcall read_adns
	mov r0, data

	; Update the x position
	add a, x_low
	mov x_low, a
	mov a, x_high
	addc a, r0
	mov x_high, a

	; Read the DELTA_Y_* registers
	mov address, #05h
	lcall read_adns
	mov a, data

	lcall delay_r

	inc address
	lcall read_adns
	mov r0, data

	; Update the y position
	add a, y_low
	mov y_low, a
	mov a, y_high
	addc a, r0
	mov y_high, a

	; Reload the timer
	mov th0, #timer_count_high
	mov tl0, #timer_count_low

	pop 01h
	pop 00h
	pop acc
	reti

on_button_press:
	; Check which button is pressed and call the appropriate subroutine
	reti

on_psoc_request:
	; Do the appropriate response to the PSOC's request
	reti
