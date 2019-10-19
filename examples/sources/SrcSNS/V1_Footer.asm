
	org $FFC0
     ; "123456789012345678901"
	db "www.ChibiAkumas.com  "	; PROGRAM TITLE (21 Byte ASCII String, Use Spaces For Unused Bytes)

	db $20		; ROM MODE/SPEED (Bits 7-4 = Speed, Bits 3-0 = Map Mode)
	db $00		; ROM TYPE (Bits 7-4 = Co-processor, Bits 3-0 = Type)
	db $01 		; ROM SIZE in banks (1bank=32k)
	db $00 		; RAM SIZE (0=none)
	db $00		; COUNTRY/VIDEO REFRESH (NTSC/PAL-M = 60 Hz, PAL/SECAM = 50 Hz) (0=j 1=US/EU)
	db $00		; DEVELOPER ID CODE
	db $00		; ROM VERSION NUMBER
	db "CC"		; COMPLEMENT CHECK
	db "CS" 	; CHECKSUM

; NATIVE VECTOR (65C816 Mode)
	dw $0000 	; RESERVED
	dw $0000 	; RESERVED
	dw $0000 	; COP VECTOR   (COP Opcode)
	dw $0000 	; BRK VECTOR   (BRK Opcode)
	dw $0000 	; ABORT VECTOR (Unused)
	ifdef CustomNmihandler
		dw CustomNmihandler	;Vblank
	else
		dw $0000
	endif
	dw $0000 	; RESET VECTOR (Unused)
	dw $0000 	; IRQ VECTOR   (H/V-Timer/External Interrupt)

; EMU VECTOR (6502 Mode)
	dw $0000 	; RESERVED
	dw $0000	; RESERVED
	dw $0000 	; COP VECTOR   (COP Opcode)
	dw $0000 	; BRK VECTOR   (Unused)
	dw $0000 	; ABORT VECTOR (Unused)
	ifdef CustomNmihandler
		dw CustomNmihandler ;Vblank
	else
		dw $0000
	endif
	dw $8000 	; RESET VECTOR (CPU is always in 6502 mode on RESET)
	dw $0000 	; IRQ/BRK VECTOR
	
	
	