CONTROL_START:

;//......................................................

_SetChanFreq_0 

		
				cmp #$c0
				bcs .note
				cmp #$80
				bcs .note_oct
				
.note_oct_tune
				and #$0f
				sta Chan0note
				stx Chan0oct
				sty Chan0step
				jmp .cont
.note_oct
				and #$0f
				sta Chan0note
				stx Chan0oct
				jmp .cont
.note
				and #$0f
				sta Chan0note

.cont		
		
_UpdateChanFreq_0:

;//Get the frequency from tbe Note table
				lda Chan0note
				asl a
				tay
				lda NoteTable,y
				sta Chan0freq+2
				lda NoteTable+1,y
				sta Chan0freq+1
				lda #$01
				sta Chan0freq
				
;//Apply fine Step
				lda Chan0note
				asl a
				tay
				lda FineStepTable,y
				sta <A0.l
				lda FineStepTable+1,y
				sta <A0.h
				lda Chan0step
				asl a
				tay
				lda [A0],y
				clc
				adc Chan0freq+2
				sta Chan0freq+2
				iny
				lda [A0],y
				clc
				adc Chan0freq+1
				sta Chan0freq+1
				bcc .skip
				inc Chan0freq
.skip
				
				
				
				
;//Calculate the Octave shift pattern
				lda Chan0oct
				and #$07
				tay
				cmp #$03
				beq .out
				bcs .left		
.right
				lsr Chan0freq
				ror Chan0freq+1
				ror Chan0freq+2
				iny
				cpy #$03
				bcc .right
				jmp .out

.left
				asl Chan0freq+2
				rol Chan0freq+1
				rol Chan0freq
				dey
				cpy #$04
				bcs .left


		
.out
				lda Chan0freq
					sta Ch0Buffer+10						;CHN0.hi
				lda Chan0freq+1
					sta Ch0Buffer+9							;CHN0.mid
				lda Chan0freq+2
					sta Ch0Buffer+8							;CHN0.lo
				
				lda #$80
				tsb Ch0State
				
			rts
				
;//end sub




;//......................................................

LoadSampleCh0:
				
				stx <A0.l
				sta <A0.h
				tma #$05
				pha
				tma #$06
				pha
				tya
				tam #$05
				inc a
				tam #$06

				ldy #$03
				lda [A0],y
				
				;//get loop address
				dey
				lda [A0],y				
				sta Ch0Buffer+7			;Ch0LoopBank					;//right now this is a relative back value/delta
				dey
				lda [A0],y				
				sta Ch0Buffer+6			;Ch0LoopAddr+1
				dey
				lda [A0],y				
				sta Ch0Buffer+5			;Ch0LoopAddr+0

				;//increment offset, store it to channel pointer
				lda <A0.l
				clc
				adc #$04
				sta Ch0Buffer+2					;CHN0.ptr
				lda <A0.h
				adc #$00
				cmp #$c0
				bcc .skip
				and #$1f
				ora #$c0
				pha
				tma #$05
				inc a
				tam #$05
				pla
.skip
				and #$1f
				ora #$c0
				sta Ch0Buffer+3					;CHN0.ptr+1
				tma #$05
				sta Ch0Buffer+4					;CHN0.bnk
				clc
				adc Ch0Buffer+7	
				sta Ch0Buffer+7					;Ch0LoopBank				;//change relative bank to absolute bank
				
				lda Ch0Buffer+2					;CHN0.ptr
				clc
				adc Ch0Buffer+5
				sta Ch0Buffer+5					;Ch0LoopAddr
				lda Ch0Buffer+3					;CHN0.ptr+1
				adc Ch0Buffer+6					;Ch0LoopAddr+1
				cmp #$e0
				bcc .skip2
				and #$1f
				ora #$c0
				inc Ch0Buffer+7					;Ch0LoopBank
.skip2
				sta Ch0Buffer+6					;Ch0LoopAddr+1
				
				lda #$03
				tsb Ch0State
				
				
				pla
				tam #$06
				pla
				tam #$05
		rts
				
;//end sub	
				




;//......................................................

UpdatePCMChannels:				

				lda Ch0State
				beq .done
				bit #$01
				beq .skip0
				jsr __PointerUpdateCH0
.skip0
				bit #$02
				beq .skip1
				jsr __LoopUpdateCH0
.skip1
				bit #$04
				beq .skip2
				jsr __StartUpdateCH0
.skip2				
				bit #$08
				beq .skip3
				jsr __StopUpdateCH0
.skip3				
				bit #$10
				beq .skip4
				jsr __ResetUpdateCH0
.skip4				
				bit #$20
				beq .skip5
				jsr __VolUpdateCH0
.skip5				
				bit #$40
				beq .skip6
				jsr __PanUpdateCH0
.skip6				
				bit #$80
				beq .out
				jsr __FreqUpdateCH0

.out				
				stz Ch0State
.done
			rts
			
__PointerUpdateCH0:
				ldx Ch0Buffer+2					;CHN0.ptr
				stx CHN0.ptr
				ldx Ch0Buffer+3					;CHN0.ptr+1
				stx CHN0.ptr+1
				ldx Ch0Buffer+4					;CHN0.bnk
				stx CHN0.bnk
			rts


