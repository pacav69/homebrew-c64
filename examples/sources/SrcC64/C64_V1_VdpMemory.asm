;  A=Hardware Sprite Number
;z_IX=Xpos
;z_IY=Ypos
; z_H=Pointer to sprites /64
; z_L=%-XY4CCCC	4=4color mode C= sprite color X=doubleX Y=doubleY
SetHardwareSprite:
		tay					;Sprite Number
		lda $D015
		ora LookupBits,y	;Turn on Sprite Y
		sta $D015			;Sprite on
		
		lda #%00010000		;Want bit 4 form z_L
		jsr C64SpriteConvertToMask
		and $D01C
		ora z_as
		sta $D01C			;4 color
		
		lda #%00100000		;Want bit 5 form z_L
		jsr C64SpriteConvertToMask
		and $D017
		ora z_as
		sta $D017			;DoubleHeight
		
		lda #%01000000		;Want bit 6 form z_L
		jsr C64SpriteConvertToMask
		and $D01D
		ora z_as
		sta $D01D			;DoubleWidth	
		
		lda z_h
		sta ScrBase+$07F8,y	;Pointer
		
		lda z_l
		and #%00001111
		sta $D027,y			;Color
		
		lda #%00000001
		and z_ixh
		jsr C64SpriteConvertToMaskB
		and $D010
		ora z_as
		sta $D010 			;8th bit of X
		
		tya		
		asl					;Double Y
		tay
		
		lda z_ixl
		sta $D000,y			;X-pos
				
		lda z_iyl
		sta $D001,y			;Y-pos
		 
		rts
		 
C64SpriteConvertToMask:
		and z_l				;Mask one of the bits in z_L
C64SpriteConvertToMaskB:
		beq C64SpriteConvertToMaskZero 
		lda LookupBits,y	;Bit Y=1
C64SpriteConvertToMaskZero:
		sta z_as
		lda LookupMaskBits,y ;Mask to clear bit
		rts
		
