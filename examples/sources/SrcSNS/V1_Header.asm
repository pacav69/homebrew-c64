
z_Regs 		equ $20
Cursor_X 	equ $40
Cursor_Y 	equ Cursor_X+1
  
sppage equ $0100
	
UserRam equ $0200
	
	org $8000		;Start of ROM
	
	lda #$40		;RTI
	sta $0000		;Don't know if this helps!