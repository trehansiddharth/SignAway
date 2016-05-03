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

	; Disable interrupts
	clr ea
	
	; Clear absolute positions
	mov x_low, #00h
	mov x_high, #00h
	mov y_low, #00h
	mov y_high, #00h
	
	; Print welcome message
	lcall print
	.db 0ah, 0dh, "Welcome to the motion machine!", 00h

	; Read the motion registers every now and then
	main_loop:
		; Read the motion register
		mov address, #02h
		lcall read_adns

		lcall delay_r
		
		mov a, data
		jnb acc.7, main_loop
		
		on_motion:
			; Read the DELTA_X_* registers
			mov address, #03h
			lcall read_adns
			mov a, data

			lcall delay_r

			inc address
			lcall read_adns
			mov r0, data

			; Update the x position
			clr c
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
			clr c
			add a, y_low
			mov y_low, a
			mov a, y_high
			addc a, r0
			mov y_high, a
		
		mov address, #02h
		mov data, #00h
		lcall write_adns
		
		lcall delay_w
		
		; Debugging!
		lcall print
		.db 0ah, 0dh, "X: ", 0h
		mov a, x_high
		lcall prthex
		mov a, x_low
		lcall prthex
		
		sjmp main_loop

delay16:
	inc delay_high
	delay16_outer_loop:
		delay16_inner_loop:
			djnz delay_low, delay16_inner_loop
		djnz delay_high, delay16_outer_loop
	ret
	
.inc adns_9800.lib.asm

.inc spi.lib.asm

.inc psoc.lib.asm

.inc serial.lib.asm

.inc util.lib.asm
