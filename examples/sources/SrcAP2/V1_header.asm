	ORG $0C00;-128
	;db $0a
	;db $47
	;db $4C
	;db $E3	;Access code
	;db $04	;File type
	;dw $4000	;Aux type (load address)
	;db $1 ;storage type
	;dw 1	;Size of file
	;dw $0000 ;Date of modification
	;dw $0000 ;Time of modification
	;dw $0000 ;Date of Creation
	;dw $0000 ;Time of Creation
;	db $2	;ID
	;db $0	;reserved
	
z_Regs 		equ $20
Cursor_X 	equ $40
Cursor_Y 	equ Cursor_X+1

SPpage 		equ $0100
ProgramStart:
	