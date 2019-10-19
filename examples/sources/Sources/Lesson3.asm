	include "..\SrcALL\V1_Header.asm"		;Cartridge/Program header - platform specific
	include "\SrcAll\BasicMacros.asm"		;Basic macros for ASM tasks

	SEI						;Stop interrupts
	jsr ScreenInit			;Init the graphics screen
	jsr Cls			;Clear the screen

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; lda #$69				;Load hex 69 into A
	; tax						;Copy A to X
	; tay						;Copy A to Y
	; sta $01					;Store to the $01 in the Zeropage
	; jsr monitor
	; dey						;Decrease Y by 1
	; inx						;Increase X by 1
	; clc						;Fake INCA - Clear Carry
	; adc #1					;Fake INCA - Add 1
	; jsr monitor
	; dex						;Decrease X by 1
	; iny						;Increase Y by 1
	; sec						;Fake DECA - Clear Carry
	; sbc #1					;Fake DECA - Add 1
	; jsr monitor
	
	; jsr MemDump
    ; word $0      			
    ; byte $1          		
	; inc $01					;Increase Zeropage $01
	; jsr MemDump
    ; word $0      			
    ; byte $1          		
	; dec $01					;Decrease Zeropage $01
	; jsr MemDump
    ; word $0      			
    ; byte $1          		
	
	 ; jmp *					;Infinite Loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; ldx #3					;Set X to 3
; DecTestAgain:
	; jsr monitor
	; dex						;Decrease X by one
	; bne DecTestAgain  		;Jump back until Zero flag is set
	; jmp *					;Infinite Loop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; ldx #3					;Set X to 3
; DecTestAgain:
	; cpx #2					;See if X is 2
	; beq TestDone			;If it's NOT, skip the next command
	; jsr monitor				;Call the monitor - effectively this happens if X=2
; TestDone:	
	; dex						;Decrease X by one
	; bne DecTestAgain  		;Jump back until Zero flag is set
	; jmp *					;Infinite Loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; lda #4					;Set X to 3	
	; cmp #5
	; bcc wrong				;A >= CMP
	; jsr monitor
; wrong:
	
	
	; ;bcc Jumped				;A < CMP
	
	; ; lda #3					;Set X to 3	
	; ; beq Jumped				;A=0
	; ; bne Jumped				;A!=0
	
	; ; lda #-1						;-1=255 -128=128
	; ; bpl Jumped				;A<128
	; ; bmi	Jumped				;A>=128
	; jmp *					;Infinite Loop
; Jumped:
	; jsr monitor
	; jmp *					;Infinite Loop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ldx #4
CaseAgain
	cpx #3
	beq Case3
	cpx #2
	beq Case2
	cpx #1
	beq Case1
	cpx #0
	beq Case0
CaseDone
	dex
	jmp CaseAgain
	
Case3:
	lda #"C"
	jsr PrintChar
	jmp CaseDone
Case2:
	lda #"B"
	jsr PrintChar
	jmp CaseDone	
Case1:
	lda #"A"
	jsr PrintChar
	jmp CaseDone
Case0:
	jmp *
	
	
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
	
	
