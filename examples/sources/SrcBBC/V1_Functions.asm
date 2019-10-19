
Cls:
	loadpair z_hl,$4180
	loadpair z_bc,(80*200)
	lda #0
	jsr cldir
	
	
		; ldx #0
		; ldy #0
		; jsr Locate
		; lda #$04
		; sta z_b
		; lda #$E8
		; sta z_c
; ClsAgain:		
		; PushPair z_bc
			; lda #' '
			; jsr PrintChar
		; PullPair z_bc
		; jsr DecBC
		; lda z_b
		; ora z_c
		; bne ClsAgain
		
				
		ldx #0
		ldy #0
	;	jsr Locate
     ;   rts

		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Locate:
	txa 
	sta Cursor_X
	tya 
	sta Cursor_Y
	rts
	
PrintChar:
	
	clc
	sbc #31
	
	
	
	;lda #$8		;Char length
	sta z_C
	
	
	PushAll
	
	;tya
	;pha
	
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
	
	lda #<BitmapFont
	sta z_L
	lda #>BitmapFont
	sta z_H
	
	
	
	jsr addhl_bc;Select char
	
	
	
	
	

	
	lda #0
	sta z_d
	lda Cursor_X
	;ifdef ScrWid256
	;clc
	;adc #4
	;endif
	
	clc
	rol ;z_e
	rol z_d
	rol ;z_e
	rol z_d
	rol ;z_e
	rol z_d
	rol ;z_e
	rol z_d
	sta z_e
	
	;lda #$02
	;sta z_b
	;lda #$80
	;sta z_c
	
	clc
	lda Cursor_Y
	sta z_b
	lda #0
	ror z_b
	ror 
	
	ifndef ScrWid256
	tax
		adc z_e
		sta z_e
		lda z_b
		adc z_d
		sta z_d
	txa
	endif
	rol 
	rol z_b
	rol 
	rol z_b
	ifndef ScrWid256
		adc z_e
		sta z_e
		
	endif
	lda z_b
	adc z_d
	sta z_d
	
	
	;cmp #0
	;beq PrintChar_NoY
	;tay
;PrintChar_Yagain
;	jsr AddDE_BC
;	dey
;	bne PrintChar_Yagain
;PrintChar_NoY
	ifndef ScrWid256
		lda #$41	;Screen Offset
		sta z_b
		lda #$80
		sta z_c
	else
		lda #$50	;Screen Offset
		sta z_b
		lda #$00
		sta z_c
	endif
	jsr AddDE_BC
	
	ldy #8
DoFontAgain:
	
	tya
	pha
		dey
		lda (z_HL),Y
		tax
		and #%11110000
		sta z_as
		jsr SwapNibbles
		ora z_as
		;ora #%00001111
		sta (z_DE),Y
		
		
		;pha
			tya
			clc
			adc #8
			tay
		;pla
		;lda (z_HL),Y
		txa
		and #%00001111
		sta z_as
		jsr SwapNibbles
		ora z_as
		;ora #%11110000
		
		sta (z_DE),Y
	pla
	tay
	dey
	bne DoFontAgain
	
	
	
	
	inc Cursor_X
	lda Cursor_X
	ifdef ScrWid256
		cmp #32
	else
		cmp #40
	endif
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
	
	;pla
	;tay
	
	PullAll
	
	rts

	

	
NewLine:
	lda #0
	sta Cursor_X	
	inc Cursor_Y
	rts
