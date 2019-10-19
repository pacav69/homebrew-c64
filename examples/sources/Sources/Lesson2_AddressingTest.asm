Mode2Color equ 1

	include "..\SrcALL\V1_Header.asm"		;Cartridge/Program header - platform specific
	include "\SrcAll\BasicMacros.asm"		;Basic macros for ASM tasks

	SEI						;Stop interrupts
	jsr ScreenInit			;Init the graphics screen
	
	;We need to set up various test areas for these examples to work....
	
	lda #<ChunkZP20
	sta z_L
	lda #>ChunkZP20
	sta z_H
	lda #<$0080
	sta z_E
	lda #>$0080
	sta z_D
	jsr CopyChunk
	
	lda #<Chunk2000
	sta z_L
	lda #>Chunk2000
	sta z_H
	lda #<$2000
	sta z_E
	lda #>$2000
	sta z_D
	jsr CopyChunk
	
	lda #<Chunk1311
	sta z_L
	lda #>Chunk1311
	sta z_H
	lda #<$1311
	sta z_E
	lda #>$1311
	sta z_D
	jsr CopyChunk
	
	lda #<Chunk1211
	sta z_L
	lda #>Chunk1211
	sta z_H
	lda #<$1211
	sta z_E
	lda #>$1211
	sta z_D
	jsr CopyChunk
		
	lda #<ChunkJmpTest
	sta z_L
	lda #>ChunkJmpTest
	sta z_H
	lda #<$1B19
	sta z_E
	lda #>$1B19
	sta z_D
	jsr CopyChunk
	
	
	
	jsr Cls					;Clear the screen
	
	
	ldx #1
	ldy #2

    jsr MemDump
    word $0080      ;Address
    byte $1          ;Lines	
	
	jsr MemDump
    word $2000      ;Address
    byte $1          ;Lines	
	
	jsr MemDump
    word $1310      ;Address
    byte $1          ;Lines	
	
	jsr MemDump
    word $1210      ;Address
    byte $1          ;Lines	
	
	jsr MemDump
	word $1B19      ;Address
    byte $1          ;Lines	
	jsr newline 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
;Example 1 JSR - Relative	
	 ; jmp bcctest				;Jump over aligned code
	 ; align 8					;align to a byte boundary
; bcctest:
	; clc							;Clear the carry
	 ; jsr Monitor				;Show the monitor
	 ; bcc 3						;Branch if the carry is clear - move +3 bytes
	 ; jsr Monitor				;Show the monitor - this command is 3 bytes
	 ; jsr Monitor				;Show to the monitor
	; jmp *						;Inf Loop
	
;Example 2 - Accumulator
	; lda #$08				;Load the accumulator with HEX 8
	; jsr Monitor				;Show the monitor
	; lsr						;Logical shift bits Right
	; jsr Monitor				;Show the monitor
	; jmp *					;Inf Loop
	
;Example 3 - Immediate
	; clc						;Clear the Carry
	; lda #$10				;LoaD the Accumulator with hex 10
	; jsr Monitor				;Show the monitor
 	; adc #$20				;ADd hex 20 + the carry to the accumulator
	; jsr Monitor				;Show the monitor
	; jmp *					;Inf Loop
		
	
;Example 4 - Zero Page / Direct page	
	; lda $80					;Load A from ZP address $80 = $0080
	; jsr Monitor				;Show the monitor
	; jmp *					;Inf Loop
	
;Example 5 - Zero Page Indexed X,Y
	; ldx #1					;Load X with 1
	; lda $80,X				;Load A from Zeropage $80 + X (so load from Zeropage $81)
	; jsr Monitor				;Show the monitor
	; ldy #2					;Load Y with 1
	; ldx $80,Y				;ZP,Y only works with LDX,STX... if you do LDA $20,Y, VASM will convert it to LDA $0020,y (which works but is longer!)
	; jsr Monitor				;Show the monitor
	; jmp *					;Inf Loop
	
;Example 6 - Absolute 
	; lda $2000				;Load from address $2000
	; jsr Monitor				;Call the monitor
	; jmp *					;Inf Loop
	
; Example 7 - Absolute Indexed
	; ldx #1					;Load X with 1
	; lda $2000,X				;Load A from address ($2000+X) so ($2001)
	; jsr Monitor
	
	; ldy #2					;Load Y with 2
	; lda $2000,Y				;Load A from address ($2000+X) so ($2001)
	; jsr Monitor				;Call the monitor
	; jmp *					;Inf Loop
	
; Example 8 - Absolute Indirect
	jmp ($2000)	; ($nnnn) only works with Jump... if you need indirect for other uses, use ($zp,X) or  ($zp),Y ... with X or Y as 0 
	jmp *						;Inf Loop
	
; Example 9 - Preindexed Indirect X
	; ldx #2					;Load X with 1
	; lda ($80,X)				;Preindex direct page ($0080+X)  so load data from address at ($0081)
	; jsr Monitor				;Call the monitor
	; jmp *					;Inf Loop
	
; Example 10 - Postindexed Indirect Y
	; ldy #0					;Load Y with 2
	; lda ($80),Y				;Postindexed direct page (($0080)+Y) so load the address from ($0080), add 2 to it... and load the data from that resulting address
	; jsr Monitor				;Call the monitor
	; jmp *					;Inf Loop
	
; Example 11 - Indirect (65C02 only) ... Apple II,Lynx,Snes or PC-Engine (in theory -PCE can't run this demo)
	; lda ($81)				;Load the address from ($0081).... then load the value from that resulting address
	; jsr Monitor				;Call the monitor
	; jmp *					;Inf Loop
	

	
	
	
	;lda #<MyText
	;sta z_L
	;lda #>MyText
	;sta z_H
	;jsr PrintString
	
	
	;900A     36874    Frequency for oscillator 1 (low)
;                  (on: 128-255)
;900B     36875    Frequency for oscillator 2 (medium)
;                  (on: 128-255)
;900C     36876    Frequency for oscillator 3 (high)
;                  (on: 128-255)
;900D     36877    Frequency of noise source
;900E     36878    bit 0-3 sets volume of all sound
;                  bits 4-7 are auxiliary color information


;	jsr SPC7000_Sound_INIT
	

	jsr *

	
	
CopyChunk:	
	lda #$00
	sta z_b
	lda #$08
	sta z_c
	jmp LDIR
	
ChunkZP20:
	db $11,$12,$13,$14,$15,$16,$17,$18
Chunk2000:
	db $1A,$1B,$1C,$1D,$1E,$1F,$20,$21
Chunk1311:
	db $30,$31,$32,$33,$34,$35,$36,$37
Chunk1211:
	db $40,$41,$42,$43,$44,$45,$46,$47
ChunkJmpTest:	
	db $69								;intentional Bad data 
	jsr Monitor							;Test program for indirect jump
InfLoopy:	
	clv
	bvc InfLoopy
	db 0,0,0,0,0,0,0,0

	
	
	Monitor_Zpair:
	PushAll
		lda z_h
		jsr printhex
		lda z_l
		jsr printhex
	tsx

    inc SPpage+$04,x
    inc SPpage+$04,x
	
    lda SPpage+$04,x
    cmp #2
    bcs Monitor_Zpair_NoIncSpH
	inc SPpage+$05,x
Monitor_Zpair_NoIncSpH
	


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
	
	