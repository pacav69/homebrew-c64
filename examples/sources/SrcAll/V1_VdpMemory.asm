
	ifdef BuildSNS
		include "\SrcSNS\SNS_V1_VdpMemory.asm"
	endif
	ifdef BuildVIC
		include "\SrcVIC\VIC_V1_VdpMemory.asm"
	endif	
	ifdef BuildPCE
		include "\SrcPCE\PCE_V1_VdpMemory.asm"
	endif
	ifdef BuildNES
		include "\SrcNES\NES_V1_VdpMemory.asm"
	endif
	ifdef BuildC64
		include "\SrcC64\C64_V1_VdpMemory.asm"
	endif