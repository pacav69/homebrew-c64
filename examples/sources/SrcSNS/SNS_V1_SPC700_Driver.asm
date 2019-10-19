
ReuploadSoundData:			;Send some data to the SPC700 ram
	lda #02
	jmp ProcessSoundCommandAlt
ProcessSoundCommandZero:	
	ldx #0
ProcessSoundCommandX:	
	sta $2140				;Reg
	stx $2141				;NewVal
ProcessSoundCommand:		;Send a register to the SPC700
	lda #03
ProcessSoundCommandAlt:
	sta $2142				;Define the command
	
	lda $2143	;Tell the SPC700 to act, by writing the value in 00F7/2143 back to itself
	sta $2143
ProcessSoundCommandWait:
	cmp $2143	;Now wait until the value changes, meaning the SPC700 has processed the data 
					;Note, Data Written to $2143 won't read back the same until SP700 writes back

	beq ProcessSoundCommandWait
	
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;db $E8,$66			;mov a<#
	;db $E8,$66			;mov a<#
	;db $c5,$F4,$00		;Mov a>$
;	align 8
	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;				SPC700 Sound driver
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;
	;		This is a simple driver for the SPC700 CPU,

	;		00F4/2140	- if command3... Reg num
	;		00F5/2141   - if command3... Reg val
	;		00F6/2142	- Command (3=SetReg / 2=ROM data transfer) 
	;		00F7/2143	- Sync... Read the value in this port, and write it back to the SPC700 to do a command.. then wait until the read data changes to know the command was processed
	;
	;
SPDest 			equ $200	;Dest in SPC700 ram
SoundKeyAddr 	equ $F000	;This is the value we're using as a 'lock'... 
								;when the main CPU writes this to port 00F7/2143 we know a command is ready to process	
	;Address Notes:
	;SoundCallPause-SPrg+SPDest.... We're loading into a different memloc (SPDest) in SP700 ram, so we need to recalculate our addresses to make them work
	;SoundGotCommand-(*+1) - this calculates a RELATIVE offset for BRA type commands
	
	;commands are Z80 style (R->L), so MOV A,Addr = loads A from Addr
	
SPrg:	
SPrgWait:		;Main loop
	s_call_addr SoundCallPause-SPrg+SPDest; jump to SoundCallPause
	s_mov_a_addr $00F6
	s_cmp_a_ii $03						;Command 3 - Set a reg
	s_beq_r SoundGotCommand-(*+1)
	s_cmp_a_ii $02						;Command 2 - Upload data
	s_beq_r SoundRomcall-(*+1)
	
	s_call_addr SCallResume-SPrg+SPDest	;Announce Command Done
	s_bra_r SPrgWait-(*+1)				;Return to main loop
	
SoundGotCommand:	;Command 3 recieved - Change Regs
	s_nop
	s_mov_a_addr $00F4					;Load Reg num from 00F4/2140
	s_mov_addr_a $00F2					;Write to 00F2
	s_nop
	s_mov_a_addr $00F5					;Load Reg num from 00F5/2141
	s_mov_addr_a $00F3					;Write to 00F3

	s_call_addr SCallResume-SPrg+SPDest	;Announce Command Done
	s_bra_r SPrg-(*+1)					;Return to main loop
	
SoundRomcall:	;Command 2 - Restart Rom routine
	s_call_addr SCallResume-SPrg+SPDest	;Announce Command Done
	s_call_addr SCallResume-SPrg+SPDest	;Announce Command Done (do twice for safety!)
	s_jmp_addr $FFC0					;Jump to the firmawre data transfer routine

SoundCallPause:		;Wait for process command
	s_mov_a_addr $00F7					;The main CPU has to write the value in 00F7/2143 back 
	s_cmp_a_addr SoundKeyAddr			 ;to 00F7/2143 to tell the SPC700 a command is waiting
	s_bne_r SoundCallPause-(*+1)		;Still pausing while byte unchanged
	s_ret
	
SCallResume:		;Finished command - We alter 00F7/2143... 	
						;INC ing it by 1 to tell the main CPU we're done
	s_mov_a_addr SoundKeyAddr			;Read current value
	s_inc_a								;Increase it
	s_mov_addr_a SoundKeyAddr			;Write it back
	s_mov_addr_a $00F7					;Store new value in $00F7/2143
	
	s_ret
SPrgEnd:	


	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


SPC7000_Sound_INIT:
	lda #<SPrg			;Send our core program to the SPC700 ram
	sta z_l
	lda #>SPrg
	sta z_h
	
	lda #<SPDest		;Dest Ram (in SPC700)
	sta z_e
	lda #>SPDest
	sta z_d
	
	lda #SPrgEnd-SPrg	;Bytes
	sta z_b
	jsr SendSoundData
	
	jsr ReuploadSoundData ;Tell our SPC700 prog we want to send more data
	
	lda #<SFXBank		;Send our SFX to the RAM
	sta z_l
	lda #>SFXBank
	sta z_h
	
	lda #<$0300			;Dest Ram (in SPC700)
	sta z_e
	lda #>$0300
	sta z_d
	
	lda #128			;Bytes
	sta z_b
;	jmp SendSoundData
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SendSoundData:			;Send data from HL (in regular memory) to DE (DE in SPC700 memory) ...
;NOTE!
;The important thing with the SPC700 ports is R and W are separate
;the 65816 can write $66 to 2140, but that doesn't mean that value will be read back by the 65816!
;2140 will only contain $66 if the SPC700 writes $66 value to its port 00F4 (00F4/2140 are a pair)

; Thats how wait loops may write a value to the port, and wait until the same value is read back as a sync timer


SoundWait:
	lda $2140			;we should get $AA in 2140 and $BB in 2141
	cmp #$AA				; when the SPC700 rom is ready for data
	bne SoundWait
	lda $2141
	cmp #$BB
	bne SoundWait
	
	lda z_e			;Dest addr L in SPC700 ram
	sta $2142
	lda z_d			;Dest addr H
	sta $2143
	
	lda #1			;Write a nonzero value here
	sta $2141
	lda #$CC		;Tell the ROM we're ready to send data
	sta $2140
SoundWait2
	lda $2140
	cmp #$CC		;Wait until we get $CC back
	bne SoundWait2
	

	
	ldx z_b				;Bytecount - this code is limted to 256 max
	ldy #0
	lda (z_hl),Y
	sta $2141			;Write the first byte
	iny
	dex
	
	lda #0				;First byte notifier (Byte 0)
	sta $2140
SoundWait3
	lda $2140
	bne SoundWait3		;Wait until first byte processed
	
	
LoadLoop:
	lda (z_hl),Y		;Get and send next byte
	sta $2141
	
	lda $2140
	clc
	adc #1
	sta $2140			;INC value in $2140	
SoundWait4
	cmp $2140			;Wait until $2140 responds with 
	bne SoundWait4			;the value we just wrote to it
	
	iny
	dex
	bne LoadLoop		;Load next byte
	
	stz $2141			;Write zero to $2141
	
	lda #<SPDest		;Execute address
	sta $2142
	lda #>SPDest
	sta $2143
	
	lda $2140			;add 2 to $2140
	clc
	adc #2
	sta $2140
	
SoundWait5
	cmp $2140			;Wait for SPC700 to process command
	bne SoundWait5
	rts
	
	
	
	