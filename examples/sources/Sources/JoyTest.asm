
UseDualJoy equ 1		;Enable 2nd joystick - to save memory on some systems we can turn it off.

	include "..\SrcALL\V1_Header.asm"
	include "\SrcAll\BasicMacros.asm"
	
;FourColor equ 1	


	SEI			;Stop interrupts
	jsr ScreenInit
	jsr Cls
	
JoytestLoop:
	pushpair z_bc
		ldx #0
		ldy #0
		jsr Locate
		jsr Player_ReadControlsDual			;read key and joy controls
		jsr Monitor_HL
	pullpair z_bc 

	jmp JoytestLoop	
	
	
	
	
	ldx #6
	ldy #3*8
	
	ifdef BuildAP2
bmpwidth equ 8
	else
	ifdef BuildLNX
bmpwidth equ 24
	else
	ifdef BuildC64
bmpwidth equ 3
	else
bmpwidth equ 6	
	endif

	endif
	endif
	
	
	
Monitor_HL:
	PushAll
	pushpair z_hl
	pushpair z_de
	pushpair z_bc
		lda z_h
		jsr printhex
		lda z_l
		jsr printhex
	pullpair z_bc
	pullpair z_de
	pullpair z_hl
	Pullall
	rts	
	

	
	include "\SrcAll\monitor.asm"
	include "\SrcAll\BasicFunctions.asm"
	;include "\SrcC64\C64_V1_KeyboardDriver.asm"
	include "\SrcBBC\BBC_V1_KeyboardDriver.asm"
	
	;include "\SrcA52\A52_V1_ChibiSound.asm"
	;include "\SrcAP2\AP2_V1_ChibiSound.asm"
	;include "\SrcPCE\PCE_V1_ChibiSound.asm"
	;include "\SrcNES\NES_V1_ChibiSound.asm"
	;include "\SrcC64\C64_V1_ChibiSound.asm"
	;include "\SrcBBC\BBC_V1_ChibiSound.asm"
	;include "\SrcLNX\LNX_V1_ChibiSound.asm"
;	include "\SrcVIC\VIC_V1_ChibiSound.asm"
	;include "\SrcSNS\SNS_V1_ChibiSound.asm"

Bitmapfont:
	ifndef BuildVIC
		incbin "\ResALL\Font96.FNT"		;Not used by the VIC due to memory limitations
	endif
	
	



Palette:
	;   -grb
	dw $0000	;0 - Background;
	dw $0099	;1
	dw $0E0F	;2
	dw $0FFF	;3 - Last color in 4 color modes
	dw $000F	;4;
	dw $004F	;5
	dw $008F	;6
	dw $00AF	;7
	dw $00FF	;8
	dw $04FF	;9
	dw $08FF	;10
	dw $0AFF	;11
	dw $0CCC	;12
	dw $0AAA	;13
	dw $0888	;14
	dw $0444	;15
	
	
	ifdef BuildNES	;Nes sprite colors
		dw $0000	;0 - Background;
		dw $0099	;1
		dw $0E0F	;2
		dw $0FF0	;3 - Last color in 4 color modes
		dw $000F	;4;
		dw $004F	;5
		dw $008F	;6
		dw $00AF	;7
		dw $00FF	;8
		dw $04FF	;9
		dw $08FF	;10
		dw $0AFF	;11
		dw $0CCC	;12
		dw $0AAA	;13
		dw $0888	;14
		dw $0444	;15
		dw $0FFF	;Border
	endif

	ALIGN 8

KeyboardScanner_KeyPresses
        db 16


		include "\SrcALL\V1_ReadJoystick.asm"
		
		include "..\SrcALL\V1_Functions.asm"
		include "\SrcALL\V1_Palette.asm"
		;include "\SrcAll\V1_SimpleTile.asm"
	
	include "\SrcAll\V1_BitmapMemory.asm"

	include "\SrcAll\V1_VdpMemory.asm"
		
		;
		ifdef BuildVIC
		ifndef BuildVIC_Rom
			org $1C00
			db 0,0,0,0,0,0,0,0	;Set Char 0 to blank
			incbin "\ResAll\Sprites\RawVIC.raw"
		endif
		endif
		
		include "..\SrcALL\V1_Footer.asm"
		
		
		
 

 