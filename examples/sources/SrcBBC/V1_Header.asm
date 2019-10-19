z_Regs 		equ $20
Cursor_X 	equ $40
Cursor_Y 	equ Cursor_X+1

SPpage equ $0100
	ifndef RunLocation
RunLocation equ $0200
	endif
;RunLocation equ $1000		;Use 1000 if you need firmware!

	ORG RunLocation  ;Actually our code runs at &3000 - but we shift it to here
BBCFirstByte:
	SEI			;Stop interrupts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	;&43 = Data Dir Reg A
	;&40 = I/O Reg B &40
	;&41 = I/O Reg A &41
	lda 255		;Set all bits to write
	sta $FE43 ; Data direction port
	
	;	  1CCOVVVV = CC=channel O=operation (1=volume) V=Value (Volume 15=off)
	lda #%10011111	;Turn off channel 0
	sta $FE41
		
	    ; ----BAAA   =A=address (0=sound chip, 3=Keyboard) B=new setting for address AAA
	lda #%00001000		;Send data to Sound Chip
	sta $FE40			
	lda #%00000000		;Stop sending data to sound chip
	sta $FE40
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
	lda #0
	sta z_c
	sta z_l
	sta z_e
	
	lda #$30
	sta z_h
	
	
	lda #>(BBCLastByte-BBCFirstByte+256)
	
	sta z_b
	
	lda #>RunLocation
	sta z_d
	
BBCLDIR:	
		ldy #0
        lda (z_HL),Y
        sta (z_DE),Y
	
		INC z_L
		BNE	BBCLDIR_SkipInc1
		INC	z_H
BBCLDIR_SkipInc1:
		INC z_E
		BNE	BBCLDIR_SkipInc2
		INC	z_D
BBCLDIR_SkipInc2:

		DEC z_C
		BNE BBCLDIR
		LDA z_B
		BEQ	BBCLDIR_Done
		DEC z_B
		sec
		bcs BBCLDIR
BBCLDIR_Done:
		jmp start
start

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

; we've Shifted our ram from the default &3000 to &1000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
