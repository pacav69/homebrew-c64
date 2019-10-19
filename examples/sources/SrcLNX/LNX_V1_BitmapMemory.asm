	;Y= $50 bytes per Yline = 00000000 01010000
	;Move Y into top byte 	= YYYYYYYY 00000000
	;Shift Right Twice      = 00YYYYYY YY000000
	;Shift Right Twice      = 0000YYYY YYYY0000
	
GetScreenPos:
	lda #$00		;Reset z_C
	sta z_c
	clc		

	tya 			;Move Y into top byte 	= YYYYYYYY 00000000
	ror 			
	ror z_c
	ror 
	ror z_c			;Shift Right Twice      = 00YYYYYY YY000000
	
	sta z_d			;Store High byte in total	
	lda z_c			
	sta z_e			;Store Low byte in total
	
	lda z_d			;Shift Right Twice      = 0000YYYY YYYY0000
	ror 
	ror z_c
	ror 
	ror z_c
	
	clc				;Add High byte to total
	adc z_d
	adc #$C0		;Screen base at &C0000
	sta z_d

	clc
	lda z_c			;Add Low byte to total
	adc z_e
	sta z_e
	
	lda z_d			;Add any carry to the high byte
	adc #0
	sta z_d
	
	clc				;Add the X pos 
	txa 
	adc z_e 
	sta z_e
	
	lda z_d			;Add any carry to the high byte
	adc #0
	sta z_d
	rts
	
GetNextLine:
	pushpair z_bc
		lda #$00
		sta z_b
		lda #$50	;Add 80 to move down a line
		sta z_c
		jsr AddDE_BC
	pullpair z_bc
	rts
	
	
ScreenInit:		;SUZY chip needs low byte setting first 
				;OR IT WILL WIPE THE HIGH BYTE!
	
	;Set screen ram pointer to $C000
	lda #$00
	sta $FD94	;DISPADR	Display Address L (Visible)
	sta $FC08	;VIDBAS		Base address of video build buffer L (Sprites)
	
	lda #$C0	
	sta $FD95	;DISPADR	Display Address H (Visible)
	sta $FC09	;VIDBAS		Base address of video build buffer H (Sprites)
	
	
	LDA #8	;Offset
	STA $FC04	;HOFF		Offset to H edge of screen
	STA $FC06	;VOFF		Offset to V edge of screen

	;Defaults for Sprite sys
	lda #%01000010
	sta $fc92	;SPRSYS		System Cotrlol Bits (RW)
	
	;Set to '$F3' after at least 100ms after power up for sprites
	lda #$f3								
	sta $FC83	;SPRINT		Sprite Initialization Bits (W)(U)
	
	;let susy take bus (For sprites)
	lda #1		
	sta $FC90	;SUZYBUSEN	Suzy bus enable FF

	
	
	;Do the palette
	lda #%00000000	;Palette Color 0 ----GGGG
	sta $FDA0
	lda #%01110000	;Palette Color 0 BBBBRRRR
	sta $FDB0
	
	lda #%00001111	;Palette Color 15 ----GGGG
	sta $FDAF
	lda #%00001111	;Palette Color 15 BBBBRRRR
	sta $FDBF
	rts
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		
	
SetHardwareSprite:
	lda z_l
	sta Sprite_Source		;Update Address of sprite ram in SCB
	lda z_h
	sta Sprite_Source+1
	
	lda z_ixl
	sta Sprite_Xpos			;Set Sprite Xpos
	lda z_iyl
	sta Sprite_Ypos			;Set Sprite Ypos
		
	lda #<Lynx_SCB			
	sta $fc10				;SCBNEXT.L - Address of next SCB
	ldy #>Lynx_SCB
	sty $fc11              	;SCBNEXT.H - Address of next SCB
	
		
		 ;-----E-S
	lda #%00000101 			;1 SprStart + 4 Everon detector(?)
	sta $FC91				;SPRGO	Sprite Process start bit
	
	stz $FD90				;SDONEACK - Suzy Done Acknowledge (Sleep CPU)

	stz $FD91				;CPUSLEEP - Cpu Bus Request Disable (0=disable)
	
	lda #%11000101			;For some reason Byte 0 of the SCB gets altered!?
	sta Lynx_SCB			;Getting changed to %00101101 - I don't know why
	
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	
				;Sprite Control block - we'll reprogram this for each sprite
Lynx_SCB:
				   ;BBHV-TTT 	SPRCTL0... B=bits per pixel (4/3/2/1) 
						;H=hflip V=vflip T=type (7=normal)
					; 101101
				db %11000101		
				   ;LSRRPSUl 	SPRCTL1... L=Literal (0=RLE) S=Sizing choice (0 only!) 
						;RR=Reloadable depth (1=Use Size 3=Use Size,ScaleTilt)
				db %00010000         ;P=Palette reload (0=yes) s=skipsprite u=draw up l=draw left
				db 0			;- SPRCOL - 0= OFF
				dw 0			;Next SCB (0=none)
Sprite_Source:	dw $0000		;Sprite pointer
Sprite_Xpos:	dw 70			;Xpos
Sprite_Ypos:	dw 30			;Yos
				dw $100			;Wid ($100 = 100%)
				dw $100			;Hei ($100 = 100%)
			;	dw 0			;Scale - not needed if B4,B5 of SPRCTL<3
			;	dw 0			;Tilt - not needed if B4,B5 of SPRCTL<2

				db $01,$23,$45,$67,$89,$AB,$CD,$EF	;Palette - maps nibbles to colors
														;(useful for <4 bpp)
														
				;End of SCB - just leave alone
				db 0		;Collision Depository
				db 0		;Identification number						
				db 0		;Z Depth
				dw 0		;Last SCB
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	