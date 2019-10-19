ScreenInit:
	
	st0 #5					;RegSelect 5
		 ;BSXXIIII			Backgroundon Spriteon eXtendedsync Interruptenable
	st1 #%11000000			;Background ON, Sprites On
	st2 #0
	
	st0 #9			
		; 0BBB0000
	st1 #%00000000			;BACKGROUND Tilemap size (32x32)
	st2 #0
	
	;Reset Background scroll registers
	
	st0 #7					;Background X-scroll (------XX XXXXXXXX)
	st1 #0
	st2 #0
	
	st0 #8					;Background Y-scroll (-------Y YYYYYYYY)
	st1 #248				;Move Byte pos 0 to top left of screen 
	st2 #0						;(why isn't this already done FFS!))
	
	stz $0402				;Palette address L
	stz $0403				;Palette address H
		 ;GGRRRBBB
	lda #%00000111	
	sta $0404				;Palette data word 
		 ;-------G
	lda #%00000000  
	sta $0405	
	
	jmp InitFont


GetVDPScreenPos:	; BC=XYpos	
		st0 #0					;Select Vram Write
		lda z_c
		
		ifdef ScrWid256
			clc
			adc #2				;Center screen for 256 pixel wide screen
		endif
		and #%00000111			;Multiply Ypos by 32 - low byte
		clc
		ror
		ror
		ror
		ror
		adc z_b					;Add Xpos
		sta $0102				;Send to Data-L
		
		lda z_c
		ifdef ScrWid256
			clc
			adc #2			;Center screen for 256 pixel wide screen
		endif
		and #%11111000		;Multiply Ypos by 32 - low byte
		clc
		ror					
		ror
		ror
		sta $0103			;Send to Data-H
	rts
	
	
FillAreaWithTiles:			; z_b = SX... z_c = SY... X=Width...
							; Y= Height... A=start tile
	sta z_d
FillAreaWithTiles_Yagain:
	pushall
		jsr GetVDPScreenPos	;Recalculate memory position
	pullall
	pushall
		lda z_d
FillAreaWithTiles_Xagain:	;Save the TileNum to Vram
		
		st0 #2				;Set Write Register
		
		sta $0102			;L Byte
		
		st2 #1				;H Byte - Tile 256+
		clc
		adc #1				;Increase Tile Number
		dex 
		bne FillAreaWithTiles_Xagain
		sta z_d
		inc z_c				;Inc Ypos
	pullall
	dey						;Decrease Y count
	bne FillAreaWithTiles_Yagain
	
	rts
	
	
	
		
DefineTiles:				;BC=Bytes
							;DE=Destination Ram
							;HL=Source Bytes
							
	jsr prepareVram			;Select Ram address
	st0 #2					;Select Data reg
	
	ldy #0	
DefineTilesAgain:
		lda (z_HL),Y		;Load a byte
		sta $0102			;Store Low byte
		jsr DecBC			;Decrease Count
		jsr incHL			;Increase Source Addr
		
		lda (z_HL),Y		;Load a byte
		sta $0103			;Store High Byte
		jsr DecBC			;Decrease Count
		jsr incHL			;Increase Source Addr
		
		lda z_b				;repeast until z_bc=0
		ora z_c
		bne DefineTilesAgain
	rts
	
prepareVram:		;z_HL=VRAM address to select

	st0 #0			;Select Memory Write Reg
	lda z_e
	sta $0102 		;st1 - L address
	lda z_d
	sta $0103 		;st2 - H Address
	rts

SetHardwareSprite:	;A=Hardware Sprite No. B,C = X,Y , D,E = Source Data, H=Palette etc

	pha
	asl
	asl
		
		st0 #0					;Sprite Table (copy in ram) 4 bytes per sprite x 64 sprites
		sta $0102 ;st1 #$00
		lda #$7F
		sta $0103 ;st2 #$10
	
		st0 #2					;Ypos (64 is visible top left corner)
		lda z_iyl
		sta $0102 ;st1 #$00
		lda z_iyh
		sta $0103 ;st2 #$10
		
		lda z_ixl				;Xpos  (32 is visible top left corner)
		sta $0102 ;st1 #$00
		lda z_ixh
		sta $0103 ;st2 #$10
		
		lda z_e					;Sprite Address >>5
		sta $0102 ;st1 #$00
		lda z_d
		sta $0103 ;st2 #$10
		
		lda z_l					;Sprite Attributes
		sta $0102 ;st1 #$00
		lda z_h
		sta $0103 ;st2 #$10
	
		st0 #$13			;Update the STAB address to force a copy to the graphics hardware
		lda #$00
		sta $0102 ;st1 #$00
		lda #$7F
		sta $0103 ;st2 #$10
	
	
	pla
	rts
