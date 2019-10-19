Player_ReadControlsDual:
	lda #0					;Set port to read (For fire button)
	STA $FE43				;SN76489 - Data Direction
	sta z_as
	
	lda #%00000000			;Get Channel 0 - Joy 1 LR
	jsr Player_ReadControlsGetData
	lda #%00000001			;Get Channel 1 - Joy 1 UD
	jsr Player_ReadControlsGetData
		
	lda $FE40
	and #%00010000			;Get the fire button 1 (PB4 / PB5)
	ora z_as
	eor #%11101111
	sta z_h
		
	ifdef UseDualJoy 		
		lda #0				;Set port to read (For fire button)
		sta z_as
		
		lda #%00000010		;Get Channel 2 - Joy 2 LR
		jsr Player_ReadControlsGetData
		lda #%00000011		;Get Channel 3 - Joy 2 UD
		jsr Player_ReadControlsGetData
		
		lda $FE40
		and #%00100000		;Get the fire button 2 (PB4 / PB5)
		lsr
		ora z_as
		eor #%11101111		;Flip all bits except Fire
	else
		lda #255			;Disable Fire 2
	endif
	sta z_l
	rts
	
	;See page 429 of the 'BBC Microcomputer Advanced user Guide' 
	
Player_ReadControlsGetData:	;We need to convert analog to digital
	sta $FEC0						;Select channel
Player_ReadControlsDualWait:
	lda $FEC0						;Get Data
	and #%10000000
	bne Player_ReadControlsDualWait	;0= data ready
	
	lda $FEC1						;8 bit analog data
	cmp #255-32
	bcs Player_ReadControlsDualHigh
	cmp #32				
	bcc Player_ReadControlsDualLow 	;Centered
	clc
	bcc Player_ReadControlsDualB	;efective branch always
;	rol z_as
;	clc
;	rol z_as
;	rts
	
Player_ReadControlsDualLow:		;L/D
	sec
Player_ReadControlsDualB:
	rol z_as
	clc
	rol z_as
	rts
Player_ReadControlsDualHigh:	;U/R
	clc
	rol z_as
	sec
	rol z_as
	rts

	