	setdp $2000				;Define the direct page as #$2000

z_Regs 		equ $60			;Fake Registers

Cursor_L 	equ $40			;Used for Printchar
Cursor_H 	equ Cursor_L+1

RPage equ $2000				;Ram is at $2000
HPage equ $0000				;Hardware regs at $0000

UserRam equ $2200

SPpage equ $2100
ZPpage equ $0000

	org $e000		;bank $0
PCE_Start:
	sei				;Disable interrupts
	csh				;Highspeed Mode
	cld				;Clear Decimal mode
	
	lda #$ff		;map in I/O
	tam #%00000001	;TAM0 (0000-1FFF)
	
	lda #$f8		;map in RAM
	tam #%00000010	;TAM1 (2000-3FFF)

	ldx #$ff		;Init stack pointer
	txs
	
	lda #$07
	sta HPage+$1402	;IRQ mask, INTS OFF


	
	
	