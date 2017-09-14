CONTROL_START:

;//..............................................................................

_SetChanFreq

				sta ChanNote
				stx ChanOct
				sty ChanStep
		
_UpdateChanFreq:

;//Get the frequency from tbe Note table
				lda ChanNote
				asl a
				tay
				lda NoteTable,y
				sta ChanFreq+2
				lda NoteTable+1,y
				sta ChanFreq+1
				lda #1
				sta ChanFreq						; This always needs to be 1
				
;//Apply fine Step
				lda FineStepTable,y
				sta <DriverPtr.l
				lda FineStepTable+1,y
				sta <DriverPtr.h
				lda ChanStep
				asl a
				tay
				lda [DriverPtr],y
				clc
				adc ChanFreq+2
				sta ChanFreq+2
				iny
				lda [DriverPtr],y
				clc
				adc ChanFreq+1
				sta ChanFreq+1
				bcc .skip
				inc ChanFreq
.skip
				
				
				
				
;//Calculate the Octave shift pattern
				lda ChanOct
				and #$07
				tay
				cmp #$03
				beq .out
				bcs .left		
.right
				lsr ChanFreq
				ror ChanFreq+1
				ror ChanFreq+2
				iny
				cpy #$03
				bcc .right
				jmp .out

.left
				asl ChanFreq+2
				rol ChanFreq+1
				rol ChanFreq
				dey
				cpy #$04
				bcs .left


		
.out
				ldx ChanSelect
				lda ChanState,x
				ora #$80
				sta ChanState,x

				ldy __buffer_offset_table,x

				lda ChanFreq
					sta ChanBuffer+10,y							;CHN0.hi
				lda ChanFreq+1
					sta ChanBuffer+9,y							;CHN0.mid
				lda ChanFreq+2
					sta ChanBuffer+8,y							;CHN0.lo
				
			rts

__buffer_offset_table .db 00,11,22,33,44,55
				
;//end sub




;//......................................................

LoadSample:
				
				stx <DriverPtr.l
				sta <DriverPtr.h
				tma #$05
				pha
				tma #$06
				pha
				tya
				tam #$05
				inc a
				tam #$06

				ldx ChanSelect
				lda ChanState,x
				ora #$03
				sta ChanState,x
				lda __buffer_offset_table,x
				tax

				ldy #$03
				lda [DriverPtr],y
				
				;//get loop address
				dey
				lda [DriverPtr],y				
				sta ChanBuffer+7,x					;Ch0LoopBank					;//this is a relative back value/delta
				dey
				lda [DriverPtr],y				
				sta ChanBuffer+6,x					;Ch0LoopAddr+1
				dey
				lda [DriverPtr],y				
				sta ChanBuffer+5,x					;Ch0LoopAddr+0

				;//increment offset, store it to channel pointer
				lda <DriverPtr.l
				clc
				adc #$04
				sta ChanBuffer+2,x					;CHN0.ptr
				lda <DriverPtr.h
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
				sta ChanBuffer+3,x					;CHN0.ptr+1
				tma #$05
				sta ChanBuffer+4,x					;CHN0.bnk
				clc
				adc ChanBuffer+7,x	
				sta ChanBuffer+7,x					;Ch0LoopBank				;//change relative bank to absolute bank
				
				lda ChanBuffer+2,x					;CHN0.ptr
				clc
				adc ChanBuffer+5,x
				sta ChanBuffer+5,x					;Ch0LoopAddr
				lda ChanBuffer+3,x					;CHN0.ptr+1
				adc ChanBuffer+6,x					;Ch0LoopAddr+1
				cmp #$e0
				bcc .skip2
				and #$1f
				ora #$c0
				inc ChanBuffer+7,x					;Ch0LoopBank
.skip2
				sta ChanBuffer+6,x					;Ch0LoopAddr+1
				
				
				
				pla
				tam #$06
				pla
				tam #$05
		rts
				
;//end sub	
				




;//......................................................

UpdatePCMChannels:
				
				lda #$01
				sta __UpdateProcFlag
					jsr	__DoExtended
					jsr __UpdateChannel_0
					jsr __UpdateChannel_1
					jsr __UpdateChannel_2
					jsr __UpdateChannel_3
					jsr __UpdateChannel_4
					jsr __UpdateChannel_5
				stz __UpdateProcFlag
		rts
		
;//.............................
__DoExtended
				lda __ExtendedFlag
				beq .done
				bit #$01
				beq .skip0
				jsr .__UpdateGlobalVol
