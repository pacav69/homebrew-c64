
	
	
load_font:
	lda #$00			;Pattern table &0000
	sta $2006;PPUADDR			;MSB - DEST ADDR
	lda #$00
	sta $2006;PPUADDR			;LSB - Dest ADDR
	
	lda #BitmapFont&255
	sta z_l
	lda #BitmapFont/256
	sta z_h
	ldx #3
	ldy #0
fontchar_loop:
	lda (z_hl),y
	sta $2007			;Write data to data-port
	iny
	lda (z_hl),y
	sta $2007
	iny
	lda (z_hl),y
	sta $2007
	iny
	lda (z_hl),y
	sta $2007
	iny
	lda (z_hl),y
	sta $2007
	iny
	lda (z_hl),y
	sta $2007
	iny
	lda (z_hl),y
	sta $2007
	iny
	lda (z_hl),y
	sta $2007
	lda #0
	
	
	sta $2007
	sta $2007
	sta $2007
	sta $2007
	sta $2007
	sta $2007
	sta $2007
	sta $2007
	iny
	bne fontchar_loop
	inc z_h
	dex
	bne fontchar_loop
	rts

	

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
	and #%11111000
	clc
	ror
	ror
	ror
	sta z_h

	
	;pha
		
		jsr waitframe
		
		lda z_H
		clc
		adc #$20
		sta $2006;PPUADDR
		lda z_L
		sta $2006;PPUADDR
		
	;pla
	lda z_as
		clc
		sbc #31
		sta $2007
			
	inc Cursor_X
	lda Cursor_X
	cmp #32
	bne PrintChar_NotNextLine
	jsr NewLine
PrintChar_NotNextLine:	
	;Need to reset scroll each write	
	jsr ResetScroll
		
	pla
	sta z_l
	pla
	sta z_h	
	pullall


	
	rts
