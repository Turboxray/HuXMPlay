WAITVBLANK		.macro
		ldx #\1+1
		jsr __wait_vblank
	.endm	
	