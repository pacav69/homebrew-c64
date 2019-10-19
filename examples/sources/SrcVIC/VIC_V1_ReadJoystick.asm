Player_ReadControlsDual:
	
	lda #%01111111
	sta $9122	;Set Data Direction of port B to READ (0=read)
	
;	lda #%11000011
;	sta $9113	;Set Data Direction of port A to READ (0=read)
	
	lda $9120	;Port B (R------- Switch)
	sta z_as
	
	lda #255	;Set all buttons to unpressed
	sta z_l
	sta z_h
	
	lda $911F	;Port A (--FLDU-- Switches)
	rol
	rol
	rol
	rol z_h		;Shift in Fire
	rol z_as		
	rol z_h		;Shift in Right
	rol
	rol z_h		;Shift in Left
	rol
	rol z_h		;Shift in Down
	rol
	rol z_h		;Shift in Up
	
	
	;lda #255
	;sta $9122	;Reset port B (for Keyb col scan)
	
	rts
	
	