	

ChibiSound_INIT:					;Call this to get ChibiSound ready!

	jsr SPC7000_Sound_INIT			;Load the driver into the SPC 700
		
	lda #$2C						;Echo vol
	jsr ProcessSoundCommandZero		;A=Reg Val=0
	
	lda #$3C						;Echo vol
	jsr ProcessSoundCommandZero		;A=Reg X=Val
	
	ldx #$7f						;Max volume
	lda #$0C						;Vol L
	jsr ProcessSoundCommandX		;A=Reg X=Val	
	lda #$1C						;Vol R
	jsr ProcessSoundCommandX		;A=Reg X=Val
	
	lda #$5D						;Offset to the source directory
	ldx #$03						;Data at $0300
	jsr ProcessSoundCommandX		;A=Reg X=Val

	lda #$4D						;echo on
	jmp ProcessSoundCommandZero		;A=Reg Val=0

	;rts
	
ChibiSound_Silent:
	lda #$5C						;Keys Off
	ldx #%00000001
	jmp ProcessSoundCommandX		;A=Reg X=Val

ChibiSound:
	cmp #0
	beq ChibiSound_Silent
	eor #%00111111
	pha
		lda #$5C					;Keys On
		ldx #%00000000
		jsr ProcessSoundCommandX	;A=Reg X=Val
		
		lda #$6C					;Flags + noise clock (5 bit noise)
		ldx #%00011111
		jsr ProcessSoundCommandX	;A=Reg X=Val		
	pla
	pha
		and #%10000000
		beq ChibiSound_NoNoise
ChibiSound_Noise:		
		lda #$3D					;Noise On;
		ldx #%00000001
		jsr ProcessSoundCommandX	;A=Reg X=Val
	pla
	pha
		and #%00111110
		lsr
		tax
		lda #$6C					;Noise Clock
		jsr ProcessSoundCommandX	;A=Reg X=Val
		
		jmp ChibiSound_NoiseDone
ChibiSound_NoNoise:	
		lda #$3D					;Noise On;
		jsr ProcessSoundCommandZero	;A=Reg Val=0

ChibiSound_NoiseDone:	
		lda #$02					;Tone L
		jsr ProcessSoundCommandZero	;A=Reg X=Val
	pla
	pha
		and #%00111111				;6 pitch bits
		tax
		lda #$03					;Tone H
		jsr ProcessSoundCommandX	;A=Reg X=Val

	pla 
	and #%01000000					;1 Volume bit
	ora #%00111111
	tax
	lda #$00						;Channel Vol L
	jsr ProcessSoundCommandX		;A=Reg X=Val
	lda #$01						;Channel Vol R
	jsr ProcessSoundCommandX		;A=Reg X=Val
	
	lda #$04						;Source Number (in the source directory)
	jsr ProcessSoundCommandZero		;A=Reg Val=0
	
	lda #$05						;ADSR
	jsr ProcessSoundCommandZero		;A=Reg Val=0
		
	lda #$4C						;Keys down
	ldx #%00000001					;Channel 1 down
	jmp ProcessSoundCommandX		;A=Reg X=Val

	;rts
	
	
	;SFX For Chibisound
SFXBank:							;We're going to load this into $0300 (IN SPC Ram)
	dw SFXBank_Sound1-SFXBank+$300	;Sample 0 main
	dw SFXBank_Sound1-SFXBank+$300	;Sample 0 Loop
									;Sample 1 main...

SFXBank_Sound1:	;Samples (9 bytes per sample set)
	db %11000111						;Header SSSSFFLE (Looping last sample)
	;   SSSSFFLE S= bitshift (0-12) FF=Filter L=Loop E=End of sample
	db $FF,$FF,$FF,$FF,$00,$00,$00,$00	;Samples (1 nibble per sample ADPCM)
	
	include "\srcSNS\SPC700_Compatibility.asm"
	include "\srcSNS\SNS_V1_SPC700_Driver.asm"