__LoopUpdateCH0:				
				ldx Ch0Buffer+5					;Ch0LoopAddr
				stx Ch0LoopAddr
				ldx Ch0Buffer+6					;Ch0LoopAddr+1
				stx Ch0LoopAddr+1
				ldx Ch0Buffer+7					;Ch0LoopBank
				stx Ch0LoopBank
			rts

__StartUpdateCH0:				

				ldx #CHN0.on
				stx CHN0.mode
				ldx #$00
				stx CHN0.brn
			rts

__StopUpdateCH0:				
				ldx #CHN0.off				
				stx CHN0.mode
				ldx #CHN0.skip
				stx CHN0.brn
			rts

__ResetUpdateCH0:				
				stz CHN0.Plo
				stz CHN0.Phi
			rts

__VolUpdateCH0:
				stz $800
				ldx Ch0Buffer
				stx $804			
			rts

__PanUpdateCH0:				
				stz $800
				ldx Ch0Buffer+1
				stx $804			
			rts

__FreqUpdateCH0:				

				ldx Ch0Buffer+10						;CHN0.hi
				stx CHN0.hi
				ldx Ch0Buffer+9							;CHN0.mid
				stx CHN0.mid
				ldx Ch0Buffer+8							;CHN0.lo
				stx CHN0.lo
			rts



;//end sub	


CONTROL_END:

;//..........................................................................
;//Tables

NoteTable:		;65536*((2^(0+(x/12)))-1)
		;C3
				.dw 0000
		;C#3
				.dw 3897
		;D3
				.dw 8026
		;D#3
				.dw 12400
		;E3
				.dw 17304
		;F3
				.dw 21944
		;F#3
				.dw 27146
		;G3
				.dw 32657
		;G#3
				.dw 38496 
		;A3
				.dw 44682
		;B3
				.dw 51236
		;B#3
				.dw 58179







StepNote .macro

		.dw (\1)*0
		.dw (\1)*1
		.dw (\1)*2
		.dw (\1)*3
		.dw (\1)*4
		.dw (\1)*5
		.dw (\1)*6
		.dw (\1)*7
		.dw (\1)*8
		.dw (\1)*9
		.dw (\1)*10
		.dw (\1)*11
		.dw (\1)*12
		.dw (\1)*13
		.dw (\1)*14
		.dw (\1)*15
		.dw (\1)*16
		.dw (\1)*17
		.dw (\1)*18
		.dw (\1)*19
		.dw (\1)*20
		.dw (\1)*21
		.dw (\1)*22
		.dw (\1)*23
		.dw (\1)*24
		.dw (\1)*25
		.dw (\1)*26
		.dw (\1)*27
		.dw (\1)*28
		.dw (\1)*29
		.dw (\1)*30
		.dw (\1)*31

	.endm


;// These are the 12 notes, each with 32steps in between them.
FineStep0:
	StepNote ((3897-0000)/32)
FineStep1:
	StepNote ((8026-3897)/32)
FineStep2:
	StepNote ((12400-8026)/32)
FineStep3:
	StepNote ((17304-12400)/32)
FineStep4:
	StepNote ((21944-17304)/32)
FineStep5:
	StepNote ((27146-21944)/32)
FineStep6:
	StepNote ((32657-27146)/32)
FineStep7:
	StepNote ((38496-32657)/32)
FineStep8:
	StepNote ((44682-38496)/32)
FineStep9:
	StepNote ((51236-44682)/32)
FineStep10:
	StepNote ((58179-51236)/32)
FineStep11:
	StepNote ((65535-58179)/32)

FineStepTable:
	.dw FineStep0, FineStep1, FineStep2, FineStep3
	.dw FineStep4, FineStep5, FineStep6, FineStep7
	.dw FineStep8, FineStep9, FineStep10, FineStep11


note_C  			= 0
note_C_sharp 	= 1
note_D 				= 2
note_D_sharp 	= 3
note_E  			= 4
note_E_sharp 	= 5
note_F  			= 6 
note_G  			= 7
note_G_sharp 	= 8
note_A  			= 9
note_A_sharp 	= 10
note_B  			= 11

octave_0			= 0
octave_1			= 1
octave_2			= 2
octave_3			= 3
octave_4			= 4
octave_5			= 5
octave_6			= 6
octave_7			= 7

finestep_0		= 0
finestep_1		= 1
finestep_2		= 2
finestep_3		= 3
finestep_4		= 4
finestep_5		= 5
finestep_6		= 6
finestep_7		= 7
finestep_8		= 8
finestep_9		= 9
finestep_10		= 10
finestep_11		= 11
finestep_12		= 12
finestep_13		= 13
finestep_14		= 14
finestep_15		= 15
finestep_16		= 16
finestep_17		= 17
finestep_18		= 18
finestep_19		= 19
finestep_20		= 20
finestep_21		= 21
finestep_22		= 22
finestep_23		= 23
finestep_24		= 24
finestep_25		= 25
finestep_26		= 26
finestep_27		= 27
finestep_28		= 28
finestep_29		= 29
finestep_30		= 30
finestep_31		= 31



