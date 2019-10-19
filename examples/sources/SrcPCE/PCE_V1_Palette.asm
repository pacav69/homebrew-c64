;The HuC6260 Video Colour Encoder
;$0400 Write 0 to reset
;$0402 LSB of byte offset into palette 	ppppppp	(512 offsets, first 256 are background, 2nd 256 are sprites)
;$0403 MSB of byte offset into palette 	------p
;$0404 LSB of 16-bit palette data 	ggrrrbbb
;$0405 MSB of 16-bit palette data 	------g

;The DAC has a palette of 512 colours. The bitmap of the palette data is this: 0000000gggrrrbbb. 
;That means, that you have a range from 0-7 for every colour, resulting in a total number of 512 colours (8 * 8 * 8). You can read and write the DAC-registers. 



SetPalette:					;-GRB
	sta z_as
	pushall
		lda z_as
		tax 				;Low palette byte
		cly	;(Clear Y)		;High Palette Byte
		
		jsr SetPaletteone	;Set Background Palette (0-255)	
		iny					;Set Matching Sprite Palette (256-511)
		jsr SetPaletteone
	pullall
	rts	
	
	
SetPaletteone:	
		stx HPage+$0402		;Select Palette entry L: PPPPPPPP
		sty HPage+$0403		;Select Palette entry H: -------P 
	
		lda z_h				;----GGGg
		ror
		ror
		ror					;GG-----G
		pha
			ror
			and #%11000000	;GG------
			sta z_c
			
			lda z_l			;RRRrBBBb
			ror				;-RRR-BBB
			pha
				ror
				and #%00111000	;--RRR---
				ora z_c			;GGRRR---
				sta z_c		
			pla
			and #%00000111	;-----BBB
			ora z_c			;GGRRRBBB
			sta HPage+$0404	;Set Palette Entry L
		pla				
		and #%00000001		;-------G
		sta HPage+$0405		;Set Palette Entry H
	rts