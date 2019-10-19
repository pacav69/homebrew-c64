
;Mode2Color equ 1	;For C64,Apple 2 & Atari
ScrWid256 equ 1

	ifdef BuildNES
UseNesBuffer equ 1
VDPBuffer equ UserRam
	endif
	
	ifdef BuildSNS
UseNesBuffer equ 1
SnesScreenBuffer equ UserRam+$400
	endif
	
	include "..\SrcALL\V1_Header.asm"
	include "\SrcAll\BasicMacros.asm"
	
;FourColor equ 1	


	SEI			;Stop interrupts
	jsr ScreenInit

	
	
	ifdef BuildVIC
		jsr Cls
	else
		jsr Cls
	endif
	jsr Monitor	
		

	lda #<MyText
	sta z_L
	lda #>MyText
	sta z_H
	jsr PrintString

	
	ldx #4
	ldy #8
	
	ifdef BuildAP2
bmpwidth equ 8
	else
	ifdef BuildLNX
bmpwidth equ 24
	else
	ifdef BuildC64
bmpwidth equ 3
	else
bmpwidth equ 6	
	endif

	endif
	endif
	
	
	
	
;BMPNORMAL equ 1
	ifdef BuildLNX
BMPNORMALQ equ 1
	endif
	ifdef BuildA52
BMPNORMALQ equ 1
	endif
	ifdef BuildA80
BMPNORMALQ equ 1
	endif
	ifdef BuildAP2
BMPNORMAL equ 1
	endif
	
	
	ifdef BuildBBC
BMPBBC equ 1		;also C64- do 8 lines in groups before next x tile
	endif
	ifdef BuildC64
BMPBBC equ 1		;also C64- do 8 lines in groups before next x tile
	endif
	
	
	ifdef BuildNES
BMPTILE equ 1
	endif
	ifdef BuildPCE
BMPTILE equ 1
	endif
	ifdef BuildSNS
BMPTILE equ 1
	endif
	ifdef BuildVIC
BMPTILE equ 1
	endif
	
	
	
	lda #<Bitmap					;Source Bitmap Data
	sta z_L
	lda #>Bitmap
	sta z_H

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;											Tile Type
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	ifdef BMPTILE
	
	lda #<(BitmapEnd-Bitmap)		;Source Bitmap Data Length
	sta z_C
	lda #>(BitmapEnd-Bitmap)
	sta z_B
	
	ifdef BuildPCE
		lda #<$1800					;Tile 384 (256+128 - 32 bytes per tile)
		sta z_E
		lda #>$1800
		sta z_D
	endif
	ifdef BuildNES
		lda #<$0800					;Tile 128 (16 bytes per tile)
		sta z_E
		lda #>$0800
		sta z_D
	endif
	ifdef BuildSNS
		lda #<$1800					;Snes patterns start at $1000
		sta z_E						; each adddress holds 1 word...  
		lda #>$1800					; so each 32 byte tile takes 16 addreses,
		sta z_D						; and tile 128 is at $1800
	endif
	ifdef BuildVIC
		lda #<$1C00					;Tile 0 in VIC Custom Characters
		sta z_E
		lda #>$1C00
		sta z_D
	endif
	jsr DefineTiles					;Define the tile patterns
	
	lda #3							;Start SX
	sta z_b
	lda #3							;Start SY
	sta z_c
	
	ldx #6							;Width in tiles
	ldy #6							;Height in tiles
	
	ifdef BuildVIC
		lda #0							;TileStart
	else
		lda #128						;TileStart
	endif
	jsr FillAreaWithTiles			;Draw the tiles to screen
	
	endif
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;											BBC Type - 8 bytes down - then across
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	ifdef BMPBBC
	
	lda #0
NexBitmapNextStrip:
	pushall
		jsr GetScreenPos			;Get screen pos from XY into Z_DE
BitmapNextLine:
		pushall
			ldY #0					;Offset for bytes in this strip
