SetPalette:		;-GRB
	ifndef Mode2Color	
		cmp #4
		bcs SetPaletteAbort			;We;re only working in 4 color mode, 
		sta z_as						;so skip other colors
		pushall
				
			lda z_l
			jsr Palcolconv			;R
			sta z_b	 				
			lda z_l
			jsr PalcolconvR			;B
			sta z_l
			lda z_h					;G
			jsr PalcolconvR
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
			
			lda (z_hl),y			;Get Apple color from lookup
			pha
			
GTIAstart equ GTIA+ $16				;Calculate the base of our GTIA palette

				lda #<GTIAstart
				sta z_L
				lda #>GTIAstart
				sta z_H
				ldy #4
				ldx z_as
				beq SetPaletteFound	;Pal 0
				ldy #0
SetPaletteRepeat:
				dex
				beq SetPaletteFound	;Pal 1
				iny
				bne SetPaletteRepeat ;(branch always)	;Pal 2,3
SetPaletteFound:
			pla
			sta (z_hl),Y
		pullall
SetPaletteAbort:
	endif
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
Palcolconv0:	
	lda #0
	rts
Palcolconv1:	
	lda #1
	rts
	
	;Hardware palette numbers
PalPalette_Map:	
	;G0		B0  B1  B2
		db $00,	$80, $88 ;R0
		db $38,	$68, $78 ;R1
		db $3A,	$6A, $5A ;R2
	;G1
		db $C0,	$B8, $98 ;R0
		db $E0,	$08, $9A ;R1
		db $28,	$3A, $3F ;R2
	;G2	
		db $CA,	$BA, $9A ;R0
		db $DA,	$BA, $AE ;R1
		db $DF,	$EF, $0F ;R2
	