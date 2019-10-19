;Convert: ----GGGG RRRRBBBB
; 	  To: -BBBBbGG GGgRRRRr

SetPalette:		;-GRB
	sta $2121
	pha 
		lda #0
		sta z_c
		
		lda z_h			;----GGGG
		ror
		ror z_c
		ror
		ror z_c			;GGgrrrrr	
		and #%00000011
		sta z_b			;-bbbbbGG
		
		lda z_l			;RRRRbbbb
		ror
		ror
		ror
		and #%00011110	;GGgRRRRr
		ora z_c
		sta z_c
		
		lda z_l			;rrrrBBBB
		rol
		rol
		rol
		and #%01111000	;-BBBBbgg
		ora z_b
		sta z_b
		
		jsr SetPaletteSendColors
	pla
	ora #%10000000			;Set equivalent Sprite palette 
	sta $2121
SetPaletteSendColors:
	lda z_c				;GGGRRRRR
	sta $2122
	lda z_b				;-BBBBBGG
	sta $2122
	rts 
	
	
	