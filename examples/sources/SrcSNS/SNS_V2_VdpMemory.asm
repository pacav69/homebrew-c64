ScreenInit:
		 ;aaaabbbb -aaa=base addr for BG2 bbb=base addr for BG1
	lda #%00010001
	sta $210B 		;BG1 & BG2 VRAM location register [BG12NBA]                    
	
	;     xxxxxxss 	- xxx=address… ss=SC size  00=32x32 01=64x32 10=32x64 11=64x64
	lda #%00000000
	sta $2107		;BG1SC - BG1 Tilemap VRAM location
	
	;        S4321
	lda #%00000001	;Turn on BG1
	sta $212C 		;TM - Main screen designation                             
	
	;	  x000bbbb - x=screen disable (1=disable) bbbb=brightness (15=max)
	lda #%00001111	;INIDISP - Screen display register
	sta $2100

	lda #0			
	sta $2121		;CGADD - Colour # (or pallete) selection  
	lda #%00000000	;?bbbbbgg 
	sta $2122		;CGDATA - Colour data register
	lda #%00111100	;gggrrrrr 
	sta $2122

	lda #1
	sta $2121		;CGADD - Colour # (or pallete) selection  
	lda #%11100000	;?bbbbbgg 
	sta $2122		;CGDATA - Colour data register
	lda #%11111111	;gggrrrrr 
	sta $2122
	
	lda #2
	sta $2121		;CGADD - Colour # (or pallete) selection  
	lda #%00011111	;?bbbbbgg
	sta $2122		;CGDATA - Colour data register
	lda #%00000000	;gggrrrrr 
	sta $2122
	
	lda #3
	sta $2121		;CGADD - Colour # (or pallete) selection  
	lda #%11111111	;?bbbbbgg 
	sta $2122		;CGDATA - Colour data register
	lda #%00000111	;gggrrrrr 
	sta $2122
	
	;	  i000abcd - I 1=inc on $2118 or $2139 0=$2119 or $213A… abcd=move size
	lda #%00000000
	sta $2115 		;VMAIN - Video port control (Inc on write to $2118)
	
		; abcdefff - abcd=tile sizes e=pri fff=mode def
	lda #%00001001
	sta $2105		;BGMODE - Screen mode register

	jsr load_font
	
	;Set Scroll position
	lda #0
	sta $210D  		;BG1HOFS BG1 horizontal scroll   
	lda #0
	sta $210D  		;BG1HOFS
	lda #-1
	sta $210E  		;BG1VOFS BG1 vertical scroll 
	lda #0
	sta $210E  		;BG1VOFS
	
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WaitVblank:
	lda $4212 			;HVBJOY - Status 
	
		; xy00000a		- x=vblank state y=hblank state a=joypad ready
	and #%10000000
	beq WaitVblank		;Wait until we get nonzero - this means we're in VBLANK
	rts	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