.skip0
				bit #$02
				beq .skip1
				jsr .__ResumeDriver
.skip1							
				bit #$04
				beq .skip2
				jsr .__PauseDriver
.skip2							

				stz __ExtendedFlag
				
				
.done
		rts
		
.__UpdateGlobalVol
				stz $800
				ldx __GlobalVol
				stx $801
		rts

.__ResumeDriver
				ldx #$8f
				stx EnableTimerDriver
		rts

.__PauseDriver
				ldx #$40
				stx EnableTimerDriver
		rts

;//.............................
__UpdateChannel_0
				tst #$01,__internalUpdateCH
				bne	.done
				lda ChanState+0
				beq .done
				bit #$01
				beq .skip0
				jsr .__PointerUpdateCH0
.skip0
				bit #$02
				beq .skip1
				jsr .__LoopUpdateCH0
.skip1
				bit #$04
				beq .skip2
				jsr .__StartUpdateCH0
.skip2				
				bit #$08
				beq .skip3
				jsr .__StopUpdateCH0
.skip3				
				bit #$10
				beq .skip4
				jsr .__ResetUpdateCH0
.skip4				
				bit #$20
				beq .skip5
				jsr .__VolUpdateCH0
.skip5				
				bit #$40
				beq .skip6
				jsr .__PanUpdateCH0
.skip6				
				bit #$80
				beq .out
				jsr .__FreqUpdateCH0

.out				
				stz ChanState+0
.done
			rts
			
.__PointerUpdateCH0:
				ldx ChanBuffer+2						
				stx CHN0.ptr
				ldx ChanBuffer+3						
				stx CHN0.ptr+1
				ldx ChanBuffer+4						
				stx CHN0.bnk
			rts


.__LoopUpdateCH0:				
				ldx ChanBuffer+5						
				stx Ch0LoopAddr
				ldx ChanBuffer+6						
				stx Ch0LoopAddr+1
				ldx ChanBuffer+7						
				stx Ch0LoopBank
			rts

.__StartUpdateCH0:				

				ldx #CHN0.on
				stx CHN0.mode
				ldx #$00
				stx CHN0.brn
			rts

.__StopUpdateCH0:				
				ldx #CHN0.off				
				stx CHN0.mode
				ldx #CHN0.skip
				stx CHN0.brn
			rts

.__ResetUpdateCH0:				
				stz CHN0.Plo
				stz CHN0.Phi
			rts

.__VolUpdateCH0:
				stz $800
				ldx ChanBuffer
				stx $804			
			rts

.__PanUpdateCH0:				
				stz $800
				ldx ChanBuffer+1
				stx $805			
			rts

.__FreqUpdateCH0:				

				ldx ChanBuffer+10						
				stx CHN0.hi
				ldx ChanBuffer+9						
				stx CHN0.mid
				ldx ChanBuffer+8						
				stx CHN0.lo
			rts

;//.............................
__UpdateChannel_1
				tst #$02,__internalUpdateCH
				bne	.done
				lda ChanState+1
				beq .done
				bit #$01
				beq .skip0
				jsr .__PointerUpdateCH1
.skip0
				bit #$02
				beq .skip1
				jsr .__LoopUpdateCH1
.skip1
				bit #$04
				beq .skip2
				jsr .__StartUpdateCH1
.skip2				
				bit #$08
				beq .skip3
				jsr .__StopUpdateCH1
.skip3				
				bit #$10
				beq .skip4
				jsr .__ResetUpdateCH1
.skip4				
				bit #$20
				beq .skip5
				jsr .__VolUpdateCH1
.skip5				
				bit #$40
				beq .skip6
				jsr .__PanUpdateCH1
.skip6				
				bit #$80
				beq .out
				jsr .__FreqUpdateCH1

.out				
				stz ChanState+1
.done
			rts
			
.__PointerUpdateCH1:
				ldx ChanBuffer+2+11					
				stx CHN1.ptr
				ldx ChanBuffer+3+11					
				stx CHN1.ptr+1
				ldx ChanBuffer+4+11				
				stx CHN1.bnk
			rts


.__LoopUpdateCH1:				
				ldx ChanBuffer+5+11			
				stx Ch1LoopAddr
				ldx ChanBuffer+6+11				
				stx Ch1LoopAddr+1
				ldx ChanBuffer+7+11			
				stx Ch1LoopBank
			rts

.__StartUpdateCH1:				

				ldx #CHN1.on
				stx CHN1.mode
				ldx #$01
				stx CHN1.brn
			rts

