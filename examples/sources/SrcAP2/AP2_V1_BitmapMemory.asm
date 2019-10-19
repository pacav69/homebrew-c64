
GetScreenPos:

		lda #0
		sta z_e
		tya
		and #%11111000
		clc
		ROR
		ROR
		ROR
		and #%00000111
		clc
		ROR
		ROR z_e
		adc #$40
		sta z_d
		
		tya
		and #%11111000
		clc
		ROR
		ROR
		ROR
		and #%11111000
		cmp #8
		bcc GetScreenPos_FirstThird
		cmp #16
		bcc GetScreenPos_SecondThird
		lda z_e
		clc
		adc #$50
		jmp GetScreenPos_ThirdDone
GetScreenPos_SecondThird:
		lda z_e
		clc
		adc #$28
		jmp GetScreenPos_ThirdDone
GetScreenPos_FirstThird:	
		lda z_e
		clc
GetScreenPos_ThirdDone:	
		sta z_e
		txa
		ifdef ScrWid256
			adc #4
		endif
		clc
		adc z_e
		sta z_e
	rts
	
GetNextLine:
		lda z_d
		clc
		adc #$04
		sta z_d
	rts