; Change to 2051.h.asm to target 2051 microcontroller:
; ==== Included from "8051.h.asm" by AS115: ====
.equ stack, 2fh
.equ errorf, 2eh

.equ sclk, 90h    ; P1.0
.equ mosi, 91h    ; P1.1
.equ miso, 92h    ; P1.2
.equ ncs, 0b4h    ; P3.4
.equ motion, 0b2h ; P3.2 (INT0)

.equ ctrl, 90h    ; P1
.equ chip, 0b0h   ; P3

.equ address, 10h
.equ data, 11h

.equ sclk_high, 12h
.equ sclk_low, 13h
.equ mosi_high, 14h
.equ mosi_low, 15h
.equ miso_mask, 16h

.equ pcs, 0b7h    ; P3.7

.equ opcode, 10h

.equ scratch, 17h

.equ top_high, 18h
.equ top_low, 19h

.org 7b00h
motion_store:
	.db 00h

.org 7c00h
image_store:
    .db 00h

.equ image_store_top_high, 7fh
.equ image_store_top_low, 84h

.equ motion_store_top_high, 7bh
.equ motion_store_top_low, 0eh

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

; ==== Included from "minmon.lib.asm" by AS115: ====
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

; ==== Included from "adns_9800.lib.asm" by AS115: ====
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
    push 00h

    ; Lower NCS
    clr ncs

    ; Write 50h to the MOTION_BURST register
    mov a, #0d0h
    lcall write_spi

    mov a, #50h
    lcall write_spi

    ; Wait for a frame
    lcall delay_frame

    ; Read 14 registers
    mov dptr, #motion_store
    mov top_high, #motion_store_top_high
    mov top_low, #motion_store_top_low
    lcall burst

    ; Raise NCS
    setb ncs

    pop 00h
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

; ==== Included from "spi.lib.asm" by AS115: ====
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

; ==== Included from "psoc.lib.asm" by AS115: ====
setup_psoc:
    setb pcs

send_psoc:
    ; Send the opcode
    mov ctrl, opcode
    clr pcs
    setb pcs

    ; Wait for the PSoC to process it
    mov scratch, #40h
    lcall delay

    ; Send the data
    mov ctrl, data
    clr pcs
    setb pcs

    ret

; ==== Included from "serial.lib.asm" by AS115: ====
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

; ==== Included from "util.lib.asm" by AS115: ====
shl_acc:
	inc r0
	rr a
	shl_acc_loop:
		rl a
		djnz r0, shl_acc_loop
    ret

shr_acc:
	inc r0
	rl a
	shr_acc_loop:
		rr a
		djnz r0, shr_acc_loop
    ret

delay:
    djnz scratch, delay
    ret

;===============================================================
; subroutine print
; print takes the string immediately following the call and
; sends it out the serial port.  the string must be terminated
; with a null. this routine will ret to the instruction
; immediately following the string.
;===============================================================
print:
   pop   dph              ; put return address in dptr
   pop   dpl
prtstr:
   clr  a                 ; set offset = 0
   movc a,  @a+dptr       ; get chr from code memory
   cjne a,  #0h, mchrok   ; if termination chr, then return
   sjmp prtdone
mchrok:
   lcall sndchr           ; send character
   inc   dptr             ; point at next character
   sjmp  prtstr           ; loop till end of string
prtdone:
   mov   a,  #1h          ; point to instruction after string
   jmp   @a+dptr          ; return
;===============================================================
; subroutine crlf
; crlf sends a carriage return line feed out the serial port
;===============================================================
crlf:
   mov   a,  #0ah         ; print lf
   lcall sndchr
cret:
   mov   a,  #0dh         ; print cr
   lcall sndchr
   ret
;===============================================================
; subroutine prthex
; this routine takes the contents of the acc and prints it out
; as a 2 digit ascii hex number.
;===============================================================
prthex:
   push acc
   lcall binasc           ; convert acc to ascii
   lcall sndchr           ; print first ascii hex digit
   mov   a,  r2           ; get second ascii hex digit
   lcall sndchr           ; print it
   pop acc
   ret
;===============================================================
; subroutine binasc
; binasc takes the contents of the accumulator and converts it
; into two ascii hex numbers.  the result is returned in the
; accumulator and r2.
;===============================================================
binasc:
   mov   r2, a            ; save in r2
   anl   a,  #0fh         ; convert least sig digit.
   add   a,  #0f6h        ; adjust it
   jnc   noadj1           ; if a-f then readjust
   add   a,  #07h
noadj1:
   add   a,  #3ah         ; make ascii
   xch   a,  r2           ; put result in reg 2
   swap  a                ; convert most sig digit
   anl   a,  #0fh         ; look at least sig half of acc
   add   a,  #0f6h        ; adjust it
   jnc   noadj2           ; if a-f then re-adjust
   add   a,  #07h
noadj2:
   add   a,  #3ah         ; make ascii
   ret

;===============================================================
; subroutine getbyt
; this routine reads in an 2 digit ascii hex number from the
; serial port. the result is returned in the acc.
;===============================================================
getbyt:
  lcall getchr           ; get msb ascii chr
  lcall ascbin           ; conv it to binary
  swap  a                ; move to most sig half of acc
  mov   b,  a            ; save in b
  lcall getchr           ; get lsb ascii chr
  lcall ascbin           ; conv it to binary
  orl   a,  b            ; combine two halves
  ret

;===============================================================
; subroutine ascbin
; this routine takes the ascii character passed to it in the
; acc and converts it to a 4 bit binary number which is returned
; in the acc.
;===============================================================
ascbin:
   clr   errorf
   add   a,  #0d0h        ; if chr < 30 then error
   jnc   notnum
   clr   c                ; check if chr is 0-9
   add   a,  #0f6h        ; adjust it
   jc    hextry           ; jmp if chr not 0-9
   add   a,  #0ah         ; if it is then adjust it
   ret
hextry:
   clr   acc.5            ; convert to upper
   clr   c                ; check if chr is a-f
   add   a,  #0f9h        ; adjust it
   jnc   notnum           ; if not a-f then error
   clr   c                ; see if char is 46 or less.
   add   a,  #0fah        ; adjust acc
   jc    notnum           ; if carry then not hex
   anl   a,  #0fh         ; clear unused bits
   ret
notnum:
   setb  errorf           ; if not a valid digit
   ret
