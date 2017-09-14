
	.zp
		CurrentPattern:	.ds 3

	.ifndef A0
		A0: .ds 2
A0.l = A0
A0.h = A0+1
	.endif		

	.ifndef A1
		A1: .ds 2
A1.l = A1
A1.h = A1+1
	.endif		

	.ifndef A2
		A2: .ds 2
A2.l = A2
A2.h = A2+1
	.endif		

	.ifndef A3
		A3: .ds 2
A3.l = A3
A3.h = A3+1
	.endif		
			
	.ifndef D0
		D0: .ds 2
D0.l = D0
D0.h = D0+1
	.endif		

	.ifndef D1
		D1: .ds 2
D1.l = D1
D1.h = D1+1
	.endif		

	.ifndef D2
		D2: .ds 2
D2.l = D2
D2.h = D2+1
	.endif		

	.ifndef D3
		D3: .ds 2
D3.l = D3
D3.h = D3+1
	.endif		
			
			
			
	.bss
			
		PatternList:			.ds 256
		PatternListLen:		.ds 1
		PatternAddr:			.ds 256 * 2
		PatternBank:			.ds 256
		PatternSizeOf:		.ds 256 * 2		
		PlayerTick:				.ds 1
		
		RegPlayerTick:		.ds 1
		RegPtrnAddr:			.ds 2
		RegPtrnBank:			.ds 1
		RegPtrnSize:			.ds 2
		RegPtrnLstPos:		.ds 1
		RegPtrnLine:			.ds 1
		
		ChanLineCache:		.ds 1
		__EntryMask:			.ds 4
		__EntryNote:			.ds 4
		__EntryOctave:		.ds 4
		__EntrySample:		.ds 4
		__EntrySub:				.ds 4
		__EntryFX:				.ds 4
		__EntryFXarg:			.ds 4
		
		LastPattern:			.ds 1
		LastSample:				.ds 1
		
		XMStringAddr:			.ds 2
		XMStringBank:			.ds 1	
		
		__ChanNote:				.ds 4
		__ChanOctave:			.ds 4
		__ChanSample:			.ds 4
		__ChanFinestep:		.ds 4
		__ChanVol:				.ds 4
		__ChanSubcode:		.ds 4
		__ChanFX:					.ds 4
		__ChanFXarg:			.ds 4
		__ChanPan:				.ds 4
		__ChanUpdate:			.ds 4


		
			
			
			
			
			
			