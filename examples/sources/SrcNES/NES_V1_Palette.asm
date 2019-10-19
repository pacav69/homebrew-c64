SetPalette:		;-GRB
	sta z_as
	pushall
		lda z_l
		jsr Palcolconv			;R
		sta z_b	 				
		lda z_l
		jsr PalcolconvR			;B
		sta z_l
		lda z_h					
		jsr PalcolconvR			;G
		sta z_h
		clc
		rol						;x2	-Multiply up green
		rol						;x4
		rol						;x8
		adc z_h					;Add Green x9
		adc z_B					
		adc z_B
		adc z_B					;Add Red x3
		adc z_L					;Add Blue x1
		tay
		
		lda #<PalPalette_Map	;Load address of lookup table
		sta z_L
		lda #>PalPalette_Map
		sta z_H
		
		jsr NesDisableScreen	;Can only set palette when screen off
		;jsr waitframe				;Or in Vblank
		
		lda #$3F				;Select Palette ram &3Fxx
		sta $2006				;PPUADDR
		lda z_as
		sta $2006				;PPUADDR
		
		lda (z_hl),y			;Get color from lookup
		sta $2007				;Update Nes Pal
		 
		jsr ResetScroll			;Fix scroll pos
		jsr NesEnableScreen		;Turn Screen Back on
	pullall
	rts

PalcolconvR:			;We need to shift the Red color bits
	jsr SwapNibbles
Palcolconv:				;We need to limit our returned value to 0,1 or 2
	and #%11110000			
	cmp #$50
	bcc Palcolconv0	
	cmp #$A0
	bcc Palcolconv1
	lda #2
	rts
Palcolconv1:	
	lda #1
	rts
Palcolconv0:	
	lda #0
	rts
	
	
	
	;Hardware palette numbers
PalPalette_Map:	
	;	B0  B1  B2
	db	$0d,$01,$11	;R0
	db	$05,$04,$14	;R1
	db	$25,$24,$23	;R2
	;G1
	db	$0a,$1b,$1c
	db	$18,$00,$22
	db	$27,$26,$36
	;G2	
	db	$2a,$2b,$2c
	db	$29,$3A,$3c
	db	$38,$39,$30

