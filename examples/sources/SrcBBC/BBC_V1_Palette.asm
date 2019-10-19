SetPalette:		;-GRB
	cmp #4
	bcs SetPaletteAbort			;We;re only working in 4 color mode,
	sta z_as						; so skip other colors
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
		
		lda (z_hl),y			;Get BBC color from lookup
		sta z_b
	
		lda z_as				;Get palette entry we want to change
		clc
		rol						;Multiply by 4
		rol
		tay						;We're now pointing to the 4 byte ULAConfig 
								;palette def
		
		lda #<ULAConfig			;Destination base of color defs
		sta z_L
		lda #>ULAConfig
		sta z_H

		ldx #5					;We need to copy 4 bytes
DoOnePalette:
		lda (z_hl),y			;Y=color offset
		and #%11110000			;Keep source logical byte
		ora z_b					;Or in new color
		sta (z_hl),y
		iny
		dex
		bne DoOnePalette
		jsr SendULA				;Transfer the update palette to the hardware
	pullall
SetPaletteAbort:
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
		db $07,	$03, $03	;R0
		db $06,	$02, $02	;R1
		db $06,	$02, $02	;R2
		
		;G1
		db $05,	$05, $01	;R0
		db $04,	$00, $01	;R1
		db $06,	$02, $02	;R2
		
		;G2
		db $05,	$05, $01	;R0
		db $05,	$05, $01	;R1
		db $04,	$04, $00	;R2


;ULAConfig:	
;Palette0:	;Colours
;		SC  SC		-	S=Screen C=Color
;	db $03,$13	;0
;	db $43,$53	;0
;Palette1:
;	db $22,$32		;1
;	db $62,$72		;1
;Palette2:
;	db $84,$94			;2
;	db $C4,$D4			;2
;Palette3:
;	db $A0,$B0				;3
;	db $E0,$F0				;3

;7	&00(0) 	black
;6	&01(1) 	red
;5	&02(2) 	green
;4	&03(3) 	yellow (green—red)
;3	&04(4) 	blue
;2	&05(5) 	magenta (red—blue)
;1	&06(6) 	cyan (green—blue)
;0	&07(7) 	white
	