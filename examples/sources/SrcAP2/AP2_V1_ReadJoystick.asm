Player_ReadControlsDual:
	ldx #$64			;AnalogAxis Base addr
	
	lda $C061			;Fire 1
	jsr ProcessJoystick
	sta z_h
	
	
	ifdef UseDualJoy 
		ldx #$66		;AnalogAxis Base addr
		lda $C062		;Fire 2
		jsr ProcessJoystick
	else
		lda #255
	endif
	sta z_l
	rts

ProcessJoystick:
	;Apple Joysticks are annoying!
	;they are analog... we have to strobe the port 
	;then read from the X and Y ports, and count up until the top bit changes
	;this is a 'timer'...using just 1 bit (the top one) it effectively returns an 'analog' value from about 0-100
	
	rol					;Move in the fire button
	rol z_as
	
	ifdef UseDualJoy 					;Selfmod to covert code for second joystick
		stx JoySelfModAA_Plus2-2
		inx
		stx JoySelfModB_Plus2-2			;2nd port
		stx JoySelfModBB_Plus2-2
	endif
	
	lda $C070	;Strobe Joypads
	
	ldy #0
	ldx #0 
	
Joy_ReadAgain:
	pha
	pla					;delay
Joy_gotPDL1:			;Jump backhere when we get X
Joy_ChkPDl0:
	lda	$C064 			;<--SM ***   Y
JoySelfModAA_Plus2:
	bpl Joy_gotPDL0		;Have we got Y?
	nop
	iny	
	lda $C065			;<--SM ***   X
JoySelfModB_Plus2:
	bmi Joy_nogots		;Have we got X?
	bpl Joy_gotPDL1
Joy_nogots:
	inx
	jmp Joy_ChkPdl0
Joy_gotPDL0:			;We've Got Tpos - just waiting for X
	lda  $C065			;<--SM ***   X
JoySelfModBB_Plus2:
	bmi Joy_Nogots
	
	tya
	jsr JoyConvertAnalog;Convert Y
	txa
	jsr JoyConvertAnalog;Convert X
	lda z_as
	eor #%11111111		;Flip bits
	ora #%11100000		;Set unused bits
	rts	
	
JoyConvertAnalog:	;covert analog from 0-100 into L/R or U/D
	cmp #$66
	bcs Joy_Rbit
	cmp #$33
	bcc Joy_Lbit
	clc 
	bcc Joy_Cbit
Joy_Rbit:
	sec 
	;rol z_as
	;clc
	;rol z_as
;	rts
Joy_Cbit:
	rol z_as
	clc
	rol z_as
	rts
	
	
	
	
Joy_Lbit:
	;lda #%00000010
	clc
	rol z_as
	sec 
	rol z_as
	rts

	
;C060 49248 BUTN3           G  R7  Switch Input 3
;C061 49249 RDBTN0        ECG  R7  Switch Input 0 / Open Apple
;C062 49250 BUTN1         E G  R7  Switch Input 1 / Solid Apple
;C063 49251 RD63          E G  R7  Switch Input 2 / Shift Key
                          ;C   R7  Bit 7 = Mouse Button Not Pressed
;C064 49252 PADDL0       OECG  R7  Analog Input 0
;C065 49253 PADDL1       OECG  R7  Analog Input 1
;C066 49254 PADDL2       OE G  R7  Analog Input 2
           ;RDMOUX1        C   R7  Mouse Horiz Position
;C067 49255 PADDL3       OE G  R7  Analog Input 3
           ;RDMOUY1        C   R7  Mouse Vert Position
