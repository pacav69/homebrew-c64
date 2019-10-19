SetPalette:				;-GRB
	sta z_as
	pushall
		lda z_as		;Store Palette number in Y
		tay
	
		lda #>$FDA0		;Dest Addr $FD--
		sta z_B		
		lda #<$FDA0		;Dest Addr $--A0
		sta z_C		
			
		lda z_h			
		sta (z_BC),y	;Write: ----GGGGG
		
		lda #<$FDB0 	;Dest Addr $--B0
		sta z_C
			
		lda z_l			;Source RRRRBBBB
		jsr SwapNibbles
		sta (z_BC),y	;Write: BBBBRRRR
	pullall
	rts 
	
	