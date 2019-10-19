
GetScreenPos:
	;BBC type is odd - the first 8 screen bytes go DOWN... the 9ths goes back to the top - effectively we're filling in 8x8 character blocks in a zigzag pattern
	pushpair z_bc
		lda #0
		sta z_d
		
		txa					;Xpos
		clc
		rol 
		rol z_d		;2
		rol 
		rol z_d		;4
		rol 
		rol z_d		;8		;8 bytes per X line
		sta z_e
		
		tya					;Ypos
		and #%11111000		;We have to work in 8 pixel tall strips on the BBC
			lsr			;$04
			lsr			;$02
		ifdef ScrWid256		;Y strip is $0280 /$0200 bytes tall
			clc
			adc z_d			;Add to D
			sta z_d
		else
			sta z_b			;Multiply Y strip num by $02				
			clc
			adc z_d			;Add to D
			sta z_d
			
			lda #0
			ror z_b		;$01 00		
			ror
			ror z_b		;$00 80
			ror
			adc z_e			;Add to E
			sta z_e
			lda z_b			;Add to D
			adc z_d
			sta z_d
		endif
		
	ifdef ScrWid256
		lda #$50			;Screen Offset $5000
		sta z_b	
		lda #$00
		sta z_c
	else
		lda #$41			;Screen Offset $4180
		sta z_b	
		lda #$80
		sta z_c
	endif
		jsr AddDE_BC
	pullpair z_bc
	rts
	
GetNextLine:
	jsr incde				;within 8x8 boundary we just do an INC to move down
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
ScreenInit:
	lda #$D8				;Mode 1
	sta $FE20				;Video ULA Control
	
	ldx #0
NextCRTCreg:
	txa
	sta $FE00				;Reg Select
	lda CRTCConfig,X
	sta $FE01				;Reg Data
	inx
	txa
	cmp #14					;Last Register?
	bne NextCRTCreg	
	
SendULA:
	ldx #0
NextULAreg	
	lda ULAConfig,X
	sta $FE21				;Load in color config
	inx
	txa
	cmp #16
	bne NextULAreg	
	rts
	
	
;scr=$3000 when 256x192
;Set screen height to 25, and screen offset so we're using &3
	
CRTCConfig:
	db $7F		;0 - Horizontal total
	ifdef ScrWid256 
		db $40		;1 - Horizontal displayed characters
		db $62		;2 - Horizontal sync position
		db $28		;3 - Horizontal sync width/Vertical sync time
	else
		db $50		;1 - Horizontal displayed characters
		db $62		;2 - Horizontal sync position
		db $28		;3 - Horizontal sync width/Vertical sync time
	endif
	db $26			;4 - Vertical total
	db $00			;5 - Vertical total adjust
	db $18			;6 - Vertical displayed characters (25)
	db $22			;7 - Vertical sync position
	db $01			;8 - Interlace/Display delay/Cursor delay
	db $07			;9 - Scan lines per character
	db %00110000	;10 - Cursor start line and blink type
	db $0			;11 - Cursor end line
	ifdef ScrWid256 
		db $0A		;12 - Screen start address H (Address /8)
		db $00		;13 - Screen start address L 
	else
		db $08		;12 - Screen start address H (Address /8)
		db $30		;13 - Screen start address L ($4130/8=$0830)
	endif
	
ULAConfig:	
Palette0:	;Colours
;		SC  SC		-	S=Screen C=Color
	db $03,$13	;0
	db $43,$53	;0
Palette1:
	db $22,$32		;1
	db $62,$72		;1
Palette2:
	db $84,$94			;2
	db $C4,$D4			;2
Palette3:
	db $A0,$B0				;3
	db $E0,$F0				;3
	
;EOR True   Color
;7  (0) 	black
;6  (1) 	red
;5  (2) 	green
;4  (3) 	yellow (green—red)
;3  (4) 	blue
;2  (5) 	magenta (red—blue)
;1  (6) 	cyan (green—blue)
;0  (7) 	white
				
				