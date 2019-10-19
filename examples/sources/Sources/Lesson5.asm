	include "..\SrcALL\V1_Header.asm"		;Cartridge/Program header - platform specific
	include "\SrcAll\BasicMacros.asm"		;Basic macros for ASM tasks

	SEI						;Stop interrupts
	jsr ScreenInit			;Init the graphics screen
	jsr Cls					;Clear the screen
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 1
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; lda #%10101010		;Set test values
	; jsr MonitorBits		;Show the test pattern
	
	; and #%11110000		;Keep only the top 4 bits 
	; jsr MonitorBits		;Show the result
	
	; jsr newline
	
	; lda #%10101010		;Set test values
	; jsr MonitorBits		;Show the test pattern
	
	; ora #%11110000		;Set the top 4 bits 
	; jsr MonitorBits		;Show the result
	
	; jsr newline
	
	; lda #%10101010		;Set test values
	; jsr MonitorBits		;Show the test pattern
	
	; eor #%11110000		;Flip the top 4 bits
	; jsr MonitorBits		;Show the result
	
	; jsr newline
	
	; jmp *
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; lda #%10111000		;Set test values
	; clc					;Clear the carry
	; ;sec				;Set the carry
	
	; jsr MonitorBitsC	;Show the current state of A+C
	; pha
		; jsr newline
	; pla
	
	; ldx #9				;9= 8 bits + Carry bit
; RolTestAgain:
	; ;rol					;Rotate Left
	; ;ror					;Rotate Right
	; ;asl					;Arithmatic shift Left
	; ;lsr					;Logical Shift Right
	
	; jsr MonitorBitsC	;Show the current state of A+C
	; dex 
	; bne RolTestAgain	;Repeat
	
	; jsr newline
	
	; jmp *
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; lda #%10111000		;Set test values
	; clc					;Clear the carry
	; ;sec				;Set the carry
	
	; jsr MonitorBitsC	;Show the current state of A+C
	; pha
		; jsr newline
	; pla
	
	; ldx #9				;9= 8 bits + Carry bit
; RolTestAgainB:

	; sec			;Set Carry
	; rol			;Rotate Left - set new bits to 1
	; sec			;Set Carry

	; ror			;Rotate Right - set new bits to 1
	
	; pha			;Back up A
		; rol		;Get the Carry 
	; pla			;Restore A
	; rol			;effect Rotate Left without carry
	
	; pha			;Back up A
		; ror		;Get the Carry 
	; pla			;Restore A
	; ror			;effect Rotate Right without carry
	
	; jsr MonitorBitsC	;Show the current state of A+C
	; dex 
	; bne RolTestAgainB	;Repeat
	
	; jsr newline
	
	; jmp *

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Again:
	; ldx 255
; pauseagain:
	; nop
	; nop
	; nop
	; nop
	; dex
	; bne pauseagain
	; lda #'A'
	; jsr printchar 
	; jmp Again
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	lda #%10010101		;95 in hex
	bit TBit1			;Test a bit
	bne BitA			;Branch if 1
	
	jsr printhex		;Prove A was unchanged
	jsr newline
	
	lda #'B'
	jsr printchar		;Show an B if bit was 0
	jmp *
	
BitA
	jsr printhex		;Prove A was unchanged
	jsr newline
	
	lda #'A'
	jsr printchar		;Show an A if bit was 1
	jmp *
	
	
TBit0: 	db %00000001	;Define a byte in binary
TBit1:	db %00000010
TBit2:	db %00000100
TBit3:	db %00001000
TBit4:	db %00010000
TBit5:	db %00100000
TBit6:	db %01000000
TBit7:	db %10000000	

	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
MonitorBitsC:
	sta z_as
	php
	php
	pla
	sta z_h
	lda z_as
		pushall
			lda z_h
			ror
			bcs MonitorBitsOneB
	
			lda #'0'
			jmp MonitorBitsDoneB
MonitorBitsOneB:

			lda #'1'
MonitorBitsDoneB:	
			jsr PrintChar
			lda #' '
			jsr PrintChar
		pullall
		
	
		jsr MonitorBits
	plp
	rts
	
MonitorBits:
	sta z_as
	pushall
	ldx #8
	lda z_as
MonitorBitsAgain:
	rol 
	bcs MonitorBitsOne
	pha
		lda #'0'
	jmp MonitorBitsDone
MonitorBitsOne:
		pha
		lda #'1'
