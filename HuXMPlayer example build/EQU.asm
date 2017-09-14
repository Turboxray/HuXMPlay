; VDC REG equates 

MAWR	.equ	$00		;Memory Access Write Reg
MARR	.equ	$01		;Memory Access Read Reg
VRWR	.equ	$02		;Vram Read/Write reg
VWR	.equ	$02		;Vram Read/Write reg
VRR	.equ	$02		;Vram Read/Write reg
CR	.equ	$05		;Control Reg
RCR	.equ	$06		;Raster Control Reg
BXR	.equ	$07		;Background X(scroll) Reg
BYR	.equ	$08		;Background Y(scroll) Reg
MWR	.equ	$09		;Memory Access Width Reg
HSR	.equ	$0a		;Horizontal Synchro Reg
HDR	.equ	$0b		;Horizontal Display Reg
VSR	.equ	$0c		;Vertical Synchro Reg
VDR	.equ	$0d		;Vertical Display Reg
VDE	.equ	$0e		;Vertical Display End Reg
DCR	.equ	$0f		;DMA Control Reg
DSR	.equ	$10		;DMA Source Address Reg
DDR	.equ	$11		;DMA Destination Address Reg
DBR	.equ	$12		;DMA Block Length Reg
SATB	.equ	$13		;VRAM-SATB Source Address Reg 


;VDC ports
vdc_status	 = $0000
vreg_port    = $0000
vdata_port   = $0002
vdata_port.l = $0002
vdata_port.h = $0003

;VDC CR reg arguments
BG_ON = $0080
BG_OFF = $0000
SPR_ON = $0040
SPR_OFF = $0000
VINT_ON = $0008
VINT_OFF = $0000
HINT_ON = $0004
HINT_OFF = $0000
ALL_OFF = $0000 

;VDC vram increment
INC_1	  = %00000000
INC_32  = %00001000
INC_64  = %00010000
INC_128 = %00011000

;VDC map sizes
SCR32_32  = %00000000 
SCR32_64  = %01000000
SCR64_32  = %00010000
SCR64_64  = %01010000
SCR128_32 = %00100000
SCR128_64 = %01100000

;VDC DMA control
AUTO_SATB_ON =  $0010
AUTO_SATB_OFF = $0000

;VDC sprite attributes
V_FLIP    = %1000000000000000
H_LFIP    = %0000100000000000
SIZE16_16 = %0000000000000000
SIZE16_32 = %0000100000000000
SIZE16_64 = %0001100000000000
SIZE32_16 = %0000000100000000
SIZE32_32 = %0000100100000000
SIZE32_64 = %0001100100000000
PRIOR_L   = %0000000000000000
PRIOR_H   = %0000000010000000
SPAL1     = %0000000000000000
SPAL2     = %0000000000000001
SPAL3     = %0000000000000010
SPAL4     = %0000000000000011
SPAL5     = %0000000000000100
SPAL6     = %0000000000000101
SPAL7     = %0000000000000110
SPAL8     = %0000000000000111
SPAL9     = %0000000000001000
SPAL10    = %0000000000001001
SPAL11    = %0000000000001010
SPAL12    = %0000000000001011
SPAL13    = %0000000000001100
SPAL14    = %0000000000001101
SPAL15    = %0000000000001110
SPAL16    = %0000000000001111



; VCE resolution
LO_RES   			= %00000000		;5.369mhz
MID_RES  			= %00000001		;7.159mhz
HI_RES   			= %00000010		;10.739mhz
H_FILTER_ON 	= %00000100		;263 scanline
H_FILTER_OFF	= %00000000		;262 scanline
BW_MODE				= %10000000		;no color burst signal
COLOR_MODE		= %00000000		;color burst signal


;VCE ports
vce_cntrl  = $400
vce_clr	   = $402
vce_clr.l  = $402
vce_clr.h  = $403
vce_data   = $404
vce_data.l = $404
vce_data.h = $405

;TIMER ports
TMR_CMD 	 = $c00
TMR_PORT 	 = $c01
TMR_ON		 = $01
TMR_OFF		 = $01


; IRQ mask 
IRQ2_ON =  %00000000
VIRQ_ON =  %00000000
TIRQ_ON =  %00000000
IRQ2_OFF = %00000001
VIRQ_OFF = %00000010
TIRQ_OFF = %00000100


; Txx
in_DMA = $D3
ia_DMA = $E3
ii_DMA = $73
dd_DMA = $C3
ai_DMA = $F3

; CD 

EX_MEMOPEN	.equ	$E0DE	;SCD version check
CD_READ	.equ	$E009	;CD sector read

AD_CPLAY	.equ	$E03F ;ADPCM streaming 

_al .equ $20f8
_ah .equ $20f9
_bl .equ $20fa
_bh .equ $20fb
_cl .equ $20fc
_ch .equ $20fd
_dl .equ $20fe
_dh .equ $20ff

; MPR slots
MPR0 = 0
MPR1 = 1
MPR2 = 2
MPR3 = 3
MPR4 = 4
MPR5 = 5
MPR6 = 6
MPR7 = 7

