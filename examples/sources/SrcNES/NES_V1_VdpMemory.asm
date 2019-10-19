ScreenInit:
	jsr load_font			;load font
	
	lda #$3F				;Select Palette ram &3F00
	sta $2006	;PPUADDR
	lda #$00
	sta $2006	;PPUADDR
	
	lda #$02				;Background
	sta $2007	;PPUDATA
	lda #$38				;Color 1
	sta $2007	;PPUDATA
	lda #$21				;Color 2
	sta $2007	;PPUDATA
	lda #$15				;Color 3
	sta $2007	;PPUDATA
	
NesEnableScreen:			;Turn ON the screen

	lda #%00011110 	;(Sprite enable/back enable/Sprite leftstrip / backleftstrip)
	sta $2001	;PPUMASK
	
	lda #$80				;NMI enable (Vblank)
	sta $2000	;PPUCTRL - VPHB SINN
	rts
	
NesDisableScreen:			;Turn OFF the screen

	lda #%00000000	;(Sprite enable/back enable/Sprite leftstrip / backleftstrip)
	sta $2001	;PPUMASK
	;lda #$00				;NMI disable (Vblank)
	sta $2000	;PPUCTRL - VPHB SINN
	rts	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		
waitframe:
	pha
		lda #$00
		sta vblanked		;Zero Vblanked
waitloop:
		lda vblanked		;Wait for the interrupt to change it
		beq waitloop
	pla
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	


GetVDPScreenPos:			; BC=XYpos	
		lda z_c
		and #%00000111		;Ypos * 32 tiles per line
		clc
		ror
		ror
		ror
		ror
		ora z_b				;Add Xpos
		sta z_l				;Store in L byte
		lda z_c
		and #%11111000		;Other bits of Ypos for H byte
		clc
		ror
		ror
		ror
		clc
		adc #$20			;$2000 ofset for base of tilemap
		jsr waitframe		;Wait for Vblank
		sta $2006	;PPUADDR
		lda z_L
		sta $2006	;PPUADDR
	rts
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
	;lda #3	;SX
	;sta z_b
	;lda #3	;SY
	;sta z_c
	
	;ldx #6	;WID
	;ldy #6	;HEI
	
	;lda #0	;TileStart
	
FillAreaWithTiles:
	sta z_d					;Backup tilenum
FillAreaWithTiles_Yagain:
	pushall
		jsr GetVDPScreenPos	;Calculate Tilemap mempos
	pullall
	pushall
		lda z_d
FillAreaWithTiles_Xagain:
		sta $2007	;PPUDATA - Save Tile selection to Vram
		clc
		adc #1				;Move to next tile
		dex 
		bne FillAreaWithTiles_Xagain
		sta z_d
	inc z_c					;INC Ypos
	pullall
	dey
	bne FillAreaWithTiles_Yagain
						
	;jmp resetscroll		;Need to reset scroll after writing to VRAM
	
ResetScroll:	
	lda #0					;Scroll X
	sta $2005	;PPUSCROLL
	lda #0-8				;Scroll y
	sta $2005	;PPUSCROLL
	rts
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	;BC=Bytes
	;DE=Destination Ram
	;HL=Source Bytes		
	
DefineTiles:				;Send Data to tile definitions
	pha
	jsr NesDisableScreen
	pla
	jsr prepareVram			;Calculate destination address
		ldy #0
DefineTilesAgain	
		lda (z_HL),Y	
		sta $2007 ;PPUDATA - Write data to data-port
		 jsr DecBC
		 jsr incHL			;Update our counters
		 lda z_b
		 ora z_c
		 bne DefineTilesAgain
		jmp NesEnableScreen
	
	
	
prepareVram:				;Select a destination address

		lda z_d				;MSB - DEST ADDR
		sta $2006;PPUADDR
		lda z_e				;LSB - Dest ADDR
		sta $2006;PPUADDR
	rts

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

SetHardwareSprite:	;A=Hardware Sprite No. B,C = X,Y , D,E = Source Data, H=Palette etc

	jsr waitframe
	pha
	asl
	asl
	sta $2003	;Select OAM address - 4 bytes per sprite - 64 sprites total
	
	lda z_iyl		;Ypos
	sta $2004
	
	lda z_E		;Tilenum
	sta $2004
	
	lda z_l
	sta $2004	;Attribs VHB---PP Vflip  Hflip  Background priority  Palette
	
	lda z_ixl		;Xpos
	sta $2004
	
	jsr ResetScroll
	pla
	rts

	