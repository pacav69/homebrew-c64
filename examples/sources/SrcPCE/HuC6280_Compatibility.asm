	; macro bsr,setting
		; db $44,\setting
	; endm
	
	; macro clx
		; db $82
	; endm
	; macro cly
		; db $C2
	; endm
	
	;macro sta_00,address		;The HU Zero page is in the wrong place!
		;db $8d,\address,$00
	;endm
	
	; macro csh
		; db $d4
	; endm
	; macro csl
		; db $54
	; endm

	; macro sax
		; db $22
	; endm
	; macro say
		; db $42
	; endm
	; macro set
		; db $f4
	; endm
	
	; macro st0,setting
		; db $03,\setting
	; endm
	; macro st1,setting
		; db $13,\setting
	; endm
	; macro st2,setting
		; db $23,\setting
	; endm
	
	; macro sxy
		; db $02
	; endm
	
	; macro tam,setting
		; db $53,\setting
	; endm
	
	;macro tam_0
		;db $53,1
	;endm
	;macro tam_1
		;db $53,2
	;endm
	;macro tam_2
		;db $53,4
	;endm
	;macro tam_3
		;db $53,8
	;endm
	;macro tam_4
		;db $53,16
	;endm
	;macro tam_5
		;db $53,32
	;endm
	;macro tam_6
		;db $53,64
	;endm
	;macro tam_7
		;db $53,128
	;endm