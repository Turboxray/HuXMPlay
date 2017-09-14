
	.zp
				DDAprocessing:			.ds 1

	.bss

				ChanNote:				.ds 1
				ChanStep:				.ds 1
				ChanTune:				.ds 1
				ChanOct:				.ds 1
				ChanFreq:				.ds 3
				ChanState:			.ds 6
				ChanBuffer:			.ds (8+3)*6
				ChanSelect:			.ds 1

				Ch0LoopAddr:		.ds 2
				Ch0LoopBank:		.ds 1
				Ch1LoopAddr:		.ds 2
				Ch1LoopBank:		.ds 1
				Ch2LoopAddr:		.ds 2
				Ch2LoopBank:		.ds 1
				Ch3LoopAddr:		.ds 2
				Ch3LoopBank:		.ds 1
				
				__GlobalVol:		.ds 1
				__ExtendedFlag:	.ds 1
				__internalUpdateCH: .ds 1
				__UpdateProcFlag:		.ds 1				

