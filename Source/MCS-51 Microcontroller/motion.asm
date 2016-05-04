; Change to 2051.h.asm to target 2051 microcontroller:
.inc 8051.h.asm

.org 000h
sjmp main

.org 050h
main:
	; Move stack pointer to where we want it
	mov sp, #stack

	; Setup the serial port
	lcall setup_serial

	; Setup and power up the ADNS-9800 chip
	lcall setup_adns
	lcall powerup_adns

	; Set the resolution to be 200 cpi by setting the CONFIGURATION_I register to 01h
	mov address, #0fh
	mov data, #01h
	lcall write_adns

	; Setup the SPI connection with the PSoC
	lcall setup_psoc

	; Disable interrupts
	clr ea

	; Clear absolute positions
	mov x_low, #00h
	mov x_high, #00h
	mov y_low, #00h
	mov y_high, #00h

	mov last_x_low, #00h
	mov last_x_high, #00h
	mov last_y_low, #00h
	mov last_y_high, #00h

	; Print welcome message
	lcall print
	.db 0ah, 0dh, "Welcome to the motion machine!", 00h

	; Keep running motion burst to keep an accumulated absolute position
	main_loop:
		; Run motion burst
		lcall motion_burst

		; Read the DELTA_X_* registers
		mov a, #02h
		lcall grab_register
		mov r0, a

		mov a, #03h
		lcall grab_register
		mov r1, a

		; Update the x position
		clr c

		mov a, x_low
		add a, r0
		mov x_low, a

		mov a, x_high
		addc a, r1
		mov x_high, a

		; Read the DELTA_Y_* registers
		mov a, #04h
		lcall grab_register
		mov r0, a

		mov a, #05h
		lcall grab_register
		mov r1, a

		; Update the y position
		clr c

		mov a, y_low
		add a, r0
		mov y_low, a

		mov a, y_high
		addc a, r1
		mov y_high, a

		; Debugging!
		lcall print
		.db 0ah, 0dh, "(", 0h
		mov a, x_high
		lcall prthex
		mov a, x_low
		lcall prthex

		lcall print
		.db ", ", 0h
		mov a, y_high
		lcall prthex
		mov a, y_low
		lcall prthex

		lcall print
		.db ") ", 0h

		sjmp main_loop

grab_register:
	mov dptr, #motion_store
	movc a, @a+dptr
	ret

.inc adns_9800.lib.asm

.inc spi.lib.asm

.inc psoc.lib.asm

.inc serial.lib.asm

.inc util.lib.asm
