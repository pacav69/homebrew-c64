ScreenInit:
		 ;aaaabbbb -aaa=base addr for BG2 bbb=base addr for BG1
	lda #%00010001
	sta $210B 		;BG1 & BG2 VRAM location register [BG12NBA]                    
	
	;     xxxxxxss 	- xxx=address… ss=SC size  00=32x32 01=64x32 10=32x64 11=64x64
	lda #%00000000
	sta $2107		;BG1SC - BG1 Tilemap VRAM location
	
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
	
	
	
	;Set Sprite defaults
	
		; ---S4321 - S=sprites 4-1=enable Bgx
	lda #%00010001		;Turn on BG1+Sprites
	sta $212C 			;Main screen designation [TM]    
	
		; SSSNNBBB - S=size N=Bame addr B=Base addr
	lda #%00000010		;Set Sprite pos to $4000
	sta $2101			;OAM settings
	
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

WaitVblank:
	lda $4212 			;HVBJOY - Status 
	
		; xy00000a		- x=vblank state y=hblank state a=joypad ready
	and #%10000000
	beq WaitVblank		;Wait until we get nonzero - this means we're in VBLANK
	rts	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
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
		ror z_h
		ror 
		sta z_l
		
		jsr WaitVblank
		lda z_b 		;Add X line
		adc z_l
		sta $2116		;MemL -Video port address [VMADDL/VMADDH]                            
		lda z_h
		sta $2117		;VMDATAL - We're writing bytes in PAIRS!
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
FillAreaWithTiles_Xagain:
		jsr WaitVblank
		lda #$00			;;vhoppptt
		sta $2119			;VMDATAH - Write first byte to VRAM
		
		lda z_d				;ttttttttt
		sta $2118			;VMDATAL - were set to Autoinc address
		clc						; on 2118 write
		
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
	jsr prepareVram	;Get VRAM address
	
	ldy #0
DefineTilesAgain	
	jsr WaitVblank
	lda (z_HL),Y	
	sta $2119		;VMDATAH - Write first byte to VRAM
	jsr DecBC				
	jsr incHL
		
	jsr WaitVblank	
	lda (z_HL),Y	
	sta $2118		;VMDATAL - were set to Autoinc address 
	jsr DecBC			;on 2118 write
	jsr incHL
	
	lda z_b
	ora z_c
	bne DefineTilesAgain
DefineTileDone:
	rts
	
	
prepareVram:			
	jsr WaitVblank
	lda z_e
	sta $2116		;VMADDL - Destination address in VRAM L
	lda z_d
	sta $2117		;VMADDH - Destination address in VRAM H
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
SetHardwareSprite:
	tay				;Lets do the main 4 definitions
		
		asl			; Double Sprite number 
					;(2 bytes per address - 2 addresses)
		sta $2102	;Address L
		lda #0
		sta $2103	;Address H
		 
		lda z_ixl
		sta $2104  	;X-pos
		lda z_iyl
		sta $2104 	;Y-pos
		lda z_h
		sta $2104  	;Tile pattern
		lda z_l
		sta $2104  	;Attribs ;YXPPPCCCT - Y=yflip X=xflip P=priority compared to BG C=palette +128 T= Tile Pattern number
	tya

	;4 sprites Attr2 are combined into one Attr2
	
	and %11111100		;Work out which one to change by sprite num
	lsr
	lsr
	pha				
		sta $2102		;Address L
		lda #1
		sta $2103		;Address H ($01xx)
	
		lda $2138		;Get current attr2
		sta z_as		
	pla
	sta $2102			;Address L
	lda #1
	sta $2103			;Address H
	 
	lda #%11111100		;Prep the mask
	sta z_b
	
	tya
	and #%00000011		;Get low 2 bits of sprite num
	tax
	
	lda z_ixh
	and #%00000011		;Two bits we want to store in attr2
	 
	cpx #0				;Shift bits ------sx into correct position
	beq SpriteSkipShift
SpriteShiftAgain:
	asl
	asl				;Shift new val 
	asl z_b
	asl z_b			;Shift mask
	dex
	bne SpriteShiftAgain
SpriteSkipShift: 
	pha
		lda z_as		;Get back current value
		and z_b			;Apply mask
		sta z_as		;Get back current value
	pla
	ora z_as			;Or in Old value to new one
	sta $2104  			;Store it!
	rts