CustomNmihandler:
	php
	pushall
		lda #0
		sta $2116		;MemL -Video port address [VMADDL/VMADDH]                            
		sta $2117		;MemH
		
		lda #128
		sta $2115			;Inc address on write to $2119
			 
		lda #%00000001		;Write mode 001=two bytes alternate
		sta $4300
		
		lda #$18
		sta $4301			;Destination $21--
		
		lda #<SnesScreenBuffer
		sta $4302			;Source (24 bit - Little endian)
		lda #>SnesScreenBuffer
		sta $4303
		lda #0				;bits 16-23
		sta $4304
		
		lda #<(32*32*2)
		sta $4305			;No of bytes (24 bit - Little endian
		lda #>(32*32*2)			;(only 1st 16 bits used?)
		sta $4306
		lda #0
		sta $4307
		
		lda #0
		sta $420C			;Disable H-DMA transfer 
		lda #%00000001		
		sta $420B			;enable DMA 0 (bit0=1)
		
		lda #0
		sta $2115			;Inc address on write to $2118
	pullall
	plp
	rti
	

GetVDPScreenPos:	; BC=XYpos	
		lda z_c
		ifdef ScrWid256	;256x192
			clc
			adc #2
		endif
		sta z_h			;32 tiles per Y line
		lda #0
		clc
		ror z_h
		ror 
		ror z_h
		ror 
		
		adc z_b 	
		adc z_b 	
		sta z_l
		
		lda z_h
		adc #0
		sta z_h
		
		lda z_l			;Calculate address in Buffer
		adc #<SnesScreenBuffer
		sta z_l
		                    
		lda z_h
		adc #>SnesScreenBuffer
		sta z_h
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
	;lda #3	;SX
	;sta z_b
	;lda #3	;SY
	;sta z_c
	
	;ldx #6	;WID
	;ldy #6	;HEI
	
	;lda #0	;TileStart
	
FillAreaWithTiles:
	sta z_d
FillAreaWithTiles_Yagain:
	jsr GetVDPScreenPos
	pushall
		ldy #0
FillAreaWithTiles_Xagain:
		lda z_d			;ttttttttt
		sta (z_hl),Y 	;sta $2118	;l
		iny
		lda #$00		;vhoppptt
		sta (z_hl),Y 	;$2119	;h -Video port data [VMDATAL/VMDATAH]                             
		iny
		
		inc z_d
		dex 
		bne FillAreaWithTiles_Xagain
		inc z_c
	pullall
	dey
	bne FillAreaWithTiles_Yagain
	rts
	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
		
	;BC=Bytes
	;DE=Destination Ram
	;HL=Source Bytes
DefineTiles:
	jsr prepareVram
	
	ldy #0
DefineTilesAgain	
	jsr WaitVblank
	lda (z_HL),Y	
	sta $2119
	jsr DecBC
	jsr incHL
		
	jsr WaitVblank	
	lda (z_HL),Y	
	sta $2118
	jsr DecBC
	jsr incHL
		
	lda z_b
	ora z_c
	bne DefineTilesAgain
	
DefineTileDone:
	lda #%10000000		;Turn on interrupts - FOR BUFFER
	sta $4200
	rts
	
prepareVram:	
	lda #%00000000		;Turn off interrupts - FOR BUFFER
	sta $4200
	
		 	
	jsr WaitVblank
	lda z_e
	sta $2116		;MemL
	lda z_d
	sta $2117		;MemH
	rts
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
		
	
	
SetHardwareSprite:
	pha
	jsr WaitVblank
	pla
		tay
		asl
		sta $2102	;Address L
		lda #0
		sta $2103	;Address H
		lda z_ixl
		sta $2104  ;X
		lda z_iyl
		sta $2104  ;Y
		lda z_h
		sta $2104  ;Tile
		lda z_l
		sta $2104  ;Attribs
		tya
		and %11111100
		lsr
		lsr
		pha
			sta $2102		;Address L
			lda #1
			sta $2103		;Address H
			
		 
			lda $2138
			sta z_as		;Get current attr2
		pla
		sta $2102			;Address L
		lda #1
		sta $2103			;Address H
		 
		lda #%00000011		;Prep the mask
		sta z_b
		 
		tya
		and #%00000011		;4 sprites per byte of attr2
		tax
		 
		lda z_ixh
		and #%00000011
		 
		cpx #0				;Shift bits ------sx into correct position
		beq SpriteSkipShift
SpriteShiftAgain:
		asl
		asl					;Shift new val
		asl z_b
		asl z_b				;Shift mask
		dex
		; jsr monitor
		bne SpriteShiftAgain
SpriteSkipShift: 
		pha
			lda z_as		;Get back current value
			and z_b			;Apply mask
			sta z_as		;Get back current value
		pla
		ora z_as
		sta $2104  
		 
		lda #%00010001	;Turn on BG1+Sprites
		sta $212C ;Main screen designation [TM]    
		lda #%00000010				;Set Sprite pos to $4000
		sta $2101	;OAM settings
	rts