BitmapNextByte:
			lda (z_hl),Y			;Load in a byte from source - offset with Y
			sta (z_de),Y			;Store it in screen ram - offset with Y
			
			
			;loadpair z_bc,$1000
			;jsr Pause
			
			inY						;INC the offset
			cpY #bmpwidth*8*2		;We draw 8 lines * bitmap width
			bne BitmapNextByte
			
			sty z_C					;ADD Y to Z_HL to move source down one strip 
			jsr addHL_0C			;Add Z_C to HL
		pullall
	pullall
	pha
		tya
			clc
			adc #8					;Move Y down 8 lines
		tay
	pla
	clc
	adc #1
	cmp #6					;NO of strips in Bitmap (Y) 8 rows per strip
	bne NexBitmapNextStrip
	
	endif	; BMPBBC
	

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;									Normal type - linear bmp
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		ifdef BMPNORMALQ			;Simple bitmap routine 
			
		lda #<Bitmap	;Bitmap source
		sta z_L
		lda #>Bitmap
		sta z_H
	
		ldx #6			;Xpos
		ldy #6			;Ypos
	
		jsr GetScreenPos
		ldx #0
BitmapNextLine:
		pushall
			ldY #0
			PushPair z_de			;Backup Mempos
BitmapNextByte:
				ldx #0
				lda (z_hl),Y		;Copy a byte from the source 
				sta (z_de),Y		;to the destination
					
				inY
				cpY #bmpwidth		;Repeat for next byte of line
				bne BitmapNextByte
				
				sty z_C				;ADD Y to Z_HL to move source down one strip 
				jsr addHL_0C		;Add Z_C to HL
				
			PullPair z_de			;Restore mempos
			jsr GetNextLine			;move mempos down a line
		pullall
		inx 
		cpx #8*6					;Check if we've done all the lines
		bne BitmapNextLine			;Repeat until we have

	endif 	;End of BMPNORMALQ	

	ifdef BMPNORMAL

		ldx #6			;Xpos
		ldy #8			;Ypos
		
		lda #0				
NexBitmapNextStrip:
		pushall
			jsr GetScreenPos
			ldx #0
BitmapNextLine:
			pushall
				ldY #0
				PushPair z_de			;Backup Mempos
BitmapNextByte:
					ldx #0
					lda (z_hl,X)
					
					sta (z_de),Y
					jsr IncHL
					
					inY
					cpY #bmpwidth				
					bne BitmapNextByte
				PullPair z_de			;Restore mempos
				jsr GetNextLine			;move mempos down a line
				
		;	loadpair z_bc,$0FFF	;Pause to allow redraw to be seen
		;
		jsr Pause
			pullall
			inx 
			cpx #8
			bne BitmapNextLine			;Some systems need a recalc every 8 lines
		pullall
		pha
			tya
			clc
			adc #8						;Move Y down 8 lines
			tay
		pla
		clc
		adc #1
		cmp #6							;See if we've got to the end of the bitmap
		bne NexBitmapNextStrip			;Every 8 lines we need to do a full recalc
	
	endif 	;End of BMPNORMAL	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	;jmp *

	lda #>Palette		;Palette definitions
	sta z_d
	lda #<Palette
	sta z_e

	ldy #0
SetPaletteAgain:	
	lda (z_de),y		;Low byte of color
	sta z_l
	iny
	lda (z_de),y		;High byte of color
	sta z_h
	iny
	
	tya					;Halve Y
	clc
	ror
	sec					;Subtract 1
	sbc #1
	jsr SetPalette		;-GRB definition in Z_HL... 
							;A=palette entry (0=background)
	ifdef BuildNES
		cpy #32*2		;16 for back, 16 for sprite
	else
		cpy #4*2		;4 palette entries, 2 bytes each
	endif
	bne SetPaletteAgain

	jmp *
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
Pause:
	jsr decbc
	lda z_b
	ora z_c
	bne Pause		;Pause for BC ticks
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	
	include "\SrcAll\monitor.asm"
	include "\SrcAll\BasicFunctions.asm"
	
MyText
    db "Hello worlds!10000001235678!!!",  255
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
Bitmap:
	Ifdef BuildAP2
		ifdef Mode2Color
			incbin "\ResAll\Sprites\RawAP2.RAW"
		else
			incbin "\ResAll\Sprites\RawAP2_4col.RAW"
		endif
	endif
	Ifdef BuildA52	
		ifdef Mode2Color
			incbin "\ResALL\Sprites\RawZX.RAW"
		else
			incbin "\ResALL\Sprites\RawA52.RAW"
		endif
	endif
	Ifdef BuildA80
		ifdef Mode2Color
			incbin "\ResALL\Sprites\RawZX.RAW"
		else
			incbin "\ResALL\Sprites\RawA52.RAW"
		endif
	endif
	ifdef BuildLNX
		incbin "\ResALL\Sprites\RawMSX.RAW"
	endif
	ifdef BuildBBC
		incbin "\ResALL\Sprites\RawBBC.RAW"
	endif
	ifdef BuildC64
		ifdef Mode2Color
			incbin "\ResALL\Sprites\RawC64-2col.RAW"
		else
			incbin "\ResALL\Sprites\RawC64-4col.RAW"
		endif
	endif
	ifdef BuildNES
		incbin "\ResALL\Sprites\RawNES.RAW"
	endif
	ifdef BuildPCE
		incbin "\ResALL\Sprites\RawPCE.RAW"
	endif
	ifdef BuildSNS
		incbin "\ResALL\Sprites\RawSNS.RAW"
	endif
	ifdef BuildVIC
		incbin "\ResAll\Sprites\RawVIC.raw"
	endif
