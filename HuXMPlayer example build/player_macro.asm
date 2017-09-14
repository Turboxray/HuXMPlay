
;......................................................

StopChannel_0 .macro

				lda #$08
				tsb Ch0State
				;lda #CHN0.off				
				;sta CHN0.mode
				;lda #CHN0.skip
				;sta CHN0.brn
				
	.endm

StopChannel_1 .macro

				lda #CHN1.off				
				sta CHN1.mode
				lda #CHN1.skip
				sta CHN1.brn
	.endm

StopChannel_2 .macro

				lda #CHN2.off				
				sta CHN2.mode
				lda #CHN2.skip
				sta CHN2.brn
	.endm

StopChannel_3 .macro

				lda #CHN3.off				
				sta CHN3.mode
				lda #CHN3.skip
				sta CHN3.brn
	.endm

StopChannel_4 .macro

				lda #CHN4.off				
				sta CHN4.mode
				lda #CHN4.skip
				sta CHN4.brn
	.endm

StopChannel_5 .macro

				lda #CHN5.off				
				sta CHN5.mode
				lda #CHN5.skip
				sta CHN5.brn
	.endm



;......................................................

SetSampleChannel_0 .macro
				
				ldy #bank(\1)
				;sta CHN0.bnk
				ldx #low(\1)
				;sta CHN0.ptr
				lda #high(\1)
				and #$1f
				ora #$a0
				;sta CHN0.ptr+1
				
				jsr LoadSampleCh0
				
				
				
	.endm

SetSampleChannel_1 .macro
				lda #bank(\1)
				sta CHN1.bnk
				lda #low(\1)
				sta CHN1.ptr
				lda #high(\1)
				and #$1f
				ora #$c0
				sta CHN1.ptr+1
	.endm

SetSampleChannel_2 .macro
				lda #bank(\1)
				sta CHN2.bnk
				lda #low(\1)
				sta CHN2.ptr
				lda #high(\1)
				and #$1f
				ora #$c0
				sta CHN2.ptr+1
	.endm

SetSampleChannel_3 .macro
				lda #bank(\1)
				sta CHN3.bnk
				lda #low(\1)
				sta CHN3.ptr
				lda #high(\1)
				and #$1f
				ora #$c0
				sta CHN3.ptr+1
	.endm

SetSampleChannel_4 .macro
				lda #bank(\1)
				sta CHN4.bnk
				lda #low(\1)
				sta CHN4.ptr
				lda #high(\1)
				and #$1f
				ora #$c0
				sta CHN4.ptr+1
	.endm

SetSampleChannel_5 .macro
				lda #bank(\1)
				sta CHN5.bnk
				lda #low(\1)
				sta CHN5.ptr
				lda #high(\1)
				and #$1f
				ora #$c0
				sta CHN5.ptr+1
	.endm
	

;......................................................

StartChannel_0 .macro
				lda #$04
				tsb Ch0State
				
				;lda #CHN0.on
				;sta CHN0.mode
				;lda #$00
				;sta CHN0.brn
				;stz CHN0.Plo
				;stz CHN0.Phi
	.endm

StartChannel_1 .macro
				
				lda #CHN1.on
				sta CHN1.mode
				lda #$01
				sta CHN1.brn
				stz CHN1.Plo
				stz CHN1.Phi
	.endm

StartChannel_2 .macro
				
				lda #CHN2.on
				sta CHN2.mode
				lda #$02
				sta CHN2.brn
				stz CHN2.Plo
				stz CHN2.Phi
	.endm

StartChannel_3 .macro
				
				lda #CHN3.on
				sta CHN3.mode
				lda #$03
				sta CHN3.brn
				stz CHN3.Plo
				stz CHN3.Phi
	.endm

StartChannel_4 .macro
				
				lda #CHN4.on
				sta CHN4.mode
				lda #$04
				sta CHN4.brn
	.endm

StartChannel_5 .macro
				
				lda #CHN5.on
				sta CHN5.mode
				lda #$05
				sta CHN5.brn
	.endm

;......................................................

ResumeChannel_0 .macro
				
				lda #CHN0.on
				sta CHN0.mode
				lda #$00
				sta CHN0.brn				
	.endm

ResumeChannel_1 .macro
				
				lda #CHN1.on
				sta CHN1.mode
				lda #$01
				sta CHN1.brn
	.endm

ResumeChannel_2 .macro
				
				lda #CHN2.on
				sta CHN2.mode
				lda #$02
				sta CHN2.brn
	.endm

ResumeChannel_3 .macro
				
				lda #CHN3.on
				sta CHN3.mode
				lda #$03
				sta CHN3.brn
	.endm

ResumeChannel_4 .macro
				
				lda #CHN4.on
				sta CHN4.mode
				lda #$04
				sta CHN4.brn
	.endm

ResumeChannel_5 .macro
				
				lda #CHN5.on
				sta CHN5.mode
				lda #$05
				sta CHN5.brn
	.endm

;......................................................

SetFreqChannel_0 .macro

				lda #low(\2)
				sta CHN0.lo
				lda #high(\2)
				sta CHN0.mid
				lda #(\1)
				sta CHN0.hi

	.endm

SetFreqChannel_1 .macro

				lda #low(\2)
				sta CHN1.lo
				lda #high(\2)
				sta CHN1.mid
				lda #(\1)
				sta CHN1.hi

	.endm


SetFreqChannel_2 .macro

				lda #low(\2)
				sta CHN2.lo
				lda #high(\2)
				sta CHN2.mid
				lda #(\1)
				sta CHN2.hi

	.endm


SetFreqChannel_3 .macro

				lda #low(\2)
				sta CHN3.lo
				lda #high(\2)
				sta CHN3.mid
				lda #(\1)
				sta CHN3.hi

	.endm



;......................................................

SetChannelNote_0 .macro

				.if (\#=1)
				lda \1
				ora #$C0
				.endif

				.if (\#=2)
				lda \1
				ldx \2
				ora #$80
				.endif

				
				.if (\#=3)
				lda \1
				ldx \2
				ldy \3				
				.endif

				jsr _SetChanFreq_0

	.endm



;......................................................
SetChannelVol_0	.macro
				lda	\1
				and #$1f
				ora #$c0
				sta Ch0Buffer
				lda #$01
				tsb Ch0State
	.endm


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
				Call_far UpdatePCMChannels
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
				Call_far UpdatePCMChannels
				stz $c01
				stz $1403
				lda #$01
				sta $c01
	.endm


Call_far	.macro
				tma #$03
				pha
				
				lda #bank(\1)
				tam #page(\1)
				jsr \1
				
				pla
				tam #$03
	
	.endm

Call_far_doublebank	.macro
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



testmem .macro
	.bss
	mem1:	.ds 1
	.code
	.endm