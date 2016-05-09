.equ stack, 2fh
.equ errorf, 2eh

.equ sclk, 90h    ; P1.0
.equ mosi, 91h    ; P1.1
.equ miso, 92h    ; P1.2
.equ ncs, 0b4h    ; P3.4

.equ ctrl, 90h    ; P1
.equ chip, 0b0h   ; P3

.equ address, 10h
.equ data, 11h

.equ sclk_high, 12h
.equ sclk_low, 13h
.equ mosi_high, 14h
.equ mosi_low, 15h
.equ miso_mask, 16h

.equ pcs, 097h    ; P1.7

.equ scratch, 17h

.equ top_high, 18h
.equ top_low, 19h

.equ x_low, 1ah
.equ x_high, 1bh
.equ y_low, 1ch
.equ y_high, 1dh

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

.equ adns_resolution, 03h
.equ motion_cutoff_high, 00h
.equ motion_cutoff_low, 20h
