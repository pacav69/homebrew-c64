	;We Return ---FRLDU in z_h for Player 0, and z_L for Player 1


	ifdef BuildA80	
Player_ReadControlsDual:
		lda PIA+$0	;22221111 - RLDU in player controls
		and #%00001111	;Bottom Nibble is Player 1 Joystick
		ora #%11100000
		sta z_h

		lda GTIA+$10	;$D010 - TRIG0 - joystick trigger 0
		clc
		rol
		rol
		rol
		rol
		ora z_h			;Joystick 1 Done
		sta z_h			
		
		
	ifdef UseDualJoy 			
		lda GTIA+$11	;$D011 - TRIG1 - joystick trigger 1
		ror 
		php
			lda PIA+$0	;22221111 - RLDU in player controls
			and #%11110000	;Top Nibble is Player 2 Joystick
		plp
		ror
		ror
		ror
		ror
		ora #%11100000
		sta z_l			;Joystick 2 Done
	else
		lda #255		;Disable Joystick 2
	endif
		sta z_l
	rts
	endif
	
	
	ifdef BuildA52		;Atari 5200 doesn't have PIA 
Player_ReadControlsDual:
	lda GTIA+$10		;$C010 - TRIG0 - joystick trigger 0
	sta z_as
	
	lda pokey+0			;$E800 - POT0 - game paddle 0
	jsr Player_ReadControlsProcessAnalog
	
	lda pokey+1			;$E801 - POT1 - game paddle 1
	jsr Player_ReadControlsProcessAnalog
	
	lda #%11100000
	ora z_as
	sta z_h
	
	ifdef UseDualJoy 	
		lda GTIA+$11	;$C011 - TRIG1 - joystick trigger 1
		sta z_as
		
		lda pokey+2		;$E802 - POT2 - game paddle 2
		jsr Player_ReadControlsProcessAnalog
		
		lda pokey+3		;$E803 - POT3 - game paddle 3
		jsr Player_ReadControlsProcessAnalog
		
		lda #%11100000
		ora z_as
	else
		lda #255		;Disable Joystick 2
	endif
	sta z_l
	rts
	
	;Convert Analog to Digital
Player_ReadControlsProcessAnalog:
	cmp #255-64
	bcs Player_ReadControlsProcessHigh
	cmp #64
	bcc Player_ReadControlsProcessLow
	sec
	bcs Player_ReadControlsProcessB
;		rol z_h
;		sec
;		rol z_h
;		rts
Player_ReadControlsProcessHigh:		;U/R
	clc
Player_ReadControlsProcessB:
	rol z_as
	sec
	rol z_as
	rts
Player_ReadControlsProcessLow:		;D/L
	sec
	rol z_as
	clc
	rol z_as
	rts
	endif
	
	
	