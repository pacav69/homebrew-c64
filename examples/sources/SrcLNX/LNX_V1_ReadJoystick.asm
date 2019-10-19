Player_ReadControlsDual:
	lda #$FF
	sta z_h			;Player 1 
	sta z_l			;Player 2 - Only one pad so disabled
	
	eor $FCB0		;JOYSTICK	Read Joystick and Switches	UDLR12IO
			;(I= Inside Fire, O=Outside Fire, 1=Option 1, 2=Option 2)
			
	;FCB1 = Pause button on bit 0
			
	jsr SwapNibbles	; swap UDLR12IO to 12IOUDLR	
	tay				;Back up for later

	ldx #4
JoystickNextBitsB:	;shift 12IOUDLR into ---RLDU
	ror
	rol z_h			;Flip the order of the bits
	dex
	bne JoystickNextBitsB
	
	tya				;Get back backup 12IOUDLR
	ora #%00001111	;Get Fires 12IO---
	and z_h			;Or in ---RLDU
	sta z_h
	rts
	
	