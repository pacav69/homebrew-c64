
	
	
load_font:
	lda #BitmapFont&255
	sta z_l
	lda #BitmapFont/256
	sta z_h
	lda #3
	sta z_b
	ldy #0
fontchar_loop:
	jsr DoFontLoop
	
	tya
	sec
	sbc #8
	tay
	
	
	jsr DoFontLoop
	
	tya
	bne fontchar_loop
	inc z_h
	dec z_b
	bne fontchar_loop
	rts
DoFontLoop
	ldx #8
fontchar_loopA:
	lda (z_hl),y
	sta $2007			;Write data to data-port
	iny
	dex
	bne fontchar_loopA
	rts
	

pal:
	db $02, $38, $21, $15
cls:

	ldx #0
	ldy #0
	jsr Locate
	
	rts

	
Locate:
	stx Cursor_X 
	sty Cursor_Y
	rts
NewLine:
	lda #0
	sta Cursor_X	
	inc Cursor_Y
	rts
	
	
PrintChar:
	;Cursor_L
	
	sta z_as
	
	pushall

	lda z_h
	pha
	lda z_l
	pha
	
	lda Cursor_Y
		ifdef ScrWid256	;256x192
			clc
			adc #2
		endif
	and #%00000111
	clc
	rol
	rol
	rol
	rol
	rol
	sta z_h
	lda Cursor_X
	ora z_h
	sta z_l
	lda Cursor_Y
		ifdef ScrWid256	;256x192
			clc
			adc #2
		endif
	and #%11111000
	clc
	ror
	ror
	ror
	clc
	;adc #>VDPBuffer
	adc #$20
	sta z_h

	
	;pha
		
		;jsr waitframe
		;lda z_H
		;clc
		;adc #$20
		;sta $2006;PPUADDR
		;lda z_L
		;sta $2006;PPUADDR
		
		
		jsr GetVdpBufferCT
		lda z_h
		sta VDPBuffer,Y
		iny
		lda z_l
		sta VDPBuffer,Y
		iny
		
		lda z_as
		clc
		sbc #31
	;	ldy #0
		sta VDPBuffer,y
		iny
		sty VDP_CT
	;pla
	;lda z_as
		;clc
		;sbc #31
		;sta $2007
			
	inc Cursor_X
	lda Cursor_X
	cmp #32
	bne PrintChar_NotNextLine
	jsr NewLine
PrintChar_NotNextLine:	
	;Need to reset scroll each write	
;	jsr ResetScroll
		
	pla
	sta z_l
	pla
	sta z_h	
	pullall


	
	rts
