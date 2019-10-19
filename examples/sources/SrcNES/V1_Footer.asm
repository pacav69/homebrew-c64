	org $FFFA
	ifdef CustomNmihandler
		dw CustomNmihandler
	else
		dw nmihandler			;FFFA - Interrupt handler
	endif
	dw	NES_main				;FFFC - Entry point
	dw irqhandler				;FFFE - IRQ Handler
	
	
	
	
	
	
	