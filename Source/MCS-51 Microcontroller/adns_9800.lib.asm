setup_adns:
    push acc

    ; Set both NCS and SCLK high for initial state
    setb ncs
    setb sclk

	; Set MISO high to use it as an input
	setb miso

    ; Set constants that will be used in write_spi and read_spi
    mov a, #sclk
    anl a, #07h
    mov r0, a
    mov a, #01h
    lcall shl_acc
    mov sclk_high, a
    cpl a
    mov sclk_low, a

    mov a, #mosi
    anl a, #07h
    mov r0, a
    mov a, #01h
    lcall shl_acc
    mov mosi_high, a
    cpl a
    mov mosi_low, a

    mov a, #miso
    anl a, #07h
    mov r0, a
    mov a, #01h
    lcall shl_acc
    mov miso_mask, a

    pop acc
    ret

powerup_adns:
	; Reset the hardware
	lcall reset_adns

	; Wait 50ms
	mov scratch, #62h
	outer_powerup_delay_loop:
		push scratch
		mov scratch, #0ffh
		inner_powerup_delay_loop:
			djnz scratch, inner_powerup_delay_loop
		pop scratch
		djnz scratch, outer_powerup_delay_loop

	; Read registers 02h, 03h, 04h, 05h, and 06h
	mov address, #02h
	lcall read_adns

	lcall delay_r

	inc address
	lcall read_adns

	lcall delay_r

	inc address
	lcall read_adns

	lcall delay_r

	inc address
	lcall read_adns

	lcall delay_r

	inc address
	lcall read_adns

	lcall delay_r

	; Enable laser
	lcall enable_laser

	ret

reset_adns:
	; Write to Power_Up_Reset register
	mov address, #3ah
	mov data, #5ah
	lcall write_adns
	ret

shutdown_adns:
	; Unimplemented!
	ret

enable_laser:
	; Read LASER_CTRL0
	mov address, #20h
	lcall read_adns
	mov a, data

	lcall delay_r

    ; Clear bit 0 (FORCE_DISABLE) and write it back
	clr acc.0
	mov data, a
	lcall write_adns

	ret

disable_laser:
    ; Read LASER_CTRL0
    mov address, #20h
    lcall read_adns
    mov a, data

    lcall delay_r

    ; Set bit 0 (FORCE_DISABLE) and write it back
    setb acc.0
    mov data, a
    lcall write_adns

    ret

motion_burst:
    push acc

    ; Lower NCS
    clr ncs

    ; Write 50h to the MOTION_BURST register
    mov a, #0d0h
    lcall write_spi

    mov a, #50h
    lcall write_spi

    ; Wait for a frame
    lcall delay_frame
	
	; Read from the MOTION_BURST register
	mov a, #50h
	lcall write_spi

    ; Read 14 registers
    mov dptr, #motion_store
    mov top_high, #motion_store_top_high
    mov top_low, #motion_store_top_low
    lcall burst

    ; Raise NCS
    setb ncs
	
	; Clear motion register
	mov address, #02h
	mov data, #00h
	lcall write_adns

    pop acc
	ret

image_burst:
    push acc

	; Reset the hardware
	lcall reset_adns

	; Enable the laser
	lcall enable_laser

	; Lower NCS
	clr ncs

	; Write 93h to FRAME_CAPTURE register
	mov a, #92h
	lcall write_spi
	mov a, #93h
	lcall write_spi

	lcall delay_w

	; Write c5h to FRAME_CAPTURE register
	mov a, #92h
	lcall write_spi
	mov a, #0c5h
	lcall write_spi

	setb ncs

	lcall delay_w

	mov scratch, #0feh
	lcall delay

	clr ncs

	; Wait for the LSB in MOTION register to be set
	await_motion_bit:
		; Read the MOTION register
		mov a, #02h
		lcall write_spi

		mov scratch, #40h
		lcall delay

		lcall read_spi

		lcall delay_r

		; Loop again if the LSB is not set
		jnb acc.0, await_motion_bit

	; Tell the chip to read register 64
	mov a, #64h
	lcall write_spi

    ; Wait for 2 frames
	lcall delay_frame
    lcall delay_frame

	; Read 900 pixels
    mov dptr, #image_store
    mov top_high, #image_store_top_high
    mov top_low, #image_store_top_low
    lcall burst

	; Raise NCS back high
	setb ncs

    pop acc
    ret

burst:
    burst_loop:
        ; Read the next incoming byte
        lcall read_spi

        ; Store it in memory
        movx @dptr, a

        ; Increment dptr
        inc dptr

        ; Wait for a bit
        mov scratch, #08h
        lcall delay

        ; Loop if necessary
        mov a, dpl
        cjne a, top_low, burst_loop
        mov a, dph
        cjne a, top_high, burst_loop
    ret

write_adns:
    push acc

    ; Set NCS for ADNS-9800 low
    clr ncs

    ; Write the address (with MSB set high) on the SPI line
    mov a, address
    orl a, #80h
    lcall write_spi

    ; Write the data on the SPI line
    mov a, data
    lcall write_spi

    ; Set NCS high again
    setb ncs

    pop acc
    ret

read_adns:
    push acc

    ; Set NCS for ADNS-9800 low
    clr ncs

    ; Write the address (with MSB set low) on the SPI line
    mov a, address
    anl a, #7fh
    lcall write_spi

    ; Wait for 120 microseconds (1 frame)
    lcall delay_frame

	; Set MISO pin high to be able to read
	setb miso

    ; Read the data from the SPI line and put it on the accumulator
    lcall read_spi
    mov data, a

    ; Set NCS high again
    setb ncs

    pop acc
    ret

delay_w:
	mov scratch, #40h
	lcall delay
	ret

delay_r:
	mov scratch, #0ah
	lcall delay
	ret

delay_frame:
    mov scratch, #40h
    lcall delay
    ret