MonitorBitsDone:	
		jsr PrintChar
		pla
	dex 
	bne MonitorBitsAgain
	jsr newline
	pullall
	rts

	; ldx #$FF				;Set Stack Pointer to $01FF
	; txs
	
	; lda #$77				;Set AXY to test values
	; ldx #$66
	; ldy #$55
	; pha						;Push A onto the stack
		; txa					;Transfer X to A and push
		; pha
			; tya				;Transfer Y to A and push
			; pha	
				; jsr MemDump	;Show the Stack      			
				; word $01F0	;We should see pushed AXY
				; byte $2        		
				
				; lda #0		;Clear XYA
				; tax
				; tay
			; pla				;Pull A and move to Y
			; tay
		; pla					;Pull A and move to X
		; tax
	; pla						;Pull A
	; jsr monitor				;Show Registers
	; jmp *					;Infinite Loop

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 2
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ldx #$FF				;Set Stack Pointer to $01FF
	; txs
	; jsr monitor
	; php						;Push flags onto the stack
		; jsr SubTest
	; plp						;Pull flags from the stack
	; jmp *					;Infinite Loop
	
; SubTest:
	; pha
		; jsr MemDump	;Show the Stack      			
		; word $01F0	;We should see pushed AXY
		; byte $2        		
	; pla
	; rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; lda #-1
	; sta z_h
	; jsr monitor			;-1 is the SAME thing as 254
	; jsr newline
	
	; lda #100			;Set A to 100
	; jsr monitor
	; clc
	; adc z_h				;Add -1
	; jsr monitor			;Result is 99
	; jsr newline
	
	; lda #100			;Set A to 100
	; jsr monitor
	; clc
	; adc #255			;Add 254
	; jsr monitor			;Result is 99 - see! 255/-1 are the SAME thing!
	; jsr newline
	
	; lda #1				;Set A to 1
	; jsr monitor
	; eor #%11111111		;To convert pos to neg, flip the bits, and add 1
	; clc
	; adc #1
	; jsr monitor

	; jmp *					;Infinite Loop


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;TestSymbol equ 1

	; lda #1
	; ifdef TestSymbol
		; clc 				;If TestSymbol is defined we add 1
		; adc #1
	; endif
	; ifndef TestSymbol
		; eor #%11111111		;If testsymbol isn't defined we flip the bits
	; endif
	; jsr Monitor
	
	
	; jmp *					;Infinite Loop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 3
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	; ldx #3					;Set X to 3
; DecTestAgain:
	; dex						;Decrease X by one
	; cpx #2					;See if X is 2
	; bne TestDone			;If it's NOT, skip the next command
	; jsr monitor				;Call the monitor - effectively this happens if X=2
; TestDone:	
	; bne DecTestAgain  		;Jump back until Zero flag is set
	; jmp *					;Infinite Loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 4
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	; ldx #3
	; lda #10
	; jsr Monitor
	; jsr Multiply			;Multiply 10 by 3
	; jsr Monitor
	; jsr newline
	
	; ldx #10
	; lda #31
	; jsr Monitor
	; jsr Divide				;Divide 31 by 10
	; jsr Monitor
	
	; jmp *					;Infinite Loop
; Multiply:
	; sta z_h					;Value to multiply by
	; lda #0
; MultiplyAgain:
	; clc 
	; adc z_h					;add again
	; dex						;Decrease counter
	; bne MultiplyAgain
	; rts

; Divide:
	; stx z_h					;divisor
	; ldx #0					;Set count to zero
; DivideAgain:	
	; sec
	; sbc z_h					;Subtract one of divisor
	; bcc DivideDone			;Have we gone below zero?
	; inx 					;Add 1 to count of sucessfull subs
	; jmp DivideAgain
; DivideDone:
	; clc
	; adc z_h					;We've gone below zero - so fix that!
	; rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 5
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	lda #>$1024			;Store the top byte (>) of $1024 in A
	sta z_h				;Store to zeropage
	jsr printhex2		
	lda #<$1024			;Store the bottom byte (<) of $1024 in A
	sta z_l
	jsr printhex2
	jsr newline
	
	lda #>$333			;Store the top byte (>) of $333 in A
	sta z_d				;Store to zeropage
	jsr printhex2		
	lda #<$333			;Store the bottom byte (<) of $333 in A
	sta z_e
	jsr printhex2
	jsr newline
	
;	jsr AddHL_DE		;Add DE to HL
	jsr SubHL_DE		;Subtract DE from HL
	
	lda z_h				;Show the result
	jsr printhex2		
	lda z_l
	jsr printhex2
	jsr newline
	jmp *

	
	
printhex2:
	sta z_as
	pushpair z_hl
	pushpair z_de
		lda z_as
		jsr PrintHex
	pullpair z_de
	pullpair z_hl
	rts


	
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
	
	