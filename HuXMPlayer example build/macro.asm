VDC1	.macro			;hardware I/O page must be mapped to the first bank

	stz $000E

	.endm


VDC2	.macro			;hardware I/O page must be mapped to the first bank

	inc $000E

	.endm

MAWR_ADDR .macro
	st0 #$00
	st1 #LOw(\1)
	st2 #HIGH(\1)

	.endm

MARR_ADDR .macro
	st0 #$01
	st1 #LOw(\1)
	st2 #HIGH(\1)

	.endm

VDC_DATA .macro
	st0 #$02

	.endm

VDC_REG	 .macro

	.if	(\?2=1)
	st0 #\1
	sta $0002
	stz $0003
	.endif
	
	.if	(\#=1)
	st0 #\1
	.endif

	.if	(\#=2 & \?2 != 1)
	st0 #\1
	st1 #LOW(\2)	
	st2 #HIGH(\2)
	 .endif

	.if	(\#=3 & \?3 != 1)
	st0 #\1
	lda \2
	sta $0002
	lda \3
	sta $0003
	.endif

	.endm

VDC2_REG .macro				;macro for SuperGrafx

	.if	(\?2=1)
	st0 #\1
	sta $0012
	stz $0013
	.endif
	
	.if	(\#=1)
	st0 #\1
	.endif

	.if	(\#=2 & \?2 != 1)
	st0 #\1
	st1 #LOW(\2)	
	st2 #HIGH(\2)
	 .endif

	.if	(\#=3 & \?3 != 1)
	st0 #\1
	lda \2
	sta $0012
	lda \3
	sta $0013
	.endif

	.endm

LOAD_RCR .macro

	st0 #RCR	
	lda \1
	clc
	adc #$40
	sta $0002
	lda \1+1
	adc #$00
	sta $0003

	.endm

UPDATE_RCR .macro		;this is for special H-line parallax scroll routine
				; - destroys REG A
	st0 #RCR
	sta $0002
	lda <RCR_MSB
	sta $0003

	 .endm

WRT_PORT .macro

	 st1 #LOW(\1)	
	 st2 #HIGH(\1)

	.endm

STWYA_PORT .macro

	 sta $0002
	 sty $0003

	.endm

STWYA_PORT_2 .macro

	 sta $0012
	 sty $0013

	.endm


BG_COLOR .macro

	lda #(\1)
	sta $402
	stz $403

	.endm

VCE_REG .macro

	lda #(\1)
	sta $400

	.endm



	

INC_BIT .macro

	lda \1
	inc a
	and #$01
	sta \1

	.endm

IRQ_CNTR	 .macro

	lda #\1
	sta $1402
	
	.endm

VREG_Select .macro

	st0 #\1
	lda #\1
	sta <vdc_reg
	
	.endm


sVDC_REG	 .macro

	.if	(\?2=1)
	lda #\1
	sta <vdc_reg
	st0 #\1
	sta $0002
	stz $0003
	.endif
	
	.if	(\#=1)
	lda #\1
	sta <vdc_reg
	st0 #\1
	.endif

	.if	(\#=2 & \?2 != 1)
	lda #\1
	sta <vdc_reg
	st0 #\1
	st1 #LOW(\2)	
	st2 #HIGH(\2)
	 .endif

	.if	(\#=3 & \?3 != 1)
	lda #\1
	sta <vdc_reg
	st0 #\1
	lda \2
	sta $0002
	lda \3
	sta $0003
	.endif

	.endm

iVDC_PORT	 .macro

	st1 #LOW(\1)	
	st2 #HIGH(\1)

	.endm

sVDC_INC	 .macro

	lda #$05
	sta <vdc_reg
	st0 #$05
	st2 #\1

	.endm
	
TIMER_REG		.macro
		lda #\2
		sta \1
	.endm
;................................................
CALL .macro

	jsr \1

	.endm
	
CallFar	.macro
				tma #$03
				pha
				
				lda #bank(\1)
				tam #page(\1)
				jsr \1
				
				pla
				tam #$03
	
	.endm

CallFarDoubleBank	.macro
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

CallFarWide	.macro
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


;................................................
CLEAR_REGS .macro

	cla
	cly
	clx

	.endm

PUSH_R .macro
	
	pha
	phy
	phx

	.endm

PULL_R .macro

	plx
	ply
	pla

	.endm

;................................................
MAP_BANK		.macro				;8k

	.if (\?1=2)
	lda #bank(\1)
	tam #(\2)
	.endif
	
	.if (\?1=3)
	lda \1
	tam #(\2)
	.endif

	.if (\?1=6)
	lda \1
	tam #(\2)
	.endif

	.if (\?1=1)
	tam #(\2)
	.endif
	
	.endm
	
MAP_BANK_WIDE		.macro		;16k
	
	.if (\?1=2)
	lda #bank(\1)
	tam #(\2)
	inc a
	tam #(\2+1)
	.endif
	
	.if (\?1=3)
	lda \1
	tam #(\2)
	inc a
	tam #(\2+1)
	.endif

	.if (\?1=6)
	lda \1
	tam #(\2)
	inc a
	tam #(\2+1)
	.endif

	.if (\?1=1)
	tam #(\2)
	inc a
	tam #(\2+1)
	.endif
	
	.endm

MAP_BANK_LONG		.macro		;24k

	lda #bank(\1)
	tam #(\2)
	inc a
	tam #(\2+1)
	inc a
	tam #(\2+2)
	
	.endm

MAP_BANK_XLONG		.macro	;32k

	lda #bank(\1)
	tam #(\2)
	inc a
	tam #(\2+1)
	inc a
	tam #(\2+2)
	inc a
	tam #(\2+3)
	
	.endm


;................................................
LEA		.macro

	lda #low(\1)
	sta <(\3)
	lda #high((\1 & $1fff)+ \2)
	sta <(\3+1)

	.endm	

LEA_l			.macro

	lda #low(\1)
	sta (\3)
	lda #high((\1 & $1fff)+ \2)
	sta (\3+1)
	lda #bank(\1)
	sta (\3+2)
	.endm	


LEB			.macro

	lda #bank(\1)
	sta (\2)

	.endm	


;................................................
INCW		.macro
			inc \1
			bne .x_\@
			inc \1+1
.x_\@
	.endm


;//................................................
;// MOVE macros

;......................
; MOVE.byte source, destination
MOVE_b	.macro
	.if (\#=0)
	.fail Macro requires two arguments
	.endif
	
	.if (\#=1)
	.fail Macro requires two arguments
	.endif
	
	.if (\#>2)
	.fail Macro requires two arguments
	.endif


	.if (\?1=2)
	lda \1
	sta \2
	.endif
	
	.if (\?1=3)
	lda \1
	sta \2
	.endif
	
	.if (\?1=4)
	lda \1
	sta \2
	.endif
	
	.if (\?1=6)
	lda \1
	sta \2
	.endif

;	.if (\?1=5)
;		.if (\5='Acc')
;		sta \2
;		.endif	
;		.if (\5='IX')
;		stx \2
;		.endif	
;		.if (\5='IY')
;		sty \2
;		.endif	
;	.endif
	
	.endm

;......................
; MOVE.byte source, destination
MOVE_b_w	.macro
	.if (\#=0)
	.fail Macro requires two arguments
	.endif
	
	.if (\#=1)
	.fail Macro requires two arguments
	.endif
	
	.if (\#>2)
	.fail Macro requires two arguments
	.endif

	.if (\?2=2)
	.fail destination cannot be an immediate
	.endif

	.if (\?2=1)
	.fail destination cannot be a huc6280 register
	.endif

	.if (\?2=5)
	.fail destination cannot be a 'string'
	.endif

	
	.if (\?2=3)
			lda \1
			sta \2
			lda #$00
			sta \2+1
	.endif
	
	.if (\?2=4)
			lda \1
			sta \2
			lda #$00
			ldy #$01
			sta \2,y
	.endif
	
	.if (\?2=6)
			lda \1
			sta \2
			lda #$00
			sta \2+1
	.endif
	
	
	.endm


;......................
; MOVE.word source, destination
MOVEA_b	.macro
	;.fail \?1
	.if (\#=0)
	.fail Macro requires one arguments
	.endif
	
	
	.if (\#>1)
	.fail Macro requires one arguments
	.endif
	
	
	.if (\?1=1)
	.fail Cannot use A,X, or Y registers as source
	.endif

	;source=#
	.if (\?1=2)
	lda #low(\1)
	.endif

	;source=full ADDR
	.if (\?1=3)
	lda \1
	.endif

	;source=indirect
	.if (\?1=4)
	lda \1
	.endif

	;source=string
	.if (\?1=5)
	.fail Can't use strings as arguments.
	.endif

	;source=label as direct address
	.if (\?1=6)
	lda \1
	.endif
	
	
	.endm

;......................
; MOVE.word source, destination
MOVE_w	.macro
	;.fail \?1
	.if (\#=0)
	.fail Macro requires two arguments
	.endif
	
	.if (\#=1)
	.fail Macro requires two arguments
	.endif
	
	.if (\#>2)
	.fail Macro requires two arguments
	.endif
	
	
	.if (\?1=1)
	.fail Cannot use A,X, or Y registers as source
	.endif

	;source=#
	.if (\?1=2)
	lda #low(\1)
	sta \2
	lda #high(\1)
	sta \2+1
	.endif

	;source=full ADDR
	.if (\?1=3)
	lda \1
	sta \2
	lda \1+1
	sta \2+1
	.endif

	;source=indirect
	.if (\?1=4)
	lda \1
	sta \2
	phy
	ldy #$01
	lda \1,y
	ply
	sta \2+1
	.endif

	;source=string
	.if (\?1=5)
	.fail Can't use strings as arguments.
	.endif

	;source=label as direct address
	.if (\?1=6)
	lda \1
	sta \2
	lda \1+1
	sta \2+1
	.endif
	
	
	.endm

;......................
; MOVE.word source, destination
MOVE_w_add	.macro
	
	.if (\#<3)
	.fail Macro requires three arguments
	.endif
	
	.if (\#>3)
	.fail Macro requires three arguments
	.endif
	
	
	.if (\?1=1)
	.fail Cannot use A,X, or Y registers as source
	.endif

	;source=#
	.if (\?1=2)
	lda #low(\1+\3)
	sta \2
	lda #high(\1+\3)
	sta \2+1
	.endif

	;source=full ADDR
	.if (\?1=3)
	lda \1
	clc
	adc #low(\3)
	sta \2
	lda \1+1
	adc #high(\3)
	sta \2+1
	.endif

	;source=indirect
	.if (\?1=4)
	lda \1
	clc
	adc #low(\3)
	sta \2
	phy
	ldy #$01
	lda \1,y
	adc #high(\3)
	ply
	sta \2+1
	.endif

	;source=string
	.if (\?1=5)
	.fail Can't use strings as arguments.
	.endif

	;source=label as direct address
	.if (\?1=6)
	lda \1
	clc
	adc #low(\3)
	sta \2
	lda \1+1
	adc #high(\3)
	sta \2+1
	.endif
	
	
	.endm


;......................
; MOVE.X.byte source, destination
MOVE_X_b	.macro
	ldx \1
	sta \2
	.endm

;......................
; MOVE.Y.byte source, destination
MOVE_Y_b	.macro
	ldy \1
	sta \2
	.endm

;......................
; MOVE.IY.byte source, destination
MOVE_IY_b	.macro
	lda \1
	sta \2
	iny
	.endm

;......................
; MOVE.IY.byte source, destination
MOVE_DY_b	.macro
	lda \1
	sta \2
	dey
	.endm

;......................
; MOVE.AX A:X, destination
MOVE_AX	.macro
	sta \1
	stx \1+1
	
	.endm

;......................
; MOVE.AY A:Y, destination
MOVE_AY	.macro
	sta \1
	sty \1+1
	
	.endm

;......................
; MOVE.XY X:Y, destination
MOVE.XY	.macro
	stx \1
	sty \1+1
	
	.endm


;//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;//..............................................
;//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;// Old move macros
MOVEA_r		.macro
		lda (\1)
		sta <(\2)
		lda (\1+1)
		sta <(\2+1)
	.endm

MOVEA_r_l		.macro
		lda \1
		sta \2
		lda \1+1
		sta \2+1
		lda \1+2
		sta \2+2
	.endm
	
MOVEB		.macro
	.if (\?1=4)
	
		lda \1
		sta \2
	.endif
	
	.if (\?1=3)
		lda \1
		sta \2
	.endif
	
	.if (\?1=2)
		lda \1
		sta \2
	.endif

	.if (\?1=6)
		lda \1
		sta \2
	.endif
		
	.endm

MOVRX		.macro
	.if (\?1=4)
	
		ldx \1
		stx \2
	.endif
	
	.if (\?1=3)
		ldx \1
		stx \2
	.endif
	
	.if (\?1=2)
		ldx \1
		stx \2
	.endif

	.if (\?1=6)
		ldx \1
		stx \2
	.endif

	.if (\?1=1)
		stx \2
	.endif
	
		
	.endm

MOVRA		.macro
	.if (\?1=4)
	
		lda \1
		sta \2
	.endif
	
	.if (\?1=3)
		lda \1
		sta \2
	.endif
	
	.if (\?1=2)
		lda \1
		sta \2
	.endif

	.if (\?1=6)
		lda \1
		sta \2
	.endif

	.if (\?1=1)
		sta \2
	.endif

	.endm

MOVRY		.macro
	.if (\?1=4)
	
		ldy \1
		sty \2
	.endif
	
	.if (\?1=3)
		ldy \1
		sty \2
	.endif
	
	.if (\?1=2)
		ldy #\1
		sty \2
	.endif

	.if (\?1=6)
		ldy \1
		sty \2
	.endif

	.if (\?1=1)
		sty \2
	.endif
	
		
	.endm


MOVEW		.macro
	.if (\?1=4)
	
		lda \1
		sta \2
		ldy #1
		lda \1,y
		sta \2+1
	.endif
	
	.if (\?1=3)
		lda \1
		sta \2
		lda \1+1
		sta \2+1
	.endif
	
	.if (\?1=2)
		lda #low(\1)
		sta \2
		lda #high(\1)
		sta \2+1
	.endif

	.if (\?1=6)
		lda #low(\1)
		sta \2
		lda #high(\1+1)
		sta \2+1
	.endif
		
	.endm


MOVIA_l		.macro

		ldx #\7-1
.x_\@
		lda \1,x
		sta \4,x
		lda \2,x
		sta \5,x
		lda \3,x
		sta \6,x
		dex
		bpl .x_\@
	.endm

MOVI_l		.macro

		lda \1
		sta \2
		lda \1+1
		sta \3
		lda \1+2
		sta \4
	.endm		

MOVE_Y_I	.macro
		ldy \1
	.endm

MOVE_X_I	.macro
		ldx \1
	.endm


;//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
;//..............................................
;//!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

;................................................
DMA_Word_Port		.macro
		tia (\1 & $1fff)+\2,\3,\4
	.endm

DMA_Byte_Port		.macro
		tin (\1 & $1fff)+\2,\3,\4
	.endm

	
DMA_Far_Local		.macro
		tii (\1 & $1fff)+\2,\3,\4
	.endm

DMA_Local		.macro
		tii \1,\2,\3
	.endm

;//................................................
;// ADD macros


;......................
;CMP.word source,destination. 16bit+16bit->16bit
CMP_w		.macro

		;first error checks
			.if (\#<>2)
			.fail Macro requires two arguments
			.endif
			.if (\?2=0)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?2=1)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?2=5)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			
	.if (\?1=2) ;src=#immd
		.if (\?2=2)	;#immd
			lda #low(\1)
			cmp #low(\2)
			lda #high(\1)
			sbc #high(\2)
		.endif

		.if (\?2=3 | \?2=6)
			lda #low(\1)
			cmp \2
			lda #high(\1)
			sbc \2+1
		.endif

		.if (\?2=4)	;indirect dest
			lda #low(\1)
			cmp \2
			ldy #$01
			lda #high(\1)
			sbc \2,y
		.endif
	.endif



	.if (\?1=3 | \?1=6) ;src=addr/label
		.if (\?2=2)	;#immd
			lda \1
			cmp #low(\2)
			lda \1+1
			sbc #high(\2)
		.endif

		.if (\?2=3 | \?2=6)
			lda \1
			cmp \2
			lda \1+1
			sbc \2+1
		.endif

		.if (\?2=4)	;indirect dest
			lda \1
			cmp \2
			ldy #$01
			lda \1+1
			sbc \2,y
		.endif
	.endif

	.if (\?1=4) ;src=indirect
		.if (\?2=2)
			lda \1
			cmp #low(\2)
			ldy #$01
			lda \1,y
			sbc #high(\2)
		.endif

		.if (\?2=3 | \?2=6)
			lda \1
			cmp \2
			ldy #$01
			lda \1,y
			sbc \2+1
		.endif

		.if (\?2=4)	;indirect dest
			lda \1
			cmp \2
			ldy #$01
			lda \1,y
			sbc \2,y
		.endif
	.endif


	.endm


;......................
;CMP.byte arg1, arg2  (8bit,8bit)
CMP.b		.macro

		;first error checks
			.if (\#<>2)
			.fail Macro requires two arguments
			.endif
			.if (\?2=0)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?2=1)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?2=5)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			
	.if (\?1=2) ;src=#immd
		.if (\?2=2)	;#immd
			lda #low(\1)
			cmp #low(\2)
		.endif

		.if (\?2=3 | \?2=6)
			lda #low(\1)
			cmp \2
		.endif

		.if (\?2=4)	;indirect dest
			lda #low(\1)
			cmp \2
		.endif
	.endif



	.if (\?1=3 | \?1=6) ;src=addr/label
		.if (\?2=2)	;#immd
			lda \1
			cmp #low(\2)
		.endif

		.if (\?2=3 | \?2=6)
			lda \1
			cmp \2
		.endif

		.if (\?2=4)	;indirect dest
			lda \1
			cmp \2
		.endif
	.endif

	.if (\?1=4) ;src=indirect
		.if (\?2=2)
			lda \1
			cmp #\2
		.endif

		.if (\?2=3 | \?2=6)
			lda \1
			cmp \2
		.endif

		.if (\?2=4)	;indirect dest
			lda \1
			cmp \2
		.endif
	.endif


	.endm



;//................................................
;// ADD macros

;......................
;ADD.byte source,destination
ADD_b		.macro
		;first error checks
			.if (\#<>2)
			.fail Macro requires two arguments
			.endif
			.if (\?2=0)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?2=1)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?2=2)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?2=5)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?1=5)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?1=1)
			.fail destination must be label, absolute address, or indirect. 1
			.endif

			
	.if (\?1=2) ;src=#immd
		.if (\?2=3 | \?2=6)
			lda \2
			clc
			adc #low(\1)
			sta \2
		.endif

		.if (\?2=4)	;indirect dest
			lda \2
			clc
			adc #low(\1)
			sta \2
		.endif
	.endif

	.if (\?1=3 | \?1=6) ;src=addr/label
		.if (\?2=3 | \?2=6)
			lda \2
			clc
			adc \1
			sta \2
		.endif

		.if (\?2=4)	;indirect dest
			lda \2
			clc
			adc \1
			sta \2
		.endif
	.endif

	.if (\?1=4) ;src=indirect
		.if (\?2=3 | \?2=6)
			lda \2
			clc
			adc \1
			sta \2
		.endif

		.if (\?2=4)	;indirect dest
			lda \2
			clc
			adc \1
			sta \2
		.endif
	.endif


	.endm


;......................
;ADD.word source,destination. 16bit+16bit->16bit
ADD_w		.macro
				
		;first error checks
			.if (\#<>2)
			.fail Macro requires two arguments
			.endif
			.if (\?2=0)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?2=1)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?2=2)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?2=5)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			
	.if (\?1=2) ;src=#immd
		.if (\?2=3 | \?2=6)
			lda #low(\1)
			clc
			adc \2
			sta \2
			;bcc .skip\@
			lda #high(\1)
			adc \2+1
			sta \2+1
.skip\@
		.endif

		.if (\?2=4)	;indirect dest
			lda #low(\1)
			clc
			adc \2
			sta \2
			;bcc .skip\@
			phy
			ldy #$01
			lda #high(\1)
			adc \2,y
			sta \2,y
			ply
.skip\@
		.endif
	.endif

	.if (\?1=3 | \?1=6) ;src=addr/label
		.if (\?2=3 | \?2=6)
			lda \1
			clc
			adc \2
			sta \2
			;bcc .skip\@
			lda \1+1
			adc \2+1
			sta \2+1
.skip\@
		.endif

		.if (\?2=4)	;indirect dest
			lda \1
			clc
			adc \2
			sta \2
			;bcc .skip\@
			phy
			ldy #$01
			lda \1+1
			adc \2,y
			sta \2,y
			ply
.skip\@
		.endif
	.endif

	.if (\?1=4) ;src=indirect
		.if (\?2=3 | \?2=6)
			lda \1
			clc
			adc \2
			sta \2
			;bcc .skip\@
			phy
			ldy #$01
			lda \1,y
			adc \2+1
			sta \2+1
			ply
.skip\@
		.endif

		.if (\?2=4)	;indirect dest
			lda \1
			clc
			adc \2
			sta \2
			;bcc .skip\@
			phy
			ldy #$01
			lda \1,y
			adc \2,y
			sta \2,y
			ply
.skip\@
		.endif
	.endif


	.endm
	
;......................
;ADD.byte.word source,destination. 8bit+16bit->16bit
ADD_b_w		.macro
				
		;first error checks
			.if (\#<>2)
			.fail Macro requires two arguments
			.endif
			.if (\?2=0)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?2=1)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?2=2)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?2=5)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			
	.if (\?1=2) ;src=#immd
		.if (\?2=3 | \?2=6)
			lda #low(\1)
			clc
			adc \2
			sta \2
			bcc .skip\@
			inc \2+1
.skip\@
		.endif

		.if (\?2=4)	;indirect dest
			lda #low(\1)
			clc
			adc \2
			sta \2
			bcc .skip\@
			phy
			ldy #$01
			lda \2,y
			inc a
			sta \2,y
			ply
.skip\@
		.endif
	.endif

	.if (\?1=3 | \?1=6) ;src=addr/label
		.if (\?2=3 | \?2=6)
			lda \1
			clc
			adc \2
			sta \2
			bcc .skip\@
			inc \2+1
.skip\@
		.endif

		.if (\?2=4)	;indirect dest
			lda \1
			clc
			adc \2
			sta \2
			bcc .skip\@
			phy
			ldy #$01
			lda \2,y
			inc a
			sta \2,y
			ply
.skip\@
		.endif
	.endif

	.if (\?1=4) ;src=indirect
		.if (\?2=3 | \?2=6)
			lda \1
			clc
			adc \2
			sta \2
			bcc .skip\@
			phy
			ldy #$01
			lda \2+1
			inc a
			sta \2+1
			ply
.skip\@
		.endif

		.if (\?2=4)	;indirect dest
			lda \1
			clc
			adc \2
			sta \2
			bcc .skip\@
			phy
			ldy #$01
			lda \2,y
			inc a
			sta \2,y
			ply
.skip\@
		.endif
	.endif


	.endm
	
	
;......................
;ADD.Y.word Y,destination. 8bit+16bit->16bit
ADD_Y_w		.macro
				
		;first error checks
			.if (\#<>1)
			.fail Macro requires two arguments
			.endif
			.if (\?1=0)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?1=1)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?1=2)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			.if (\?1=5)
			.fail destination must be label, absolute address, or indirect. 1
			.endif
			
	
		.if (\?1=3 | \?1=6)
			tya
			clc
			adc \1
			sta \1
			bcc .skip\@
			inc \1+1
.skip\@
		.endif

		.if (\?1=4)	;indirect dest
			tya
			clc
			adc \1
			sta \1
			bcc .skip\@
			phy
			ldy #$01
			lda \1,y
			inc a
			sta \1,y
			ply
.skip\@
		.endif


	.endm
		

;................................................
BNE_L	.macro
		beq .x_\@
		jmp \1
.x_\@

	.endm

BEQ_L	.macro
		bne .x_\@
		jmp \1
.x_\@

	.endm

BPL_L	.macro
		BMI .x_\@
		jmp \1
.x_\@

	.endm
	
BMI_L	.macro
		bpl .x_\@
		jmp \1
.x_\@

	.endm
	
BCS_L	.macro
		bcc .x_\@
		jmp \1
.x_\@

	.endm
	
BCC_L	.macro
		bcs .x_\@
		jmp \1
.x_\@

	.endm
	
BVS_L	.macro
		bvc .x_\@
		jmp \1
.x_\@

	.endm

BVC_L	.macro
		bvs .x_\@
		jmp \1
.x_\@

	.endm


;................................................

;......................
;PUSHBANK.1  addr
PUSHBANK_1		.macro
	.if (\#=0)
	.fail Macro requires two arguments
	.endif
	
		tma #(high(\1)>>5)
		pha
	.endm

;......................
;PUSHBANK.3  addr
PUSHBANK_2		.macro
	.if (\#=0)
	.fail Macro requires two arguments
	.endif
	
	
		tma #(\1)
		pha
		tma #(\1+1)
		pha
	.endm

;......................
;PUSHBANK.3 addr
PUSHBANK_3		.macro
	.if (\#=0)
	.fail Macro requires two arguments
	.endif
	
	
		tma #(\1)
		pha
		tma #(\1+1)
		pha
		tma #(\1+2)
		pha
	.endm

;......................
;PUSHBANK.4 addr
PUSHBANK_4		.macro
	.if (\#=0)
	.fail Macro requires two arguments
	.endif
	
	
		tma #(\1+1)
		pha
		tma #(\1+1)
		pha
		tma #(\1+2)
		pha
		tma #(\1+3)
		pha
	.endm

;......................
;PULLBANK.1 addr
PULLBANK_1		.macro
	.if (\#=0)
	.fail Macro requires two arguments
	.endif
	

		pla	
		tam #(\1)
	.endm

;......................
;PULLBANK.2 addr
PULLBANK_2		.macro
	.if (\#=0)
	.fail Macro requires two arguments
	.endif
	

		pla	
		tam #(\1+1)
		pla	
		tam #(\1)
	.endm

;......................
;PULLBANK.3 addr
PULLBANK_3		.macro
	.if (\#=0)
	.fail Macro requires two arguments
	.endif
	

		pla	
		tam #(\1+2)
		pla	
		tam #(\1+1)
		pla	
		tam #(\1)
	.endm


;......................
;PULLBANK.4 addr
PULLBANK_4		.macro
	.if (\#=0)
	.fail Macro requires two arguments
	.endif
	
		pla	
		tam #(\1+3)
		pla	
		tam #(\1+2)
		pla	
		tam #(\1+1)
		pla	
		tam #(\1)
	.endm

	


;................................................

CPUslow_INTdisabled	.macro
			php
			sei
			csl
	.endm

CPU_slow	.macro
			php
			csl
	.endm


CPU_restored	.macro
			plp
	.endm

;................................................

InitialStartup	.macro

				sei
				cld
				csh
				ldx #$ff
				txs
				lda #$ff
				tam #$00
				lda #$f8
				tam #$01

	.endm


	



