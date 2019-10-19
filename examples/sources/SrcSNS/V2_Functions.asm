
	
Cls:
	lda #0
	stx Cursor_X 
	sty Cursor_Y
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
		sta z_h
		lda #0
		sta z_l
		clc
		ror z_h
		ror z_l
		ror z_h
		ror z_l
		;ror z_h
		;ror z_l
		
		
		
		
		;jsr WaitVblank
		lda Cursor_X 	
		adc cursor_X
		adc z_l
		sta z_l
		
		
		lda z_l
		adc #<SnesScreenBuffer
		sta z_l
		;lda #$00
		;sta $2116		;MemL -Video port address [VMADDL/VMADDH]                            
		lda z_h
		adc #>SnesScreenBuffer
		sta z_h
		
		ldy #0
		lda z_as
		clc
		sbc #31
		sta (z_hl),y
		iny
		lda #0
		sta (z_hl),y
		
		
		;sta $2116		;MemL -Video port address [VMADDL/VMADDH]                            
		;lda z_h
		;sta $2117		;MemH
	

		;lda #$00
		;sta $2119	;h -Video port data [VMDATAL/VMDATAH]                             
		;lda z_as
		;sbc #31
		;lda #'L'-32
		;sta $2118	;l
	
	inc Cursor_X
	lda Cursor_X
	cmp #32
	bne PrintChar_NotNextLine
	jsr NewLine
	
PrintChar_NotNextLine:
	
		
	pla
	sta z_l
	pla
	sta z_h	
	pullall
	
	rts
	
			
load_font:

	lda #$00
	sta $2116		;MemL
	lda #$10
	sta $2117		;MemH

	lda #BitmapFont&255
	sta z_l
	lda #BitmapFont/256
	sta z_h
	ldx #3
	ldy #0
fontchar_loop:
	lda (z_hl),y
	sta $2119
	sta $2118			;Write data to data-port
	iny
	lda (z_hl),y
	sta $2119
	sta $2118
	iny
	lda (z_hl),y
	sta $2119
	sta $2118
	iny
	lda (z_hl),y
	sta $2119
	sta $2118
	iny
	lda (z_hl),y
	sta $2119
	sta $2118
	iny
	lda (z_hl),y
	sta $2119
	sta $2118
	iny
	lda (z_hl),y
	sta $2119
	sta $2118
	iny
	lda (z_hl),y
	sta $2119
	sta $2118
	
	
	lda #0	
	jsr blankblock
	iny
	bne fontchar_loop
	inc z_hl+1
	dex
	bne fontchar_loop
	rts
blankblock:
	sta $2119
	sta $2118
	sta $2119
	sta $2118
	sta $2119
	sta $2118
	sta $2119
	sta $2118
	sta $2119
	sta $2118
	sta $2119
	sta $2118
	sta $2119
	sta $2118
	sta $2119
	sta $2118
	rts