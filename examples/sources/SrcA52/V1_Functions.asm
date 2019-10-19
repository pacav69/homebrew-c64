		

Cls:
		ldx #0
		ldy #0
		jsr Locate
		lda #$04
		sta z_b
		lda #$C0
		sta z_c
ClsAgain:		
		PushPair z_bc
			lda #' '
			jsr PrintChar
		PullPair z_bc
		jsr DecBC
		lda z_b
		ora z_c
		bne ClsAgain
		
				
		ldx #0
		ldy #0
		;jsr Locate
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
	sta z_as
	PushAll
	Pushpair z_bc
	Pushpair z_hl
	Pushpair z_de
	lda #$0
	sta z_B
	
	
	lda z_as
	clc
	sbc #31
	
	
	
	clc
	rol 
	rol z_B
	rol 
	rol z_B
	rol 
	rol z_B
	;sta z_C
	
	;lda #<BitmapFont
	;sta z_L
	;lda #>BitmapFont
	;sta z_H
	
		;lda z_e
		adc #<BitmapFont
		sta z_l
		lda z_b
		adc #>BitmapFont
		sta z_h
	
	;jsr addhl_bc;Select char
	
	
	
	
	

	
	lda #0
	sta z_d
	lda Cursor_X
	ifdef ScrWid256
		adc #4
	endif
	;sta z_e
	ifndef Mode2Color
	ifndef HalfWidthFont 
		clc
		rol ;z_e
		rol z_d
	endif
	endif
	sta z_e
	
	
	;rol z_e
	;rol z_d
	;rol z_e
	;rol z_d
	;rol z_e
	;rol z_d
	
	
	;lda #$01
	;sta z_b
	;lda #$40
	;sta z_c
	
	lda Cursor_Y
	sta z_b
	clc
	adc z_d
	sta z_d
	
	lda #0
	ror z_b
	ror
	ror z_b
	ror
		adc z_e
		sta z_e
		lda z_b
		
		adc z_d
		sta z_d
;	cmp #0
	;beq PrintChar_NoY
	;tay
;PrintChar_Yagain
;	jsr AddDE_BC
;	dey
;	bne PrintChar_Yagain
;PrintChar_NoY
	
	lda #$20	;Screen Offset
	sta z_b
	lda #$60
	sta z_c
	jsr AddDE_BC
	

	
	
	lda #8
	sta z_b
DoFontLineAgain:
	jsr DoFontLine
	dec z_b
	bne DoFontLineAgain
	
	
	inc Cursor_X
	lda Cursor_X
	ifndef Mode2Color
		ifndef HalfWidthFont 
			cmp #20
		else
			cmp #40
		endif
	else
		cmp #40
	endif
	bne PrintChar_NotNextLine
	jsr NewLine
	
	;lda #0
	;sta Cursor_X
	;inc Cursor_Y
PrintChar_NotNextLine:
	
	Pullpair z_de
	Pullpair z_hl
	Pullpair z_bc
	
	;pla
	;tay
	
	PullAll
	
	rts
DoFontLine:
	
	ldx #0
	ldy #0
	
	lda (z_HL,X)
	;lda #255
	ifndef Mode2Color
	ifndef HalfWidthFont 
		sty z_as
		and #%11110000
		rol
		rol z_as
		rol z_as
		rol
		rol z_as
		rol z_as
		rol
		rol z_as
		rol z_as
		rol
		rol z_as
		rol z_as
		lda z_as
	endif
	endif
	
	;ora #%00001111
	
	sta (z_DE),Y
	ifndef Mode2Color
	ifndef HalfWidthFont 
	sty z_as
	ldY #1
	
	lda (z_HL,X)
	;	lda #255
	and #%00001111
	;and #%01010101
	rol
	rol
	rol
	rol
	
	rol
	rol z_as
	rol z_as
	rol
	rol z_as
	rol z_as
	rol
	rol z_as
	rol z_as
	rol
	rol z_as
	rol z_as
	;clc
	;rol
	;rol
	;rol
	;rol
	;ora #%11110000
	lda z_as
	sta (z_DE),Y
	endif
	endif
	
	
	;lda #$00
	;sta z_b
	;lda #$28
	;sta z_c
	addpair z_de,$0028
	
	jmp Inchl
	;jsr IncDE
	
	;rts