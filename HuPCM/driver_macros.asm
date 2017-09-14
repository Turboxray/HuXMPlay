;......................................................
InitialRegs	.macro
				stz __ExtendedFlag
				stz ChanState+0
				stz ChanState+1
				stz ChanState+2
				stz ChanState+3
				stz ChanState+4
				stz ChanState+5
				stz <DDAprocessing
				stz __internalUpdateCH		
				stz __UpdateProcFlag		
	.endm

;......................................................
InitializeRamDriver_FarDouble	.macro
				tma #( (\2 & $ffff) / $2000)
				pha
				tma #( (\2 & $ffff) / $2000)+1
				pha
				
				lda #bank(\1)
				tam #( (\2 & $ffff) / $2000)
				inc a
				tam #( (\2 & $ffff) / $2000)+1
				
				tii #(\1 & $1fff) + (((\2 & $ffff) / $2000)* $2000),#\3,#\4
				
				pla
				tam #( (\2 & $ffff) / $2000)+1
				pla
				tam #( (\2 & $ffff) / $2000)
	.endm

InitializeRamDriver_FarSingle	.macro
				tma #( (\2 & $ffff) / $2000)
				pha
				
				lda #bank(\1)
				tam #( (\2 & $ffff) / $2000)
				
				tii #(\1 & $1fff) + (((\2 & $ffff) / $2000)* $2000),#\3,#\4
				
				pla
				tam #( (\2 & $ffff) / $2000)
	.endm

InitializeRamDriver	.macro
				
				tii \1,\2,\3
	.endm
	
	
	
;......................................................
HaltUpdateChan_0	.macro
				lda #$01
				tsb __internalUpdateCH
	.endm

HaltUpdateChan_1	.macro
				lda #$02
				tsb __internalUpdateCH
	.endm
	

HaltUpdateChan_2	.macro
				lda #$04
				tsb __internalUpdateCH
	.endm
	

HaltUpdateChan_3	.macro
				lda #$08
				tsb __internalUpdateCH
	.endm
	

HaltUpdateChan_4	.macro
				lda #$10
				tsb __internalUpdateCH
	.endm
	
HaltUpdateChan_5	.macro
				lda #$20
				tsb __internalUpdateCH
	.endm

;......................................................
ResumeUpdateChan_0	.macro
				lda #$fe
				trb __internalUpdateCH
	.endm
	
ResumeUpdateChan_1	.macro
				lda #$fd
				trb __internalUpdateCH
	.endm
	
ResumeUpdateChan_2	.macro
				lda #$fb
				trb __internalUpdateCH
	.endm
	
ResumeUpdateChan_3	.macro
				lda #$f7
				trb __internalUpdateCH
	.endm
	
ResumeUpdateChan_4	.macro
				lda #$ef
				trb __internalUpdateCH
	.endm
	
ResumeUpdateChan_5	.macro
				lda #$df
				trb __internalUpdateCH
	.endm
	

