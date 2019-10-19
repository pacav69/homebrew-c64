		
		
ChibiSound:
	;we use to ports $FE43 to set the data direction, and $FF41 to send the data

	pha				
		lda 255		;Set all bits to write (1)
		sta $FE43   ;of the Data direction port
	pla
	beq silent
	tax
		 ;1CCTLLLL	(Latch - Channel Type DataL)
	lda #%11001111	
	sta $FE41		;Tone L
	txa
	and #%00111111
	sta $FE41 		;Tone H

	txa 
	and #%01000000	;Volume
	asl
	adc #$80
	rol
	asl
	adc #$80
	rol
	tay
	eor #%11010100
	sta $FE41 		;Tone Volume

	lda #%11111111	;Mute Noise
	sta $FE41 ;

	txa
	and #%10000000
	beq ChibiSoundFinish		;No Noise?
		 ;1CCTVVVV	(Latch - Channel Type Volume)	
	lda #%11011111	;Mute tone
	sta $FE41
	
		 ;1CCT-MRRr	(Latch - Channel Type... noise Mode (1=white) Rate (Rate 11= use Tone Channel 2)
	lda #%11100111	;Link to channel 2
	sta $FE41 
	tya
	eor #%11110100	;1CCTVVVV	(Latch - Channel Type Volume)	
	sta $FE41 ;out (&7F),a

ChibiSoundFinish:
		
		lda #%00001000		;Send data to Sound Chip
		sta $FE40	
		lda #%00000000		;Stop sending data to sound chip
		sta $FE40		
	rts
silent:				;Mute Tone and Noise (Vol 15=silent)
		 ;1CCTVVVV	(Latch - Channel Type Volume)	
	lda #%11111111	
	sta $FE41 
	lda #%11011111	
	sta $FE41 
	rts
