
z_Regs equ $20
Cursor_X 	equ $40
Cursor_Y 	equ Cursor_X+1
SPpage equ $0100
	ifndef BuildVIC_ROM
		;;;db $01, $10
* = $1001
		; BASIC program to boot the machine language code
		db $0b, $10, $0a, $00, $9e, $34, $31, $30, $39, $00, $00, $00
	else
* = $A000
		dw ProgramStart
		dw ProgramStart
		db $41,$30,$C3,$C2,$CD		;ROM Header
ProgramStart:
	endif