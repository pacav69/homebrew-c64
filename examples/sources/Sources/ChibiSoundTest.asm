Mode2Color equ 1
	include "..\SrcALL\V1_Header.asm"
	include "\SrcAll\BasicMacros.asm"

	SEI			;Stop interrupts
	jsr ScreenInit
	
	jsr Cls
	
	ifdef BuildSNS		;Need Init on SNS
		jsr ChibiSound_INIT
	endif

	
	lda #$80			;Starting Sound
InfLoop:
	pha
		ldx #0
		ldy #0
		jsr Locate		;Reset Print Location
	pla
	pha
		jsr showhex		;Show A
	pla
	pha	
		jsr Chibisound	;Make sound			
		jsr Pause		;Slow down loop
	pla

	sec					;Alter sound for next loop
	sbc #1

	jmp InfLoop
	
	
	
Pause:
	ifndef BuildAP2	
		lda #$50
		sta z_b
		lda #00
		sta z_c
	
DelayAgain2:	
		jsr DecBC
		lda z_b
		ora z_c
		bne DelayAgain2	
	endif			
	rts	
	
	include "\SrcAll\V1_ChibiSound.asm"
	include "\SrcAll\monitor.asm"
	include "\SrcAll\BasicFunctions.asm"
	include "\SrcAll\V1_BitmapMemory.asm"
	include "\SrcAll\V1_VdpMemory.asm"		;VRAM functions for Tilemap Systems
	
Bitmapfont:
	incbin "\ResALL\Font96.FNT"		;Not used by the VIC due to memory limitations
	
	include "..\SrcALL\V1_Functions.asm"
	include "..\SrcALL\V1_Footer.asm"
		