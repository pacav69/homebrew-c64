
	
InitFont:	
	st0 #0			;set Address reg to $1000 - we'll put our font there (tiles 256+)
	st1 #$00
	st2 #$10
	
	st0 #2			;Select Data reg
	
    lda #96
    sta z_B			;96 tiles in our font

	
	lda #>Bitmapfont	;Address of our font
    sta z_H
    lda #<Bitmapfont
	sta z_L

	ldy #0	
	
xLDIR:
		lda #8			;8 lines per letter
	    sta z_C
T1Again	
		lda (z_HL),Y	

        ;sta_00 $02		;I use my macro here - I need to write to VramDataWrite at $0002
		sta $0102		;This does not work, as the CPU redirects it to $2002
		
	
		sta $0103
	;	st2 #$00		;just set second plane to 0
		jsr IncHL
		DEC z_C
		BNE T1Again		;Write the first 8 lines 
		ldx #8
FontDecAgain:		
		jsr DecHL		;The format of tiles is weird! We have to write the first 2 bitplanes as a 16 bit number
		;jsr DecHL		;THEN the second two... so we have to backpedal 8 lines, and send the char agan!
		;jsr DecHL
		;jsr DecHL
		;jsr DecHL
		;jsr DecHL
		;jsr DecHL
		;jsr DecHL
		dex
		bne FontDecAgain
		
		lda #8
	    sta z_C
T1Again2
		lda (z_HL),Y	
	
        ;sta_00 $02		;I use my macro here - I need to write to VramDataWrite at $0002
		sta $0102		;This does not work, as the CPU redirects it to $2002
		sta $0103		
		;st2 #$00		;just set second plane to 0
		jsr IncHL
		DEC z_C
		BNE T1Again2
		
		DEC z_B
		BNE xLDIR
		rts
Cls:

	st0 #0		;VDP reg 0 (address)
	st1 #$00	;We want to clear the tilemap
	st2 #$00

	ldx #32		;32x32 area
	ldy #32
	st0 #2		;Select VDP Reg2 (data)
	
repeatfill:	
	st1 #0				;Fill the entire area with our "Space tile" (tile 256)
	st2 #%00000001		;Tile 256+
	dex
	bne repeatfill
	ldx #32
	dey
	bne repeatfill
	ldy #0
	ldx #0
	

Locate:
		tya
		ifdef ScrWid256
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
		sta z_As
		txa
		ora z_As
		sta Cursor_L
		tya
		ifdef ScrWid256
			clc
			adc #2
		endif
		and #%11111000
		clc
		ror
		ror
		ror
		sta Cursor_H		
		rts

PrintChar:
	;Cursor_L
	pha
		st0 #0
		lda Cursor_L
		sta $0102
		lda Cursor_H
		sta $0103
	pla
	pha
		clc
		sbc #31
		st0 #2
		sta $0102
		st2 #%00000001
			
		INC Cursor_L
		BNE	IncCursor_Done
		INC	Cursor_H
IncCursor_Done:
	pla
	rts
NewLine:
		pha
			lda Cursor_L
			and #%11100000
			clc 
			adc #%00100000
			sta Cursor_L
			lda Cursor_H
			adc #0
			sta Cursor_H
		pla
	rts