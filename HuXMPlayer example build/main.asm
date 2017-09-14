;
; 	PCMdriver test using HuXMPlay.											
;		 - Uses version 1.2.1 of PCMdriver											
;
;		{Assemble with PCEAS} 
;											
; 	Rick Leverton '16									
;										


;..............................................................................................................
;..............................................................................................................
;..............................................................................................................
;..............................................................................................................

	list
	mlist

;..............................................
;																							.
;	Logical Memory Map:													.
;																							.
;						$0000 = Hardware bank							.
;						$2000 = Sys Ram										.
;						$4000 = Subcode 									.
;						$6000 = Cont. of Subcode					.
;						$8000 = Data											.
;						$A000 = Cont. of Data							.
;						$C000 = Main											.
;						$E000 = Fixed Libray							.
;																							.
;..............................................


;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
;//	Vars

	.zp

				_TM_temp:						.ds 3
				vdc_reg:						.ds 1
				zp_ptr:							.ds 2


	.bss
		.org $2200



				_vbl_flag:			.ds 1
				__vblank:				.ds 1
				_counter:				.ds 1

				Chan0oct:				.ds 1
				Chan0note:			.ds 1
				Chan0step:			.ds 1
				


		;// Support files for MAIN
		.include "reg_vars.asm"

		;// PCMdriver files
		.include "driver_vars.asm"

		;// HuXMPlay files
		.include "HuXMPlay_vars.asm"

;....................................
				.code

				.bank $00, "Fixed Lib/Start up"
				.org $e000
;....................................
				
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
;// Support files: equates and macros 
	
		;// PCMdriver files
		.include "driver_macros.asm"

		;// Support files for MAIN
		.include "macro.asm"
		.include "EQU.asm"
		.include "base_macros.asm"
		.include "print_macros.asm"
		
		;// HuXMPlay files
		.include "HuXMPlay_macros.asm"


;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
;// Main

startup:
				;................................
				;Main initialization routine.
				InitialStartup
				CallFarWide init_audio
				CallFarWide init_video
				
				stz $2000
				tii $2000,$2001,$2000

				;................................
				;Set video parameters
	      VCE_REG HI_RES|H_FILTER_ON				;<-Important! 263 scanline mode.
				VDC_REG HSR , $0b06
				VDC_REG HDR , $063f
				VDC_REG VSR , $0F02
				VDC_REG VDR , $00EF
				VDC_REG VDE , $0003
	      VDC_REG DCR , AUTO_SATB_ON
	      VDC_REG CR , $0000
	      IRQ_CNTR IRQ2_ON|VIRQ_ON|TIRQ_ON
	      VDC_REG SATB , $7F00
	      VDC_REG MWR , SCR64_32
	      TIMER_REG TMR_CMD, #$00
	      TIMER_REG TMR_PORT, #$01
	      
	      MAP_BANK #MAIN, MPR6
	      jmp MAIN

;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
;// Data / fixed bank

;Some internal controls
	.include "driver_interface.asm"

;Stuff for printing on screen
	.include "Print_func.asm"

;other basic functions
	.include "base_func.asm"

;Notes for diplaying
NoteTableA .db $43,$43,$44,$44,$45,$46,$46,$47,$47,$41,$41,$42
NoteTableB .db $20,$23,$20,$23,$20,$20,$23,$20,$23,$20,$23,$20

;								C  ,C# ,D  ,D# ,E  ,F  ,F# ,G  ,G# ,A  ,A#  ,B

;end DATA
;//...................................................................


;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
;// Interrupt routines

;//........
TIRQ:									;unused
				stz $1403
				rti

;//........
BRK:
				rti

;//........
VDC:
					pha
				lda $0000
				bit #$20
				bne .vsync
.hsync
					pla
				rti

.vsync
				ProcessPCM6_9khz_local
					pla
				stz __vblank
				rti

;//........
NMI:
				rti

;end INT

;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
;// INT VECTORS

	.org $fff6

	.dw BRK
	.dw VDC
	.dw PCM_DRIVER
	.dw NMI
	.dw startup

;..............................................................................................................
;..............................................................................................................
;..............................................................................................................
;..............................................................................................................
;Bank 0 end





;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
;// Main code bank @ $C000

	.bank $01, "MAIN"
	.org $c000

