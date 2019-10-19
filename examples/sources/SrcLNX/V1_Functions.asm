
Cls:
	rts


PrintChar:
	
	
	clc
	sbc #31
	
	
	;lda #$8		;Char length
	sta z_C
	

	lda #$0
	sta z_B
	
	txa
	pha
	
	tya
	pha
	lda z_h
	pha
	lda z_l
	pha
	
	
	clc
	rol z_C
	rol z_B
	rol z_C
	rol z_B
	rol z_C
	rol z_B
	
	
	lda #<BitmapFont
	sta z_L
	lda #>BitmapFont
	sta z_H
	
	
	
	jsr addhl_bc;Select char
	
	ifdef ShortTile
		lda #$01
		sta z_b
		lda #$E0
		sta z_c
	else
		lda #$02
		sta z_b
		lda #$80
		sta z_c
	endif
	lda #$C0
	sta z_d
	lda Cursor_X
	clc
	rol
	rol
	sta z_e
	
	ldy Cursor_Y
	tya
	beq LocateDone
LocateYagain:
	jsr AddDE_BC
	dey
	bne LocateYagain
LocateDone:
	
	ldx #00
	lda #$50
	sta z_C
	lda #$00
	sta z_B


	ldy #0
nextFontLine
	tya
	pha
	
	ifdef ShortTile
	cmp #1
	beq SkipFontLine
	cmp #5
	beq SkipFontLine
	endif
	
	
	lda (z_HL),y
	ldy #00
	sta z_AS
MoreFontLine:
	lda #0
	rol z_As
	rol 
	rol 
	rol 
	rol 
	rol z_As
	rol 
	sta z_ixl
	clc
	rol
	ora z_ixl
	rol
	ora z_ixl
	rol
	ora z_ixl
	sta (z_DE),Y
	iny
	cpy #4
	bne MoreFontLine
	
	jsr addde_bc
SkipFontLine:
	pla
	tay
	iny
	cpy #8
	bne nextFontLine
	
	;jsr IncHL
	;rts
	
	
	
	inc Cursor_X
	lda Cursor_X
	cmp #20
	bne PrintChar_NotNextLine
	jsr NewLine
	
	;lda #0
	;sta Cursor_X
	;inc Cursor_Y
PrintChar_NotNextLine:
	
	
	pla
	sta z_l
	pla
	sta z_h	
	
	pla
	tay
	pla
	tax
	rts
	
Locate:
	txa 
	sta Cursor_X
	tya 
	sta Cursor_Y
	rts

NewLine:		
		lda #0
		sta Cursor_X
		
		inc Cursor_Y
	rts
