	include "..\SrcALL\V1_Header.asm"		;Cartridge/Program header - platform specific
	include "\SrcAll\BasicMacros.asm"		;Basic macros for ASM tasks

	SEI						;Stop interrupts
	jsr ScreenInit			;Init the graphics screen
	jsr Cls					;Clear the screen
		
;Example 1 - 65c02 commands
	; ldx #1
	; ldy #2
	; lda #0
	
	; jsr monitor 		;Show registers to screen
	
	; dec 			;Dec A
	; inc				;Inc A
	; inc				;Inc A
	
	; phx				;Push X
	; phy				;Push Y
	; plx				;Pull X
	; ply				;Pull Y
	
	; jsr monitor 		;Show registers to screen
	
	; bra GoHere			;Branch always (relative jump)
; GoHere:	

	; lda #$FF
	; sta $01
	 ; jsr MemDump		;Dump an address to screen
		; dw $0000      	;Address to show
		; db $1           ;Lines to show
		
	; stz $01
	; jsr MemDump		;Dump an address to screen
		; dw $0000      	;Address to show
		; db $1           ;Lines to show
	
	; jmp *				;Infinite Loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example 2
	; lda #$33			;Store some test data into ram
	; sta $2000
	; sta $2001

	; lda #$00			;map in CART ROM
	; tam #%00000100		;MPR2 (4000-5FFF)
	
	 ; jsr MemDump		;Dump an address to screen
		; dw $4000      	;Address to show
		; db $3           ;Lines to show
		
	; lda #$F8			;map in RAM
	; tam #%00000100		;MPR2 (4000-5FFF)	
		
	 ; jsr MemDump		;Dump an address to screen
		; dw $4000      	;Address to show
		; db $3          	;Lines to show
	; lda #0
	; tma #%00000100		;MPR2 (4000-5FFF)	
	; jsr monitor 		;Show registers to screen
	; jmp *				;Infinite Loop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Example 3
	; st0 #0		;Reg Select (0=Address select)
	; st1 #$00	;Address L
	; st2 #$00	;Address H

	; st0 #2		;Reg Select (2=data write)
	; St1 #1		;Data L: Tile number
	; st2 #1		;Data H: Skip the first 256 'tiles' as 
					; ;these overlap the tilemap in VRAM

	; St1 #2		;Draw a second tile to the right (address autoincs)
	; st2 #1		

	; st0 #0		
	; st1 #32		;one line down
	; st2 #$00	
	
	; st0 #2		
	; st1 #3		;Draw a third tile below
	; st2 #1		

	; lda #$ff			;map in I/O
	; tam #%00000100		;TAM0 (4000-5FFF)
	
	; ;instead of ST0 we can write to $[io]00, ST1 = $[io]02, ST2 = $[io]03
	; ;all these repeat throughout the IO range
	
	; lda #0		;Reg Select (0=Address select)
	; sta $4100
	; lda #64		;Address L
	; sta $4102
	; lda #$00	;Address H
	; sta $4103
	
	; lda #2		;Reg Select (2=data write)
	; sta $4100
	; lda #4		;Data L: Tile number
	; sta $4102
	; lda #1		;Data H: Skip the first 256 'tiles' as 
					; ;these overlap the tilemap in VRAM
	; sta $4103
	
	; jmp *				;Infinite Loop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;Example 4
	; lda #1
	; ldx #2
	; ldy #3
	; jsr monitor			
	; sxy					;Swap X and Y
	; jsr monitor			
	; sax					;Swap A and X
	; jsr monitor			
	; say					;Swap A and Y
	; jsr monitor			
	; clx					;Clear X
	; cly					;Clear Y
	; jsr monitor			
	; jmp *				
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Example 5
	; csl					;Lowspeed mode (1.78 MHz)
	; bsr SpeedTest		;Branch Subroutine (Relative call)
	
	; jsr newline
	; jsr newline
	
	; csh					;Higspeed mode (7.16 MHz)
	; bsr SpeedTest
	; jmp *				;Infinite Loop
	
; SpeedTest:				;Print 16 A's to screen with a delay
	; ldx #16
; SpeedTestAgain:
	; lda #'a'
	; jsr printchar
	; loadpair z_bc,$4FFF	
	; jsr Pause
	; dex
	; bne SpeedTestAgain
	; rts
