	;40 bytes per line = * %00000000 00101000
	;We shift our Ypos 3 to the right, add it, then another 2, eg
	
	;%00000000 00101000
	;%YYYYYYYY 00000000
	;%000YYYYY YYY00000
	;%00000YYYYY YYY000
GetScreenPos:
	txa	
	sta z_e					;Store X pos in E
	
	tya 					;Get Ypos - store in B
	sta z_b				
	lda #0
	sta z_d					;Clear D
	
	clc
	ror z_b					;Shift 3 Bits
	ror 
	ror z_b
	ror 
	ror z_b
	ror 
	tax	
		clc
		adc z_e				;Update Low Byte
		sta z_e
		
		lda z_d				;Update High Byte
		adc z_b
		sta z_d
	txa
	ror z_b					;Shift 2 bits
	ror 
	ror z_b
	ror 
		
	adc z_e					;Update Low Byte
	sta z_e
	
	lda z_b					;Update High Byte
	adc z_d
	sta z_d	
	
	ifdef ScrWid256
		AddPair z_de,$2064	;Add Screen Base
	else
		AddPair z_de,$2060
	endif
	rts
	
GetNextLine:
	AddPair z_de,$0028		;40 Bytes per Y line
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
ScreenInit:		 

		lda     #<dlist;$00     ;Set Display list pointer
        sta     DLISTL
        lda     #>dlist;$10
        sta     DLISTH
		
        lda     #%00100010      ;Enable DMA
		sta     DMACTL
     
	ifdef Mode2Color
Smode Equ $0F				;ANTIC mode F 
	else
Smode Equ $0E				;ANTIC mode E (Screen mode 7.5) 4 color
	endif
	 
		lda     #$EF        ;Set color PF1
		sta COLPF1
		ifdef Mode2Color
			lda #$73        ;2 color mode only uses the brightness of color1
			sta COLPF0
			sta COLPF2
			sta COLBK
		else
			lda #$AF        ;Set color PF0
			sta COLPF0
			lda #$38        ;Set color PF2
			sta COLPF2
			lda #$73        ;Set color PF0
			sta COLBK
		endif
	rts
		
		
