ScreenInit:
		sei 	;Disable interrupts
	
		lda #0
		sta $C050 ; Text off
		sta $C052 ; Mixed Mode off
		sta $c057 ; Display hires
		sta $C055 ; hires screen 2

		rts
		

Cls:
		loadpair z_hl,$4000
		loadpair z_bc,$1F00
		lda #0
		tax
		tay							;For locate command in a bit!
		sta (z_hl)
		jsr CLdir
        ;rts

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
	
	clc
	sbc #31
	
	
	
	
	;lda #$8		;Char length
	sta z_C

	pushall
	
	
	lda z_h
	pha
	lda z_l
	pha
	
	lda #$0
	
	clc
	rol z_C
	rol ;z_B
	rol z_C
	rol ;z_B
	rol z_C
	rol ;z_B
	sta z_b
	
	lda #>(BitmapFont)
	sta z_h
	lda #<(BitmapFont)
	sta z_l
		
	
	jsr addhl_bc;Select char
	
		lda #0
		sta z_e
		
		lda Cursor_Y
		and #%00000111
		clc
		ROR
		ROR z_e
		adc #$40
		sta z_d
		
		lda Cursor_Y
		and #%11111000
		cmp #8
		bcc PrintChar_FirstThird
		cmp #16
		bcc PrintChar_SecondThird
		lda z_e
		clc
		adc #$50
		jmp PrintChar_ThirdDone
PrintChar_SecondThird:
		lda z_e
		clc
		adc #$28
		jmp PrintChar_ThirdDone
PrintChar_FirstThird:	
		lda z_e
		clc
PrintChar_ThirdDone:	
		ifdef ScrWid256
			adc #4
		endif
		adc Cursor_X
		sta z_e
		
		ldy #0		
		ldx #0		
FontNextLine:		

		;showline
		lda (z_hl),y		
		;rol
		clc
		;ror z_As
		rol
		ror z_As
		rol
		ror z_As
		rol
		ror z_As
		rol
		ror z_As
		rol
		ror z_As
		rol
		ror z_As
		rol
		ror z_As
		sec				;'color'
		ror z_As
		
		lda z_As
		sta (z_de,x)
		jsr GetNextLine		
		;jsr IncHL
		iny
		cpy #8
		bne FontNextLine
		
		
		
			

		
		;ldx #0
		;jsr showline
		;jsr showline
		;jsr showline
		;jsr showline
		;jsr showline
		;jsr showline
		;jsr showline
		;jsr showline


	inc Cursor_X
	lda Cursor_X
	cmp #40
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
	
	pullall
	
	rts