MAIN:
				;................................
				;Turn display on
	      VDC_REG CR , BG_ON|SPR_OFF|VINT_ON|HINT_OFF


				
				;................................
				;Load font in vram
	      MAP_BANK_WIDE #Font , MPR4
	      VDC_REG MAWR, $1000
	      VDC_REG VRWR
	      DMA_Word_Port Font, $8000, vdata_port, sizeof(Font)

				;................................
		    ;load font palette
	      BG_COLOR #$0
	      DMA_Word_Port FontPal,$8000, vce_data, sizeof(FontPal)

				;................................
				;Clear 64x32 map
				jsr ClearScreen




				;................................
				;Copy PCM Driver to ram
				;Note: Driver is far mapped, but doesn't cross a bank boundary
				InitializeRamDriver_FarSingle TIMER_PLAYER, $4000, ram_driver, PCMDriverSize

				;................................
				;Important part of driver initialization process
				InitialRegs
				AssignInternalPointer zp_ptr


				;................................
				;set global volume
				SetGlobalVol #15,#15

			
				;................................
				;start the party
				cli



				;................................
				;Display the XM file name
				PRINT_STR_i "XM File: ",2,3
				PRINT_STR_i "Ver: ",2,4
	      MAP_BANK_WIDE #XM_File , MPR4
				LEA (XM_File+$11),$8000,R0
				PRINT_STR_q 11,3
				LEA (XM_File+$25),$8000,R0
				PRINT_STR_q 7,4
				
				
debug01:
				PRINT_STR_i "Pattern Index: ",2,6
				PRINT_STR_i "Pattern Playing: ",2,7
				PRINT_STR_i "Pattern line: ",2,8
				PRINT_STR_i "Speed: ",2,9
				
				;................................
				;Load XM file into player
debug02:
	      MAP_BANK_WIDE #XM_File , MPR4
				LoadXMFile XM_File

		
				;................................
				;Important: The driver won't activate until
				;EnablePCMDriver is called. 
				EnablePCMDriver



main_loop:

				WAITVBLANK 0
				XM_Play
				PRINT_BYTEhex RegPtrnLstPos, 17,6
				ldx RegPtrnLstPos
				ldy PatternList,x
				PRINT_BYTEhex_q 19,7
				ldy RegPtrnLine
				PRINT_BYTEhex_q 16,8
				lda PlayerTick
				dec a
				tay
				PRINT_BYTEhex_q 9,9
			bra main_loop	
						


;Main end
;//...................................................................





;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
	.bank $02, "Subcode 1"
	.org $4000

		;// Support files for MAIN
		.include "InitHW.asm"

		;// PCMdriver files
		.include "driver.asm"

		;// HuXMPlay files
		.include "HuXMPlay.asm"



Font: .incbin "font.dat"

FontPal: .db $00,$00,$33,$01,$ff,$01,$ff,$01,$ff,$01,$ff,$01,$ff,$01,$f6,$01


;..............................................................................................................
;..............................................................................................................
;..............................................................................................................
;..............................................................................................................
;Bank 1 end


;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
;// Some samples

	.bank $03, "Song/Samples"
	.org $8000

;//.....................
;// Actual XM data
XM_File:	.incbin "Axel_f.txm"


;//.....................
;//Sample files
st01hallbrass_1	.incbin "st01hallbrass_1.5bt"
st01digdug_2	.incbin "st01digdug_2.5bt"
st01nice_3	.incbin "st01nice_3.5bt"
st01synbrass_4	.incbin "st01synbrass_4.5bt"
st01popsnare2_5	.incbin "st01popsnare2_5.5bt"
st01bassdrum2_6	.incbin "st01bassdrum2_6.5bt"
st01dxtom_7	.incbin "st01dxtom_7.5bt"
st01hihat2_8	.incbin "st01hihat2_8b.5bt"
blank	.incbin "blank.5bt"
st01blast_A	.incbin "st01blast_A.5bt"
st01hallbrass_B	.incbin "st01hallbrass_B.5bt"
st01synbrass_C	.incbin "st01synbrass_C.5bt"
st01nice_D	.incbin "st01nice_D.5bt"
st01popsnare2_E	.incbin "st01popsnare2_E.5bt"
st01blubzing_F	.incbin "st01blubzing_F.5bt"


;//......................
;//Built tables for sample access
SampleAddr:
				.dw (st01hallbrass_1 & $1fff),(st01digdug_2 & $1fff),(st01nice_3 & $1fff),(st01synbrass_4 & $1fff)
				.dw (st01popsnare2_5 & $1fff),(st01bassdrum2_6 & $1fff),(st01dxtom_7 & $1fff),(st01hihat2_8 & $1fff)
				.dw (blank & $1fff),(st01blast_A & $1fff),(st01hallbrass_B & $1fff),(st01synbrass_C & $1fff)
				.dw (st01nice_D & $1fff),(st01popsnare2_E & $1fff),(st01blubzing_F & $1fff)

SampleBank:
				.db bank(st01hallbrass_1),bank(st01digdug_2),bank(st01nice_3),bank(st01synbrass_4)
				.db bank(st01popsnare2_5),bank(st01bassdrum2_6),bank(st01dxtom_7),bank(st01hihat2_8)
				.db bank(blank),bank(st01blast_A),bank(st01hallbrass_B),bank(st01synbrass_C)
				.db bank(st01nice_D),bank(st01popsnare2_E),bank(st01blubzing_F)
;..............................................................................................................
;..............................................................................................................
;..............................................................................................................
;..............................................................................................................
;END OF FILE