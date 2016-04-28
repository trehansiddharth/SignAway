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
	; Set LASER_CTRL0 register to 0 (clear force-disable bit)
	mov address, #20h
	lcall read_adns
	mov a, data
	
	lcall delay_r
	
	clr acc.0
	mov data, a
	lcall write_adns
	
	ret

disable_laser:
	; Set LASER_CTRL0 register to 1 (set force-disable bit)
	mov address, #20h
	mov data, #01h
	lcall write_adns
	ret

motion_burst:
	ret

image_burst:
    push acc

	; Reset the hardware
	lcall reset_adns
	
	; Wait for a while
	mov scratch, #0feh
	lcall delay

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
	
	mov scratch, #0feh
	lcall delay

	; Loop to read 900 pixels
    mov dptr, #image_store
	image_burst_loop:		
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
		cjne a, #image_store_top_low, image_burst_loop
		mov a, dph
		cjne a, #image_store_top_high, image_burst_loop

	; Raise NCS back high
	setb ncs

    pop acc
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

    ; Wait for 120 microseconds
    mov scratch, #40h
    lcall delay

	; Set MISO pin high to be able to read
	setb miso

    ; Read the data from the SPI line and put it on the accumulator
    lcall read_spi
    mov data, a

    ; Set NCS high again
    setb ncs

    pop acc
    ret

write_spi:
    push 00h

    ; Set up the loop so it only runs 8 times (one for each bit of the data in acc)
    mov r0, #08h
    write_adns_loop:
        ; Get the next bit in acc (from MSB to LSB)
        rl a
        push acc
        jnb acc.0, write_bit_not_set

        ; Run SCLK low and MOSI high
        write_bit_set:
            mov a, ctrl
            anl a, sclk_low
            orl a, mosi_high
            sjmp write_resume

        ; Run SCLK low and MOSI low
        write_bit_not_set:
            mov a, ctrl
            anl a, sclk_low
            anl a, mosi_low
            sjmp write_resume

        write_resume:
            ; Write new SCLK and MOSI
            mov ctrl, a

            ; Set SCLK high
            orl a, sclk_high
            mov ctrl, a

            pop acc
            djnz r0, write_adns_loop

    pop 00h
    ret

read_spi:
    push 00h
	
	; Set MOSI low so the chip doesn't think we're writing to it
	clr mosi

    ; Set up the loop so it only runs 8 times (one for each bit of the data in acc)
    mov r0, #08h
    read_adns_loop:

        ; Shift to the next digit
        rl a
        push acc

        ; Set SCLK low
        mov a, sclk_low
        anl ctrl, a

        ; Set SCLK high
        mov a, sclk_high
        orl ctrl, a

        ; Get the next bit from the control register (from MSB to LSB)
        pop acc
        jnb miso, read_bit_not_set

        ; Set acc.0
        read_bit_set:
            setb acc.0
            sjmp read_resume

        ; Clear acc.0
        read_bit_not_set:
            clr acc.0
            sjmp read_resume

        read_resume:
            djnz r0, read_adns_loop

    pop 00h
    ret

delay_w:
	mov scratch, #40h
	lcall delay
	ret

delay_r:
	mov scratch, #0ah
	lcall delay
	ret