;......................................................
SetGlobalVol .macro
				.if (\#=1)
				lda \1
				sta __GlobalVol
				lda #1
				tsb __ExtendedFlag
				.endif

				.if (\#=2)
				lda \1
				asl a
				asl a
				asl a
				asl a
				sta __GlobalVol
				lda \2
				and #$0f
				tsb __GlobalVol
				lda #1
				tsb __ExtendedFlag
				.endif
	.endm
				
;......................................................

EnablePCMDriver	.macro

				lda #$02
				tsb __ExtendedFlag


	.endm

PausePCMDriver	.macro

				lda #$04
				tsb __ExtendedFlag


	.endm

ResumePCMDriver	.macro

				lda #$02
				tsb __ExtendedFlag


	.endm


;......................................................
StopChannel_IX .macro
				lda ChanState,x
				ora #$08
				sta ChanState,x
	.endm

StopChannel_0 .macro
				lda ChanState+0
				ora #$08
				sta ChanState+0
	.endm

StopChannel_1 .macro

				lda ChanState+1
				ora #$08
				sta ChanState+1
				
	.endm

StopChannel_2 .macro

				lda ChanState+2
				ora #$08
				sta ChanState+2
				
	.endm

StopChannel_3 .macro

				lda ChanState+3
				ora #$08
				sta ChanState+3
				
	.endm

StopChannel_4 .macro

				lda ChanState+4
				ora #$08
				sta ChanState+4
				
	.endm

StopChannel_5 .macro

				lda ChanState+5
				ora #$08
				sta ChanState+5
				
	.endm



;......................................................

SetSampleChannel .macro
					jsr LoadSample	
	.endm

SetSampleChannel_0 .macro
				
	.if (\#==1)
				lda #0
				sta ChanSelect
				ldy #bank(\1)
				ldx #low(\1)
				lda #high(\1)
				and #$1f
				ora #$a0
				jsr LoadSample
	.endif
	
	.if (\#==0)
				lda #0
				sta ChanSelect
				jsr LoadSample	
	.endif
	.endm

SetSampleChannel_1 .macro

	.if (\#==1)
				lda #1
				sta ChanSelect
				ldy #bank(\1)
				ldx #low(\1)
				lda #high(\1)
				and #$1f
				ora #$a0
				jsr LoadSample
	.endif
	.if (\#==0)
				lda #1
				sta ChanSelect
				jsr LoadSample	
	.endif
								
	.endm

SetSampleChannel_2 .macro

	.if (\#==1)
				lda #2
				sta ChanSelect
				ldy #bank(\1)
				ldx #low(\1)
				lda #high(\1)
				and #$1f
				ora #$a0
				jsr LoadSample
	.endif
	.if (\#==0)
				lda #2
				sta ChanSelect
				jsr LoadSample	
	.endif	
	.endm



SetSampleChannel_3 .macro

	.if (\#==1)
				lda #3
				sta ChanSelect
				ldy #bank(\1)
				ldx #low(\1)
				lda #high(\1)
				and #$1f
				ora #$a0
				jsr LoadSample
	.endif								
	.if (\#==0)
				lda #3
				sta ChanSelect
				jsr LoadSample	
	.endif
	.endm

SetSampleChannel_4 .macro

	.if (\#==1)
				lda #4
				sta ChanSelect
				ldy #bank(\1)
				ldx #low(\1)
				lda #high(\1)
				and #$1f
				ora #$a0
				jsr LoadSample
	.endif
	.if (\#==0)
				lda #4
				sta ChanSelect
				jsr LoadSample	
	.endif
								
	.endm

SetSampleChannel_5 .macro

	.if (\#==1)
				lda #5
				sta ChanSelect
				ldy #bank(\1)
				ldx #low(\1)
				lda #high(\1)
				and #$1f
				ora #$a0
				jsr LoadSample
	.endif								
	.if (\#==0)
				lda #5
				sta ChanSelect
				jsr LoadSample	
	.endif
	.endm
	

;......................................................

StartChannel_IX	.macro
				lda ChanState,x
				ora #$04
				sta ChanState,x
	.endm


StartChannel_0 .macro
				lda ChanState+0
				ora #$04
				sta ChanState+0
				
	.endm

StartChannel_1 .macro
				
				lda ChanState+1
				ora #$04
				sta ChanState+1
				
	.endm

StartChannel_2 .macro
				
				lda ChanState+2
				ora #$04
				sta ChanState+2
				
	.endm

StartChannel_3 .macro
				
				lda ChanState+3
				ora #$04
				sta ChanState+3
				
	.endm

StartChannel_4 .macro
				
				lda ChanState+4
				ora #$04
				sta ChanState+4
				
	.endm

StartChannel_5 .macro
				
				lda ChanState+5
				ora #$04
				sta ChanState+5
				
	.endm

;......................................................

RestartChannel_IX	.macro
				lda ChanState,x
				ora #$17
				sta ChanState,x
	.endm

RestartChannel_0	.macro
				lda ChanState+0
				ora #$17
				sta ChanState+0
	.endm

RestartChannel_1	.macro
				lda ChanState+1
				ora #$17
				sta ChanState+1
	.endm

RestartChannel_2	.macro
				lda ChanState+2
				ora #$17
				sta ChanState+2
	.endm

RestartChannel_3	.macro
				lda ChanState+3
				ora #$17
				sta ChanState+3
	.endm




;......................................................

ResumeChannel_IX .macro
				StartChannel_IX
	.endm
ResumeChannel_0 .macro
				StartChannel_0
	.endm
ResumeChannel_1 .macro
				StartChannel_1
	.endm
ResumeChannel_2 .macro
				StartChannel_2
	.endm
ResumeChannel_3 .macro
				StartChannel_3
	.endm
ResumeChannel_4 .macro
				StartChannel_4
	.endm
ResumeChannel_5 .macro
				StartChannel_5
	.endm
				
;......................................................

SetChannelNote_0 .macro

				.if (\#=1)
				stz ChanSelect
				lda \1
				clx
				cly
				.endif

				.if (\#=2)
				stz ChanSelect
				lda \1
				ldx \2
				cly
				.endif

				
				.if (\#=3)
				stz ChanSelect
				lda \1
				ldx \2
				ldy \3				
				.endif

				jsr _SetChanFreq
	.endm

SetChannelNote_1 .macro

				.if (\#=1)
				lda #1
				sta ChanSelect
				lda \1
				clx
				cly
				.endif

				.if (\#=2)
				lda #1
				sta ChanSelect
				lda \1
				ldx \2
				cly
				.endif

				
				.if (\#=3)
				lda #1
				sta ChanSelect
				lda \1
				ldx \2
				ldy \3				
				.endif

				jsr _SetChanFreq
	.endm
	
SetChannelNote_2 .macro

				.if (\#=1)
				lda #2
				sta ChanSelect
				lda \1
				clx
				cly
				.endif

				.if (\#=2)
				lda #2
				sta ChanSelect
				lda \1
				ldx \2
				cly
				.endif

				
				.if (\#=3)
				lda #2
				sta ChanSelect
				lda \1
				ldx \2
				ldy \3				
				.endif

				jsr _SetChanFreq
	.endm
		
SetChannelNote_3 .macro

				.if (\#=1)
				lda #3
				sta ChanSelect
				lda \1
				clx
				cly
				.endif

				.if (\#=2)
				lda #3
				sta ChanSelect
				lda \1
				ldx \2
				cly
				.endif

				
				.if (\#=3)
				lda #3
				sta ChanSelect
				lda \1
				ldx \2
				ldy \3				
				.endif

				jsr _SetChanFreq
	.endm
	

;......................................................
SetChannelVol_IX	.macro
				and #$1f
				ora #$c0
				ldy __buffer_offset_table,x
				sta ChanBuffer,y
				lda #$20
				ora ChanState,x
				sta ChanState,x
	.endm


SetChannelVol_0	.macro
				lda	\1
				and #$1f
				ora #$c0
				sta ChanBuffer+0
				lda #$20
				tsb ChanState+0
	.endm

SetChannelVol_1	.macro
				lda	\1
				and #$1f
				ora #$c0
				sta ChanBuffer+11
				lda #$20
				tsb ChanState+1
	.endm
	
SetChannelVol_2	.macro
				lda	\1
				and #$1f
				ora #$c0
				sta ChanBuffer+22
				lda #$20
				tsb ChanState+2
	.endm

SetChannelVol_3	.macro
				lda	\1
				and #$1f
				ora #$c0
				sta ChanBuffer+33
				lda #$20
				tsb ChanState+3
	.endm

SetChannelVol_4	.macro
				lda	\1
				and #$1f
				ora #$c0
				sta ChanBuffer+44
				lda #$20
				tsb ChanState+4
	.endm

SetChannelVol_5	.macro
				lda	\1
				and #$1f
				ora #$c0
				sta ChanBuffer+55
				lda #$20
				tsb ChanState+5
	.endm


;......................................................
SetChannelPanVol_IX .macro
				ldy __buffer_offset_table,x
				sta ChanBuffer+1,y
				lda #$40
				ora ChanState,x
				sta ChanState,x

	.endm

SetChannelPanVol_0 .macro
				.if (\#=1)
				lda \1
				sta ChanBuffer+1+0
				lda #$40
				tsb ChanState+0
				.endif

				.if (\#=2)
				lda \1
				asl a
				asl a
				asl a
				asl a
				sta ChanBuffer+1
				lda \2
				and #$0f
				tsb ChanBuffer+1
				lda #$40
				tsb ChanState+0
				.endif
	.endm

SetChannelPanVol_1 .macro
				.if (\#=1)
				lda \1
				sta ChanBuffer+1+11
				lda #$40
				tsb ChanState+1
				.endif

				.if (\#=2)
				lda \1
				asl a
				asl a
				asl a
				asl a
				sta ChanBuffer+1+11
				lda \2
				and #$0f
				tsb ChanBuffer+1+11
				lda #$40
				tsb ChanState+1
				.endif
	.endm

SetChannelPanVol_2 .macro
				.if (\#=1)
				lda \1
				sta ChanBuffer+1+22
				lda #$40
				tsb ChanState+2
				.endif

				.if (\#=2)
				lda \1
				asl a
				asl a
				asl a
				asl a
				sta ChanBuffer+1+22
				lda \2
				and #$0f
				tsb ChanBuffer+1+22
				lda #$40
				tsb ChanState+2
				.endif
	.endm

SetChannelPanVol_3 .macro
				.if (\#=1)
				lda \1
				sta ChanBuffer+1+33
				lda #$40
				tsb ChanState+3
				.endif

				.if (\#=2)
				lda \1
				asl a
				asl a
				asl a
				asl a
				sta ChanBuffer+1+33
				lda \2
				and #$0f
				tsb ChanBuffer+1+33
				lda #$40
				tsb ChanState+3
				.endif
	.endm

SetChannelPanVol_4 .macro
				.if (\#=1)
				lda \1
				sta ChanBuffer+1+44
				lda #$40
				tsb ChanState+4
				.endif

				.if (\#=2)
				lda \1
				asl a
				asl a
				asl a
				asl a
				sta ChanBuffer+1+44
				lda \2
				and #$0f
				tsb ChanBuffer+1+44
				lda #$40
				tsb ChanState+4
				.endif
	.endm

SetChannelPanVol_5 .macro
				.if (\#=1)
				lda \1
				sta ChanBuffer+1+55
				lda #$40
				tsb ChanState+5
				.endif

				.if (\#=2)
				lda \1
				asl a
				asl a
				asl a
				asl a
				sta ChanBuffer+1+55
				lda \2
				and #$0f
				tsb ChanBuffer+1+55
				lda #$40
				tsb ChanState+5
				.endif
	.endm



;......................................................
ProcessPCM7_0khz_local .macro
				jsr UpdatePCMChannels
				stz $c01
				stz $1403
				lda #$01
				sta $c01
				lda #high(.return)
				pha
				lda #low(.return)
				pha
				php
				jmp PCM_DRIVER			
.return
	.endm

ProcessPCM6_9khz_local .macro
				jsr UpdatePCMChannels
				stz $c01
				stz $1403
				lda #$01
				sta $c01
	.endm

ProcessPCM7_0khz_far .macro
				__Call_far UpdatePCMChannels
				stz $c01
				stz $1403
				lda #$01
				sta $c01
				lda #high(.return)
				pha
				lda #low(.return)
				pha
				php
				jmp PCM_DRIVER			
.return
	.endm

ProcessPCM6_9khz_far .macro
				__Call_far UpdatePCMChannels
				stz $c01
				stz $1403
				lda #$01
				sta $c01
	.endm


__Call_far	.macro
				tma #$03
				pha
				
				lda #bank(\1)
				tam #page(\1)
				jsr \1
				
				pla
				tam #$03
	
	.endm

__Call_far_doublebank	.macro
				tma #page(\1)
				pha
				tma #page(\1)+1
				pha
				
				lda #bank(\1)
				tam #page(\1)
				inc a
				tam #page(\1)+1
				jsr \1
				
				pla
				tam #page(\1)+1
				pla
				tam #page(\1)
	
	.endm

;......................................................

SampleStateCh_0	.macro
				lda CHN0.mode
				cmp #$80
	.endm

SampleStateCh_1	.macro
				lda CHN1.mode
				cmp #$80
	.endm

SampleStateCh_2 .macro
				lda CHN2.mode
				cmp #$80
	.endm

SampleStateCh_3	.macro
				lda CHN3.mode
				cmp #$80
	.endm

SampleStateCh_4	.macro
				lda CHN4.mode
				cmp #$80
	.endm

SampleStateCh_5	.macro
				lda CHN5.mode
				cmp #$80
	.endm

;......................................................
ProcessingState .macro
				tst #$01, __UpdateProcFlag
	.endm

;......................................................

AssignInternalPointer	.macro
DriverPtr = \1
DriverPtr.l = DriverPtr
DriverPtr.h = DriverPtr+1
	.endm
	
	