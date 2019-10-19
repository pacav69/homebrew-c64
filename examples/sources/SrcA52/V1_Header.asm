	ifdef BuildA52
BuildA5280 equ 1			;In most cases Atari 5200 and 800 are the same
GTIA equ $C000
POKEY equ $E800
		org     $4000       ;Start of cartridge area
	endif
	
	ifdef BuildA80
BuildA5280 equ 1			;In most cases Atari 5200 and 800 are the same
GTIA equ $D000
POKEY equ $D200
		org     $A000       ;Start of cartridge area
	endif
	
	include "\SrcAll\BasicMacros.asm"

DMACTL  equ     $D400           ;DMA Control
DLISTL  equ     $D402           ;Display list lo
DLISTH  equ     $D403           ;Display list hi

CHBASE  equ     $D409           ;Character set base
CHACTL  equ     $D401           ;Character control
NMIEN   equ     $D40E           ;NMI Enable

COLPM0 equ GTIA+ $12
COLPM1 equ GTIA+ $13
COLPM2 equ GTIA+ $14
COLPM3 equ GTIA+ $15

COLPF0 equ GTIA+ $16
COLPF1 equ GTIA+ $17
COLPF2 equ GTIA+ $18
COLPF3 equ GTIA+ $19

COLBK  equ GTIA+ $1A
	
z_Regs 		equ $40
Cursor_X 	equ $80
Cursor_Y 	equ Cursor_X+1

SPpage 		equ $0100
UserRam 	equ $0200

;Mode2Color equ 1

        
        sei                     ;Disable interrupts
        cld                     ;Clear decimal mode
Start
        ldx     #$00
        txa
crloop1    
        sta     $00,x           ;Clear zero page
        sta     $D400,x         ;Clear ANTIC
        sta     GTIA,x          ;Clear GTIA
        sta     POKEY,x         ;Clear POKEY
        dex
        bne     crloop1
		
        ldy     #0            
        lda     #$02            ;Start at $0200 (Ram)
        sta     z_e            ;Clear to $3FFF
        tya
        sta     z_d
crloop2
        lda     #$00            
crloop3
        sta     (z_e),y         ;Store data
        iny                     ;Next byte
        bne     crloop3         ;Branch if not done page
        inc     z_d             ;Next page
        lda     z_d
        cmp     #$40            ;Check if end of RAM
        bne     crloop2         ;Branch if not

		
     
		jsr ScreenInit
		