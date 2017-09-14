
;//.........................................
LoadXMFile .macro

			
				;// Get the Play list offset & bank -> A0:D0.l
				lda #low((\1 & $1fff) + $8000 )
				sta <A0.l 
				lda #high((\1 & $1fff) + $8000)
				sta <A0.h
				lda #Bank(\1)
				sta <D0.l 
				
				CallFarWide __LoadXMFile
				
				;// Set player tick
				lda PlayerTick
				sta RegPlayerTick	

			
	.endm


;//.........................................

__CreateCase	.macro
				cmp \1
				bne .x_\@
				jmp \2
.x_\@			

	.endm

;//.........................................

__CreateCaseBit	.macro
				lsr a
				bcc .x_\@
					phx
				jsr \1
					plx
.x_\@			

	.endm


;//.........................................

__GetChanEntry	.macro

				lsr \1 
				bcc .x_\@
				lda \2
				iny
				sta \3
				jsr __DecPatternCounter
.x_\@	

	.endm

		


;//.........................................

XM_Play	.macro
				CallFarWide XM_GetPatternLine
				CallFarWide XM_UpdateRegs

	.endm
	

