BitmapEnd:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
BitmapFont:
	incbin "\ResALL\Font96.FNT"		;Not used by the VIC due to memory limitations

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

Palette:
	;   -grb
	dw $0000	;0 - Background;
	dw $0099	;1
	dw $0E0F	;2
	dw $0FFF	;3 - Last color in 4 color modes
	dw $000F	;4;
	dw $004F	;5
	dw $008F	;6
	dw $00AF	;7
	dw $00FF	;8
	dw $04FF	;9
	dw $08FF	;10
	dw $0AFF	;11
	dw $0CCC	;12
	dw $0AAA	;13
	dw $0888	;14
	dw $0444	;15
	
	
	ifdef BuildNES	;Nes sprite colors
		dw $0000	;0 - Background;
		dw $0099	;1
		dw $0E0F	;2
		dw $0FF0	;3 - Last color in 4 color modes
		dw $000F	;4;
		dw $004F	;5
		dw $008F	;6
		dw $00AF	;7
		dw $00FF	;8
		dw $04FF	;9
		dw $08FF	;10
		dw $0AFF	;11
		dw $0CCC	;12
		dw $0AAA	;13
		dw $0888	;14
		dw $0444	;15
		dw $0FFF	;Border
	endif

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

	
	include "\SrcAll\V1_BitmapMemory.asm"
	include "\SrcALL\V1_Palette.asm"
	
	ifndef UseNesBuffer
		include "\SrcALL\V1_Functions.asm"		
		include "\SrcALL\V1_VdpMemory.asm"
	else
		ifdef BuildNES
			include "\SrcNes\Nes_V2_VdpMemory.asm"
			include "\SrcNes\V2_Functions.asm"
		endif
		ifdef BuildSNS
			include "\SrcSNS\SNS_V2_VdpMemory.asm"
			include "\SrcSNS\V2_Functions.asm"
		endif
	endif
	
	; ifdef BuildSNS
		; include "\SrcSNS\SNS_V1_VdpMemory.asm"
	; endif
	; ifdef BuildVIC
		; include "\SrcVIC\VIC_V1_VdpMemory.asm"
	; endif	
	; ifdef BuildPCE
		; include "\SrcPCE\PCE_V1_VdpMemory.asm"
	; endif
	; ifdef BuildNES
		; include "\SrcNES\NES_V1_VdpMemory.asm"
	; endif
	; ifdef BuildC64
		; include "\SrcC64\C64_V1_VdpMemory.asm"
	; endif
	; Ifdef BuildA52
		; include "\SrcA52\A52_V1_Palette.asm"
	; endif
	; Ifdef BuildA80
		; include "\SrcA52\A52_V1_Palette.asm"
	; endif
	; ifdef BuildLNX
		; include "\SrcLNX\LNX_V1_Palette.asm"
	; endif
	; ifdef BuildPCE
		; include "\SrcPCE\PCE_V1_Palette.asm"
	; endif
	; ifdef BuildNES
		; include "\SrcNES\NES_V1_Palette.asm"
	; endif
	; Ifdef BuildAP2
		; include "\SrcAP2\AP2_V1_Palette.asm"
	; endif
	; ifdef BuildBBC
		; include "\SrcBBC\BBC_V1_Palette.asm"
	; endif
	; ifdef BuildSNS
		; include "\SrcSNS\SNS_V1_Palette.asm"
	; endif
	; ifdef BuildC64
; SetPalette:
	; rts
	; endif
	; ifdef BuildVIC
; SetPalette:
	; rts
	; endif
		
		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
		; ifdef BuildVIC
		; ifndef BuildVIC_Rom
			; org $1C00
			; db 0,0,0,0,0,0,0,0	;Set Char 0 to blank
			; incbin "\ResAll\Sprites\RawVIC.raw"
		; endif
		; endif
		
		include "..\SrcALL\V1_Footer.asm"
		
 