.__StopUpdateCH1:				
				ldx #CHN1.off				
				stx CHN1.mode
				ldx #CHN1.skip
				stx CHN1.brn
			rts

.__ResetUpdateCH1:				
				stz CHN1.Plo
				stz CHN1.Phi
			rts

.__VolUpdateCH1:
				ldx #$01
				stx $800
				ldx ChanBuffer+11	
				stx $804			
			rts

.__PanUpdateCH1:				
				ldx #$01
				stx $800
				ldx ChanBuffer+1+11	
				stx $805			
			rts

.__FreqUpdateCH1:				

				ldx ChanBuffer+10+11				
				stx CHN1.hi
				ldx ChanBuffer+9+11					
				stx CHN1.mid
				ldx ChanBuffer+8+11					
				stx CHN1.lo
			rts

;//.............................
__UpdateChannel_2
				tst #$04,__internalUpdateCH
				bne	.done
				lda ChanState+2
				beq .done
				bit #$01
				beq .skip0
				jsr .__PointerUpdateCH2
.skip0
				bit #$02
				beq .skip1
				jsr .__LoopUpdateCH2
.skip1
				bit #$04
				beq .skip2
				jsr .__StartUpdateCH2
.skip2				
				bit #$08
				beq .skip3
				jsr .__StopUpdateCH2
.skip3				
				bit #$10
				beq .skip4
				jsr .__ResetUpdateCH2
.skip4				
				bit #$20
				beq .skip5
				jsr .__VolUpdateCH2
.skip5				
				bit #$40
				beq .skip6
				jsr .__PanUpdateCH2
.skip6				
				bit #$80
				beq .out
				jsr .__FreqUpdateCH2

.out				
				stz ChanState+2
.done
			rts
			
.__PointerUpdateCH2:
				ldx ChanBuffer+2+22					
				stx CHN2.ptr
				ldx ChanBuffer+3+22					
				stx CHN2.ptr+1
				ldx ChanBuffer+4+22					
				stx CHN2.bnk
			rts


.__LoopUpdateCH2:				
				ldx ChanBuffer+5+22					
				stx Ch2LoopAddr
				ldx ChanBuffer+6+22				
				stx Ch2LoopAddr+1
				ldx ChanBuffer+7+22				
				stx Ch2LoopBank
			rts

.__StartUpdateCH2:				

				ldx #CHN2.on
				stx CHN2.mode
				ldx #$02
				stx CHN2.brn
			rts

.__StopUpdateCH2:				
				ldx #CHN2.off				
				stx CHN2.mode
				ldx #CHN2.skip
				stx CHN2.brn
			rts

.__ResetUpdateCH2:				
				stz CHN2.Plo
				stz CHN2.Phi
			rts

.__VolUpdateCH2:
				ldx #$02
				stx $800
				ldx ChanBuffer+22
				stx $804			
			rts

.__PanUpdateCH2:				
				ldx #$02
				stx $800
				ldx ChanBuffer+1+22	
				stx $805			
			rts

.__FreqUpdateCH2:				

				ldx ChanBuffer+10+22				
				stx CHN2.hi
				ldx ChanBuffer+9+22					
				stx CHN2.mid
				ldx ChanBuffer+8+22					
				stx CHN2.lo
			rts

;//.............................
__UpdateChannel_3
				tst #$08,__internalUpdateCH
				bne	.done
				lda ChanState+3
				beq .done
				bit #$01
				beq .skip0
				jsr .__PointerUpdateCH3
.skip0
				bit #$02
				beq .skip1
				jsr .__LoopUpdateCH3
.skip1
				bit #$04
				beq .skip2
				jsr .__StartUpdateCH3
.skip2				
				bit #$08
				beq .skip3
				jsr .__StopUpdateCH3
.skip3				
				bit #$10
				beq .skip4
				jsr .__ResetUpdateCH3
.skip4				
				bit #$20
				beq .skip5
				jsr .__VolUpdateCH3
.skip5				
				bit #$40
				beq .skip6
				jsr .__PanUpdateCH3
.skip6				
				bit #$80
				beq .out
				jsr .__FreqUpdateCH3

.out				
				stz ChanState+3
.done
			rts
			
.__PointerUpdateCH3:
				ldx ChanBuffer+2+33					
				stx CHN3.ptr
				ldx ChanBuffer+3+33					
				stx CHN3.ptr+1
				ldx ChanBuffer+4+33					
				stx CHN3.bnk
			rts


