Player_ReadControlsDual:
	;R:      3210
	;W:		   CS			C=Clear S=Select key/dir
	
	;Reset the Multitap... following reads will read in 
		;from joysticks 1-5
	ldx #%00000001			;Reset Multitap 1
	jsr JoypadSendCommand
	ldx #%00000011			;Reset Multitap 2
	jsr JoypadSendCommand

	jsr Player_ReadControlsOne	;Read Pad 1
	sta z_h
	
								;Read Pad 2
Player_ReadControlsOne:	
	ldx #%00000001				
	jsr JoypadSendCommand	;----LDRU (Left/Down/Right/Up)
	jsr JoypadShiftFourBitsA
	dex
	jsr JoypadSendCommand	;---RSBA (Run/Start/B/A)
	jsr JoypadShiftFourBits
	lda z_as
	sta z_l
	rts
	
JoypadShiftFourBitsA:		;Swap LDRU to RLDU
	ror						;Up
	ror z_as		
	ror						;Right (for later)
	ror z_l			
	ror						;Down
	ror z_as
	ror						;Left
	ror z_as
	rol z_l					;Right
	ror z_as
	rts	

JoypadShiftFourBits:		;Shift RSBA in to z_as
	ldx #4
JoypadShiftFourBitsB:
	ror
	ror z_as
	dex
	bne JoypadShiftFourBitsB
	rts
	
JoypadSendCommand:
	stx $1000			;Set option from X
	
	PHA 				;Delay
	PLA 
	NOP 
	NOP
	
	lda $1000			;Load result
	rts