; Pause:					;Pause for BC ticks
	; jsr decbc
	; lda z_b
	; ora z_c
	; bne Pause		
	; rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;Example 6

	; lda #$60
	; sta $0
	; jsr MemDump		
		; dw $2000     
		; db $1       
	
	; ldx #0			;X= Zero Page $00
	; lda #0
	
	; jsr Monitor
	; jsr newline
	
	; clc
	; set		;Set T flag - next accumulator command will affect Zeropage X (0)
	; adc #1	;	(works on ADC, AND, EOR, ORA,SBC)
	; adc #2
	
	; inx 
	; set		;Set T flag - next accumulator command will affect Zeropage X (1)
	; adc #3	;	(works on ADC, AND, EOR, ORA,SBC)
	
	; jsr MemDump		
		; dw $2000  
		; db $1         
	
	; jsr Monitor

	; jmp *					;Infinite Loop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;Example 7
; Again:	
	; jsr MemDump		
		; dw $2000      
		; db $2          
	
	; tii SomeData,$2000,8	;Copy 8 bytes from Somedata to $2000
	
	; jsr MemDump		
		; dw $2000      
		; db $2         
	
	; tdd BlankData+7,$2000+7,8	;Copy empty bytes backwards
	
	; jsr MemDump		
		; dw $2000      
		; db $2         
	
	; tin SomeData,$2000,8	;Copy bytes to a single destination 
							;;(for streaming data to hardware)
	; jsr MemDump		
		; dw $2000      	
		; db $2          
		
	; tdd BlankData+7,$2000+7,8	;Clear data
	
	; tia SomeData,$2000,8	;Copy bytes to a pair of destinations 
							;;This is for writing bulk data to the
	; jsr MemDump				;	 HL video data ports
		; dw $2000      
		; db $2        
	; jmp *

; SomeData:	
	; db $11,$22,$33,$44,$55,$66,$77,$88
	
; BlankData:	
	; db $10,$00,$00,$00,$00,$00,$00,$01
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Example 8

	jsr MemDump		
		dw $2000      
		db $1          	
	
	stz $00			;Set Zeropage $00 to 0
	
	smb 0,$01		;Set Memory Bit 0 of $01
	smb 1,$02		;Set Memory Bit 1 of $02
	smb 2,$03			
	smb 3,$03		;Set Memory Bit 2+3 of $03
	
	jsr MemDump		
		dw $2000
		db $1   
		
	rmb 0,$01		;Reset Memory bit 0 of $01
	rmb 1,$02		;Reset Memory bit 1 of $02
	rmb 2,$03
	
	jsr MemDump		
		dw $2000    
		db $1       
	jsr NewLine
	
	jsr ShowBit
	smb 0,$00		;Set Memory Bit 0 of $0
	jsr ShowBit
	jsr Newline
	
	lda #$80
	tsb $00			;Test and Set it 7 of Zeropage $00
	
	jsr MemDump	
		dw $2000
		db $1   
	
	lda #$80
	trb $00			;Test and Reset Bit 7 of zeropage $00
	
	jsr MemDump		
		dw $2000    
		db $1       

	lda #$80
	sta $00			;Store $80 to Zeropage $00
	
	tst #$80,$00	;Test bit 7 of zero page $00
	bne Done4
		lda #'0'
		jsr PrintChar
Done4:
	jsr NewLine
	
	tst #$01,$00 	;Test bit 1 of zero page $00
	bne Done5
		lda #'0'
		jsr PrintChar
Done5:
	jsr NewLine

	jsr MemDump		
		dw $2000    
		db $1       
	jmp *
ShowBit:
Done1:	
	bbs 0,$00,Done2	;Branch if bit 0 of Zeropage $00 is set
		lda #'0'
		jsr PrintChar
Done2:	
	bbr 0,$00,Done3	;Branch if bit 0 of Zeropage $00 is reset
		lda #'1'
		jsr PrintChar
Done3:	
	jsr Newline
	rts
	
	
	
	
	
	
	
	
	
	
	include "\SrcAll\monitor.asm"			;Debugging tools
	include "\SrcAll\BasicFunctions.asm"	;Basic commands for ASM tasks
	
Bitmapfont:									;Chibiakumas bitmap font
	ifndef BuildVIC
		incbin "\ResALL\Font96.FNT"		;Not used by the VIC due to memory limitations
	endif
	

	include "\SrcALL\V1_Functions.asm"	;Basic text to screen functions
	include "\SrcAll\V1_BitmapMemory.asm"	;Bitmap functions for Bitmap screen systems
	include "\SrcAll\V1_VdpMemory.asm"		;VRAM functions for Tilemap Systems
	include "\SrcALL\V1_Palette.asm"		;Palette functions
	include "\SrcALL\V1_Footer.asm"		;Footer for systems that need it
	
	