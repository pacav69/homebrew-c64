	include "..\SrcALL\V1_Header.asm"		;Cartridge/Program header - platform specific
	include "\SrcAll\BasicMacros.asm"		;Basic macros for ASM tasks

	SEI						;Stop interrupts
	jsr ScreenInit			;Init the graphics screen
	jsr Cls					;Clear the screen
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	

	; jsr MemDump
    ; word Bytes      ;Address
    ; byte $2         ;Lines	
	
	; jmp *

; Bytes:
	; db $01,$02,$03,$04	;Define 4 separate bytes
	
; Words:
	; dw $F1F0,$E1E0		;Define two words
	
; sequence:
	; ds 3,$CC			;Define 3 bytes of CC
	; ds 1				;Define 1 byte of 00
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; StartAgain:
	; ldx #16
; LoopAgain:
	; dex
	; txa 
	; pha
		; jsr SineLocate	;Locate a position based on the 
		; lda #'X'		;  sine wave in the lookuptable
		; jsr printchar	;Print an X
		; jsr DoDelay
	; pla
	; tax
	; cpx #0				;Repeat until Zero
	; bne LoopAgain
	; jmp *

; SineLocate:	
		; tay				;use value in X as a Ypos
		; lda sine,x		;Get value X from the lookuptable
		; lsr		
		; lsr				;convert 0-255 to 0-16
		; lsr
		; lsr
		; tax				;Use Sine value as an Xpos
		; jsr locate		
	; rts

; Sine:	;Simple 16 entry Sine wave LOOKUP TABLE
	; db 128,176,217,245,255,254,245,217,175,128,77,36,8,0,8,36,78
	
; DoDelay:			;Delay for 255 x 255
	; txa
	; pha
		; ldy #255	
		; ldx #255
; delay:	
		; dex
		; bne delay
		; dey
		; bne delay
	; pla
	; tax	
	; rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; cmdDash equ 0			;Defined Symbols to represent
; cmdNewLine equ 1		;	 commands
; cmdCake equ 2
; cmdCheese equ 3
; cmdEnd equ 255

	lda #cmdCake				;Command num
	jsr VectorJump		;Call the vector
	lda #cmdDash
	jsr VectorJump
	
	; ldx #0
; LoopAgain:	
	; txa
	; pha
		; lda CommandList,x	;Read in a command 
		; cmp #255			;End of list?
		; beq done			;Yes? then end!
		; jsr VectorJump		;No? call the command
	; pla
	; tax
	; inx 
	; jmp LoopAgain
; done:
	; jmp *
	
; VectorJump:
	; asl					;Double the passed parameter 
	; tax
	; lda VectorList,x	;Load in Low byte of address
	; sta z_l
	; inx
	; lda VectorList,x	;Load in high byte of address
	; sta z_h	
	; jmp (z_hl)			;Jump to address
	
; TestComand0:			;0: show -
	; lda #'-'
	; jmp printchar
; TestComand1:			;1: newline
	; jmp newline
; TestComand2:			;2: show Cake
	; lda #>txtCake
	; sta z_h
	; lda #<txtCake
	; sta z_l
	; jmp PrintString
; TestComand3:			;2: show Cheese
	; lda #>txtCheese
	; sta z_h
	; lda #<txtCheese
	; sta z_l
	; jmp PrintString
	
; VectorList:				;VectorList - addresses of commands
	; dw TestComand0
	; dw TestComand1
	; dw TestComand2
	; dw TestComand3
	
; txtCake:
	; db 'cake',255		;Test Strings
; txtCheese:
	; db 'cheese',255
	
; CommandList:			;255 terminated command sequence
	; db cmdCake,cmdNewLine,cmdCheese,cmdNewLine,cmdCheese,cmdDash,cmdCake,cmdEnd
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
cmdDash equ 0
cmdNewLine equ 1
cmdCake equ 2
cmdCheese equ 3
cmdEnd equ 255
	lda #2
	jsr VectorJump	
	lda #1
	jsr VectorJump
	
	ldx #0
LoopAgain:	
	stx XRestore_Plus1-1	;Selfmod the X restore
		lda CommandList,x
		cmp #255
		beq done
		jsr VectorJump
	ldx #0			;<-- Selfmod ***
XRestore_Plus1:

	inx 
	jmp LoopAgain
done:
	jmp *
	
VectorJump:
	asl					;Double the passed parameter 
	tax
	lda VectorList,x	;Load in Low byte of address
	sta VectorJumpSelfMod_Plus2-2

	jmp TestComand0		;<-- Selfmod ***
VectorJumpSelfMod_Plus2:
	
	align 8	;Align to byte boundary (8 Bits)
TestComand0:
	lda #'-'
	jmp printchar
TestComand1:
	jmp newline
TestComand2:
	lda #>txtCake
	sta z_h
	lda #<txtCake
	sta z_l
	jmp PrintString
TestComand3:
	lda #>txtCheese
	sta z_h
	lda #<txtCheese
	sta z_l
	jmp PrintString
	
txtCake:
	db 'cake',255
txtCheese:
	db 'cheese',255
	
	
VectorList:
	dw TestComand0
	dw TestComand1
	dw TestComand2
	dw TestComand3

CommandList:
	db cmdCake,cmdNewLine,cmdCheese,cmdNewLine,cmdCheese,cmdDash,cmdCake,cmdEnd
	

	
	
	include "\SrcAll\monitor.asm"			;Debugging tools
	include "\SrcAll\BasicFunctions.asm"	;Basic commands for ASM tasks
	
Bitmapfont:									;Chibiakumas bitmap font
	ifndef BuildVIC
		incbin "\ResALL\Font96.FNT"		;Not used by the VIC due to memory limitations
	endif
	

	include "\SrcALL\V1_Functions.asm"	;Basic text to screen functions
	include "\SrcAll\V1_BitmapMemory.asm"	;Bitmap functions for Bitmap screen systems
	include "\SrcAll\V1_VdpMemory.asm"		;VRAM functions for Tilemap Systems
	include "\SrcALL\V1_Palette.asm"		;Palette functions
	include "\SrcALL\V1_Footer.asm"		;Footer for systems that need it
	
	