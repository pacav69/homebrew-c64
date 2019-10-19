Player_ReadControlsDual:
	;Strobe joysticks to reset them
	ldx #$01				;Send a 1 to joysticks (strobe reset)
	stx $4016				;JOYPAD1 port
	
	dex 					;Send a 0 to joysticks (read data)
	stx $4016				;JOYPAD1 port

	ldx #8					;Read in 8 bits from each joystick
Player_ReadControlsDualloop:
	lda $4016				;JOYPAD1
	lsr 	   				; bit0 -> Carry
	ror z_h  				;Add carry to Joy1 data
  
	lda $4017				;JOYPAD2
	lsr 	   				; bit0 -> Carry
	ror z_l  				;Add carry to Joy2 data
  
	dex 
	bne Player_ReadControlsDualloop
  
	lda z_h
	jsr Player_ReadControlsCorrectOrder
	sta z_h 
	
	lda z_l
	jsr Player_ReadControlsCorrectOrder
	sta z_l 
	rts
    
	;Convert: Right Left Down Up Start Select B A
	;To:	  Start Select B A Right Left Down Up 
Player_ReadControlsCorrectOrder:
	eor #255				;Flip bits so unpressed=1
	jsr SwapNibbles
	rts
	
	
	
; $4016/$4017 - 1=Pressed / 0=NotPressed

; Read  1 - A
; Read  2 - B
; Read  3 - Select
; Read  4 - Start
; Read  5 - Up
; Read  6 - Down
; Read  7 - Left
; Read  8 - Right