GetColMemPos:
		rts
		
		
GetVDPScreenPos:	; BC=XYpos	
	lda #$1e						;Screen base is $1E00
	sta z_h
	
	lda z_b							;Xpos
	sta z_l
	
	lda #0
	sta z_d
	lda #22							;Screen Width
	sta z_e
	ldy z_c
	beq GetVDPScreenPos_YZero
GetVDPScreenPos_Addagain:	
	jsr AddHL_DE					;Repeatedly add screen width Y times 
	dey
	bne GetVDPScreenPos_Addagain
GetVDPScreenPos_YZero:
	rts

FillAreaWithTiles:
	sta z_as						;Backup Tile number
FillAreaWithTiles_Yagain:
	pushall 
		jsr GetVDPScreenPos			;Calculate screen ram location of tile
	pullall 
	pushall
		lda z_as
		ldy #0
FillAreaWithTiles_Xagain:
		sta (z_hl),y				;Transfer Tile to ram
		jsr IncHL
		clc
		adc #1						;Increase tile number
		dex							;Decrease X counter
		bne FillAreaWithTiles_Xagain
		sta z_as					;Back up Tilenum for next loop
		inc z_c
	pullall
	dey								;Decrease Y counter
	bne FillAreaWithTiles_Yagain
	rts
	
	
	;LLLL options
	   ; 0000   ROM   8000  32768
	   ; 0001         8400  33792
	   ; 0010         8800  34816
	   ; 0011         8C00  35840
	   ; 1000   RAM   0000  0000
	   ; 1001         xxxx
	   ; 1010         xxxx  unavail.
	   ; 1011         xxxx
	   ; 1100         1000  4096
	   ; 1101         1400  5120
	   ; 1110         1800  6144
	   ; 1111         1C00  7168		<---
	   
	   
ScreenInit:
	ldx #16					;We're going to copy 16 registers 
ScreenInitAgain:	
	dex
	lda VicScreenSettings,x	;Get A parameter
	sta $9000,X				;Store to the video registers at $9000
	txa
	bne ScreenInitAgain
VicTilesAt_1C00:
prepareVram:	
	rts
	
VicScreenSettings:
	db $0C		;$9000 - horizontal centering
	db $26		;$9001 - vertical centering
	db $96		;$9002 - set # of columns / 
					;Bit7 = screen base bit ($16 for screen at $1000)
	db $AE		;$9003 - set # of rows
	db $7A		;$9004 - TV raster beam line
	db $FF		;$9005 - bits 0-3 start of character memory /  
					;bits 4-7 is rest of video address 
					;$(CF for screen at $1000)
	db $57		;$9006 - horizontal position of light pen
	db $EA		;$9007 - vertical position of light pen
	db $FF		;$9008 - Digitized value of paddle X
	db $FF		;$9009 - Digitized value of paddle Y
	db $00		;$900A - Frequency for oscillator 1 (low)
	db $00		;$900B - Frequency for oscillator 2 (medium)
	db $00		;$900C - Frequency for oscillator 3 (high)
	db $00		;$900D - Frequency of noise source
	db $00		;$900E - bit 0-3 sets volume of all sound / 
					;bits 4-7 are auxiliary color information
	db $66+8 	;$900F - Screen and border color register
	
	
	

DefineTiles:	
	jmp LDIR	;Copy Data to the Character Defs from ram/rom to char ram


	
	
	
		
