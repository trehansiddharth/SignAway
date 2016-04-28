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
