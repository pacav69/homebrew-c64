;-------------------------------------- $2400
;Attribute Table 0
;-------------------------------------- $23C0
;Name Table 0 (32x30 tiles)
;-------------------------------------- $2000

;Vblanking equ z_Regs+17


SpriteBuffer equ VDPBuffer+$100
VDP_CT equ z_Regs+18

CustomNmihandler:
	pushall
		lda #SpriteBuffer/256	;Data to copy to sprites
		sta $4014 				;Start Srirte DMA
		
		ldy #0
CustomNmihandlerAgain:	
		cpy VDP_CT				;See if there are any bytes left to write
		bcs CustomNmihandlerDone
		
		lda VDPBuffer,y
		iny	
		sta $2006	;PPUADDR 	Destination address - H
		
		lda VDPBuffer,y
		iny
		sta $2006	;PPUADDR 	Destination address - L
		
		lda VDPBuffer,y
		iny
		sta $2007 	;PPUDATA
		
		jmp CustomNmihandlerAgain;Process more bytes

CustomNmihandlerDone:		;Reset Scroll
		lda #0				;Scroll X
		sta VDP_CT
		sta $2005
		lda #0-8			;Scroll y
		sta $2005

		inc vblanked		;Alter Vblank Zero page entry
	pullall
	rti						;Return from interrupt handler


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
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
	
	jsr ResetScroll
	
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
	

	
ResetScroll:	
	lda #0		;Scroll X
	sta $2005
	lda #0-8	;Scroll y
	sta $2005	
	rts
		
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
GetVDPScreenPos:			; BC=XYpos
	lda z_c
	ifdef ScrWid256		;256x192
		clc
		adc #2
	endif
	and #%00000111		;Ypos * 32 tiles per line
	clc
	ror
	ror
	ror
	ror
	ora z_b				;Add Xpos
	sta z_l				;Store in L byte
	lda z_c
	ifdef ScrWid256	;256x192
		clc
		adc #2
	endif
	and #%11111000		;Other bits of Ypos for H byte
	clc
	ror
	ror
	ror
	clc
	adc #$20			;$2000 ofset for base of tilemap
	sta z_h
		
	jsr GetVdpBufferCT	;Get the VDP buffer pos
	lda z_h
	sta VDPBuffer,Y		;Store the address to the buffer
	iny
	lda z_l
	sta VDPBuffer,Y
	iny					;We still need to write a data byte!
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
GetVdpBufferCT:	
	ldy VDP_CT
	cpy #32*3			;See if buffer is full
	bcc VdpNotBusy		
	jsr waitframe		;Buffer is full, so wait for Vblank
	ldy VDP_CT
VdpNotBusy:	
	lda #0
	sta VDP_CT			;Halt the queue
	rts
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		
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
		lda z_b
		pha		
FillAreaWithTiles_Xagain:
			jsr GetVDPScreenPos	;Calculate Tilemap mempos
			
			lda z_d
			sta VDPBuffer,y		;Save Tile selection to Vram
			iny
			sty VDP_CT			;INC and save Buffer Pos 
			
			inc z_d				;INC Tile num
			inc z_b				;INC Xpos
			dex 
			bne FillAreaWithTiles_Xagain
		pla 
		sta z_b					;reset Xpos
		inc z_c					;INC Ypos
	pullall
	dey
	bne FillAreaWithTiles_Yagain	
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		
DefineTiles:
	
	;BC=Bytes
	;DE=Destination Ram
	;HL=Source Bytes
	pha
	jsr NesDisableScreen
	pla
	jsr prepareVram
	
	
		ldy #0
DefineTilesAgain	
		lda (z_HL),Y	
		sta $2007			;Write data to data-port
		 jsr DecBC
		 jsr incHL
		 lda z_b
		 ora z_c
		 bne DefineTilesAgain
		 jsr NesEnableScreen
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
prepareVram:		;7FFF003 = FFFF 40000=0000
		lda z_d	
		sta $2006;PPUADDR			;MSB - DEST ADDR
		lda z_e
		sta $2006;PPUADDR			;LSB - Dest ADDR
	rts


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		

SetHardwareSprite:	;A=Hardware Sprite No. B,C = X,Y , D,E = Source Data, H=Palette etc
;On the gameboy You need to set XY to 8,16 to get the top corner of the screen
	;jsr waitframe
	pha
	asl
	asl
	sta z_l
	lda #SpriteBuffer/256
	sta z_h
	
	ldy #0
	
	lda z_iyl		;Ypos
	sta (z_hl),y
	iny
	lda z_E		;Tilenum
	sta (z_hl),y
	iny
	lda z_l
	sta (z_hl),y
	iny
	lda z_ixl		;Xpos
	sta (z_hl),y
	iny
	;jsr ResetScroll
	pla
	rts

	