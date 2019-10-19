		macro s_mov_a_ii,aval		;Set A=immidiate value
			db $E8
			db \aval
		endm
		macro s_mov_x_ii,aval		;Set X=immidiate value
			db $CD
			db \aval
		endm
		macro s_mov_a_addr,aval   	;load A from addr(16bit)
			db $E5
			dw \aval
		endm
		macro s_mov_sp_x			;Set SP=X
			db $BD
		endm
		macro s_mov_addr_a,aval   	;store A in addr(16bit)
			db $C5
			dw \aval
		endm
		
		macro s_inc_a  				;store A in addr(16bit)
			db $bc
		endm
		
		macro s_bra_r,aval   		;branch to relative address
			db $2F
			db \aval
		endm
		
		macro s_beq_r,aval   		;branch to relative address if equal
			db $F0
			db \aval
		endm
		macro s_bne_r,aval   		;branch to relative address if notequal
			db $D0
			db \aval
		endm
		macro s_bcc_r,aval  		 ;branch to relative address if carry clear
			db $90
			db \aval
		endm
		macro s_bcs_r,aval   		;branch to relative address if carry seet
			db $B0
			db \aval
		endm
		
		macro s_cmp_a_ii,aval   	;Compare A with an immediate value
			db $68
			db \aval
		endm
		macro s_cmp_a_addr,aval   	;Compare A with an (addr)
			db $65
			dw \aval
		endm
		
		macro s_call_addr,aval  	;Call sub at (addr)
			db $3F
			dw \aval
		endm
		
		macro s_jmp_addr,aval   	;Call sub at (addr)
			db $5F
			dw \aval
		endm
		
		macro s_ret  				;Compare A with an (addr)
			db $6f
		endm
		
		macro s_nop					;Do nothing
			db $00
		endm