.__LoopUpdateCH3:				
				ldx ChanBuffer+5+33					;Ch3LoopAddr
				stx Ch3LoopAddr
				ldx ChanBuffer+6+33					;Ch3LoopAddr+1
				stx Ch3LoopAddr+1
				ldx ChanBuffer+7+33					;Ch3LoopBank
				stx Ch0LoopBank
			rts

.__StartUpdateCH3:				

				ldx #CHN3.on
				stx CHN3.mode
				ldx #$03
				stx CHN3.brn
			rts

.__StopUpdateCH3:				
				ldx #CHN3.off				
				stx CHN3.mode
				ldx #CHN3.skip
				stx CHN3.brn
			rts

.__ResetUpdateCH3:				
				stz CHN3.Plo
				stz CHN3.Phi
			rts

.__VolUpdateCH3:
				ldx #$03
				stx $800
				ldx ChanBuffer+33
				stx $804			
			rts

.__PanUpdateCH3:				
				ldx #$03
				stx $800
				ldx ChanBuffer+1+33
				stx $805			
			rts

.__FreqUpdateCH3:				

				ldx ChanBuffer+10+33					
				stx CHN3.hi
				ldx ChanBuffer+9+33						
				stx CHN3.mid
				ldx ChanBuffer+8+33						
				stx CHN3.lo
			rts

;//.............................
__UpdateChannel_4
				tst #$10,__internalUpdateCH
				bne	.done
				lda ChanState+4
				beq .done
				bit #$01
				beq .skip0
				jsr .__PointerUpdateCH4
.skip0
				bit #$04
				beq .skip2
				jsr .__StartUpdateCH4
.skip2				
				bit #$08
				beq .skip3
				jsr .__StopUpdateCH4
.skip3				
				bit #$20
				beq .skip5
				jsr .__VolUpdateCH4
.skip5				
				bit #$40
				beq .skip6
				jsr .__PanUpdateCH4
.skip6				

.out				
				stz ChanState+4
.done
			rts
			
.__PointerUpdateCH4:
				ldx ChanBuffer+2+44					
				stx CHN4.ptr
				ldx ChanBuffer+3+44					
				stx CHN4.ptr+1
				ldx ChanBuffer+4+44					
				stx CHN4.bnk
			rts

.__StartUpdateCH4:				

				ldx #CHN4.on
				stx CHN4.mode
				ldx #$04
				stx CHN4.brn
			rts

.__StopUpdateCH4:				
				ldx #CHN4.off				
				stx CHN4.mode
				ldx #CHN4.skip
				stx CHN4.brn
			rts

.__VolUpdateCH4:
				ldx #$04
				stx $800
				ldx ChanBuffer+44
				stx $804			
			rts

.__PanUpdateCH4:				
				ldx #$04
				stx $800
				ldx ChanBuffer+1+44
				stx $805			
			rts


;//.............................
__UpdateChannel_5
				tst #$20,__internalUpdateCH
				bne	.done
				lda ChanState+5
				beq .done
				bit #$01
				beq .skip0
				jsr .__PointerUpdateCH5
.skip0
				bit #$04
				beq .skip2
				jsr .__StartUpdateCH5
.skip2				
				bit #$08
				beq .skip3
				jsr .__StopUpdateCH5
.skip3				
				bit #$20
				beq .skip5
				jsr .__VolUpdateCH5
.skip5				
				bit #$40
				beq .skip6
				jsr .__PanUpdateCH5
.skip6				

.out				
				stz ChanState+5
.done
			rts
			
.__PointerUpdateCH5:
				ldx ChanBuffer+2+55					;CHN5.ptr
				stx CHN5.ptr
				ldx ChanBuffer+3+55					;CHN5.ptr+1
				stx CHN5.ptr+1
				ldx ChanBuffer+4+55					;CHN5.bnk
				stx CHN5.bnk
			rts

.__StartUpdateCH5:				

				ldx #CHN5.on
				stx CHN5.mode
				ldx #$05
				stx CHN5.brn
			rts

.__StopUpdateCH5:				
				ldx #CHN5.off				
				stx CHN5.mode
				ldx #CHN5.skip
				stx CHN5.brn
			rts

.__VolUpdateCH5:
				ldx #$05
				stx $800
				ldx ChanBuffer+55
				stx $804			
			rts

.__PanUpdateCH5:				
				ldx #$05
				stx $800
				ldx ChanBuffer+1+55
				stx $805			
			rts


;//end sub	


CONTROL_END:

control_sizefo = CONTROL_END - CONTROL_START

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


