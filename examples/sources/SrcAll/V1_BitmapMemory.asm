	Ifdef BuildAP2
		include "\SrcAP2\AP2_V1_BitmapMemory.asm"
	endif
	Ifdef BuildA52
		include "\SrcA52\A52_V1_BitmapMemory.asm"
	endif
	Ifdef BuildA80
		include "\SrcA52\A52_V1_BitmapMemory.asm"
	endif
	ifdef BuildLNX
		include "\SrcLNX\LNX_V1_BitmapMemory.asm"
	endif
	ifdef BuildBBC
		include "\SrcBBC\BBC_V1_BitmapMemory.asm"
	endif
	ifdef BuildC64
		include "\SrcC64\C64_V1_BitmapMemory.asm"
	endif
	
	