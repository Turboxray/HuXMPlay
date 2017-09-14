;													 -----------------------
; 												|	6 channel PCM driver. |
;													| ver 1.2.1             |
; 												|	                      |
; 												|	Rick Leverton '16     |
;													 -----------------------

;..............................................................................................................
;..............................................................................................................
;..............................................................................................................
;..............................................................................................................
TIMER_PLAYER:

    		;ram


.miss
			rti




                             
.PCM_DRIVER
        ;int call               			;8
        stz $1403											;5

.EnablePlayer
	        .db $40  
	        .db low(DDAprocessing)
	        .db (.doDDA - .miss)				;6 cycles for BBS0
.doDDA
        cli														;2       
        	pha													;4
        lda #$ff											;2
        sta <DDAprocessing						;4
        tma #$06											;4
        	pha                     		;4
        jmp (.PhaseShift - TIMER_PLAYER)+BASE_SM1				; 4 
																			
																			;43

        
.chn0_chk
      jmp (.chn0_end_chk - TIMER_PLAYER)+BASE_SM1				;.chn0_end_chk
.chn1_chk
      jmp (.chn1_end_chk - TIMER_PLAYER)+BASE_SM1				;.chn1_end_chk
 
.inc_chn0_msb
      lda (.sm8 - TIMER_PLAYER)+BASE_SM1+2                
      adc #$00                  
      cmp #$e0                  
      bcs .inc_chn0_bnk         
      sta (.sm8 - TIMER_PLAYER)+BASE_SM1+2                
      jmp (.sm8 - TIMER_PLAYER)+BASE_SM1       ;20 cycles for msb, but no bank           
.inc_chn0_bnk
      and #$c0
      sta (.sm8 - TIMER_PLAYER)+BASE_SM1+2
      lda (.ch0 - TIMER_PLAYER)+BASE_SM1+1               
      inc a
      sta (.ch0 - TIMER_PLAYER)+BASE_SM1+1
.ch0_ tam #$06
      jmp (.sm8 - TIMER_PLAYER)+BASE_SM1   		;41 cycles for msb and bank               

                  
.PhaseShift

;.............................................
;Channel0
.chn0on
				;lda #$00
				bra .chn1on
				sta $800
.ch0    lda #$00                
        tam #$06                
.sm5    lda #$00                
.cn0    adc #$00                
        sta (.sm5 - TIMER_PLAYER)+BASE_SM1+1                
.sm6    lda #$00                
.cn1    adc #$00                
        sta (.sm6 - TIMER_PLAYER)+BASE_SM1+1               
.sm7    lda #$00                
        adc (.sm8 - TIMER_PLAYER)+BASE_SM1+1              
        sta (.sm8 - TIMER_PLAYER)+BASE_SM1+1              
        bcs .inc_chn0_msb       
.sm8    lda $0000              
        bmi .chn0_chk          
       sta $806
                                ; 58 cycles
  
;.............................................
;Channel0
.chn1on
				;lda #$01
				bra .chn2on
				sta $800
.ch1    lda #$00              
				tam #$06               
.sm9    lda #$00                
.cn2    adc #$00                
        sta (.sm9 - TIMER_PLAYER)+BASE_SM1+1                
.sm10   lda #$00                
.cn3    adc #$00                
        sta (.sm10 - TIMER_PLAYER)+BASE_SM1+1                
.sm11   lda #$00                
        adc (.sm12 - TIMER_PLAYER)+BASE_SM1+1              
        sta (.sm12 - TIMER_PLAYER)+BASE_SM1+1              
        bcs .inc_chn1_msb       
.sm12   lda $0000              
        bmi .chn1_chk           
        sta $806
                              ; 58 cycles
  
;.............................................
;Channel0
.chn2on
				;lda #$02
				bra .chn3on
				sta $800
.ch2    lda #$00                
			  tam #$06                
.sm13   lda #$00                
.cn4    adc #$00                
        sta (.sm13 - TIMER_PLAYER)+BASE_SM1+1                
.sm14   lda #$00                
.cn5    adc #$00                
        sta (.sm14 - TIMER_PLAYER)+BASE_SM1+1                
.sm15   lda #$00                
        adc (.sm16 - TIMER_PLAYER)+BASE_SM1+1              
        sta (.sm16 - TIMER_PLAYER)+BASE_SM1+1              
        bcs .inc_chn2_msb       
.sm16   lda $0000              
        bmi .chn2_chk           
        sta $806
                                ; 58 cycles
  
;.............................................
;Channel0
.chn3on
				;lda #$03																	;2
				bra .do_fix_chan													; <-not counted. Part of initialized state.
				sta $800																	;5
.ch3    lda #$00                									;2
        tam #$06                									;5
.sm17   lda #$00                									;2
.cn6    adc #$00                									;2
        sta (.sm17 - TIMER_PLAYER)+BASE_SM1+1     ;5        
.sm18   lda #$00                									;2
.cn7    adc #$00                									;2
        sta (.sm18 - TIMER_PLAYER)+BASE_SM1+1     ;5           
.sm19   lda #$00                									;2
        adc (.sm20 - TIMER_PLAYER)+BASE_SM1+1     ;5       
        sta (.sm20 - TIMER_PLAYER)+BASE_SM1+1     ;5         
        bcs .inc_chn3_msb       									;2
.sm20   lda $0000              										;5
        bmi .chn3_chk           									;2	
        sta $806																	;5
                                ; 58 cycles

;.............................................
; Now onto fixed frequency channels
.do_fix_chan
			jmp (.fixed_chan_output - TIMER_PLAYER)+BASE_SM1
			

;//...................................................................
;//
;// Bank bounds check
;// 
    

.chn2_chk
      jmp (.chn2_end_chk - TIMER_PLAYER)+BASE_SM1
.chn3_chk
      jmp (.chn3_end_chk - TIMER_PLAYER)+BASE_SM1


      

.inc_chn1_msb
      lda (.sm12 - TIMER_PLAYER)+BASE_SM1+2                
      adc #$00                  
      cmp #$e0                  
      bcs .inc_chn1_bnk         
      sta (.sm12 - TIMER_PLAYER)+BASE_SM1+2                
      jmp (.sm12 - TIMER_PLAYER)+BASE_SM1                  
.inc_chn1_bnk
      and #$c0
      sta (.sm12 - TIMER_PLAYER)+BASE_SM1+2
      lda (.ch1 - TIMER_PLAYER)+BASE_SM1+1               
      inc a
      sta (.ch1 - TIMER_PLAYER)+BASE_SM1+1
.ch1_ tam #$06
      jmp (.sm12 - TIMER_PLAYER)+BASE_SM1                   



.inc_chn2_msb
      lda (.sm16 - TIMER_PLAYER)+BASE_SM1+2                
      adc #$00                  
      cmp #$e0                  
      bcs .inc_chn2_bnk         
      sta (.sm16 - TIMER_PLAYER)+BASE_SM1+2                
      jmp (.sm16 - TIMER_PLAYER)+BASE_SM1                  
.inc_chn2_bnk
      and #$c0
      sta (.sm16 - TIMER_PLAYER)+BASE_SM1+2
      lda (.ch2 - TIMER_PLAYER)+BASE_SM1+1               
      inc a
      sta (.ch2 - TIMER_PLAYER)+BASE_SM1+1
.ch2_ tam #$06
      jmp (.sm16 - TIMER_PLAYER)+BASE_SM1                   



.inc_chn3_msb
      lda (.sm20 - TIMER_PLAYER)+BASE_SM1+2                
      adc #$00                  
      cmp #$e0                  
      bcs .inc_chn3_bnk         
      sta (.sm20 - TIMER_PLAYER)+BASE_SM1+2                
      jmp (.sm20 - TIMER_PLAYER)+BASE_SM1                  
.inc_chn3_bnk
      and #$c0
      sta (.sm20 - TIMER_PLAYER)+BASE_SM1+2
      lda (.ch3 - TIMER_PLAYER)+BASE_SM1+1               
      inc a
      sta (.ch3 - TIMER_PLAYER)+BASE_SM1+1
.ch3_ tam #$06
      jmp (.sm20 - TIMER_PLAYER)+BASE_SM1                   



;//...................................................................
;//
;// Check to see if EOF or LOOP
;// 

.chn0_end_chk
			cmp #$81
		bcc .chn0_end_chk.skip
		jmp (.ch0_loop - TIMER_PLAYER)+BASE_SM1
.chn0_end_chk.skip
      lda #$80
      sta (.chn0on - TIMER_PLAYER)+BASE_SM1							;.ch0
.0    lda #low(.chn1on - .chn0on)-2
      sta (.chn0on - TIMER_PLAYER)+BASE_SM1+1					 	;.ch0+1
    jmp (.chn1on - TIMER_PLAYER)+BASE_SM1 							;.ch1

.chn1_end_chk
			cmp #$81
		bcc .chn1_end_chk.skip
		jmp (.ch1_loop - TIMER_PLAYER)+BASE_SM1
.chn1_end_chk.skip
      lda #$80
      sta (.chn1on - TIMER_PLAYER)+BASE_SM1 							;.ch1
.1    lda #low(.chn2on - .chn1on)-2
      sta (.chn1on - TIMER_PLAYER)+BASE_SM1+1 						;.ch1+1
    jmp (.chn2on - TIMER_PLAYER)+BASE_SM1 							;.ch2

.chn2_end_chk
 			cmp #$81
		bcc .chn2_end_chk.skip
		jmp (.ch2_loop - TIMER_PLAYER)+BASE_SM1
.chn2_end_chk.skip
     lda #$80
      sta (.chn2on - TIMER_PLAYER)+BASE_SM1							;.ch2
.2    lda #low(.chn3on - .chn2on)-2
      sta (.chn2on - TIMER_PLAYER)+BASE_SM1+1						;.ch2+1
    jmp (.chn3on - TIMER_PLAYER)+BASE_SM1							;.ch3

.chn3_end_chk
			cmp #$81
		bcc .chn3_end_chk.skip
		jmp (.ch3_loop - TIMER_PLAYER)+BASE_SM1
.chn3_end_chk.skip
      lda #$80
      sta (.chn3on - TIMER_PLAYER)+BASE_SM1							;.ch3
.3    lda #low(.do_fix_chan - .chn3on)-2
      sta (.chn3on - TIMER_PLAYER)+BASE_SM1+1						;.ch3+1
    jmp (.do_fix_chan - TIMER_PLAYER)+BASE_SM1							;.end


    
;//...................................................................
;//
;// Fixed channels eat up less resource, but not by much
;// 

.fixed_chan_output

;.............................................
;Channel4
.chn4on
				;lda #$04																	;2
				bra .chn5on																; <- not counted.
				sta $800																	;5
.ch4    lda #$00                									;2
        tam #$06                									;5
        inc (.ch4sm - TIMER_PLAYER)+BASE_SM1+1    ;7         
        beq .inc_chn4_msb       									;2
.ch4sm   lda $0000              									;5
        bmi .chn4_chk        											;2	
        sta $806																	;5
        																					;35


;.............................................
;Channel5
.chn5on
				;lda #$05																	
				bra .end
				sta $800																	
.ch5    lda #$00                									
        tam #$06                									
        inc (.ch5sm - TIMER_PLAYER)+BASE_SM1+1             
        beq .inc_chn5_msb       									
.ch5sm   lda $0000              									
        bmi .chn5_chk           										
        sta $806																

        																					

;//...................................................................
;//
;// Exit driver
;// 

.end                                
			
        pla         					;3
        tam #$06							;5
        stz <DDAprocessing		;4
        pla            				;3
.out
	rti                     		;8
                                ; 23 cycles

																; four frequency scaled channels	
																; 58*4= 232 + 43 + 23 + 4 + 4 = 306
                                ; @ 116 times per frame
                                ; 34596 cycles per frame
                                ; 29.7% cpu resource
                                
                                ; 2 channels + 4 channels
                                ; 306 + 31 + 31 = 368
                                ; 42688 cycles per frame
                                ; 35.7% cpu resource
 
;//...................................................................
;//
;// Bank bounds check for fixed channels
;// 
                                
.chn4_chk 
      jmp (.chn4_end_chk - TIMER_PLAYER)+BASE_SM1
.chn5_chk
      jmp (.chn5_end_chk - TIMER_PLAYER)+BASE_SM1

.inc_chn4_msb
      lda (.ch4sm - TIMER_PLAYER)+BASE_SM1+2                
      inc a                  
      cmp #$e0                  
      bcs .inc_chn4_bnk         
      sta (.ch4sm - TIMER_PLAYER)+BASE_SM1+2                
      jmp (.ch4sm - TIMER_PLAYER)+BASE_SM1                  
.inc_chn4_bnk
      and #$c0
      sta (.ch4sm - TIMER_PLAYER)+BASE_SM1+2
      lda (.ch4 - TIMER_PLAYER)+BASE_SM1+1               
      inc a
      sta (.ch4 - TIMER_PLAYER)+BASE_SM1+1
.ch4_ tam #$06
      jmp (.ch4sm - TIMER_PLAYER)+BASE_SM1                   



.inc_chn5_msb
      lda (.ch5sm - TIMER_PLAYER)+BASE_SM1+2                
      inc a                  
      cmp #$e0                  
      bcs .inc_chn5_bnk         
      sta (.ch5sm - TIMER_PLAYER)+BASE_SM1+2                
      jmp (.ch5sm - TIMER_PLAYER)+BASE_SM1                  
.inc_chn5_bnk
      and #$c0
      sta (.ch5sm - TIMER_PLAYER)+BASE_SM1+2
      lda (.ch5 - TIMER_PLAYER)+BASE_SM1+1               
      inc a
      sta (.ch5 - TIMER_PLAYER)+BASE_SM1+1
.ch5_ tam #$06
      jmp (.ch5sm - TIMER_PLAYER)+BASE_SM1                   


.chn4_end_chk
      lda #$80
      sta (.chn4on - TIMER_PLAYER)+BASE_SM1							;.ch0
.4    lda #low(.chn5on - .chn4on)-2
      sta (.chn4on - TIMER_PLAYER)+BASE_SM1+1					 	;.ch0+1
      jmp (.chn5on - TIMER_PLAYER)+BASE_SM1 							;.ch1

.chn5_end_chk
      lda #$80
      sta (.chn5on - TIMER_PLAYER)+BASE_SM1							;.ch0
.5    lda #low(.end - .chn5on)-2
      sta (.chn5on - TIMER_PLAYER)+BASE_SM1+1					 	;.ch0+1
      jmp (.end - TIMER_PLAYER)+BASE_SM1 							;.ch1




;//...................................................................
;//
;// Loop code
;// 

.ch0_loop
			lda Ch0LoopAddr
			sta (.sm8 - TIMER_PLAYER)+BASE_SM1+1
			lda Ch0LoopAddr+1
			sta (.sm8 - TIMER_PLAYER)+BASE_SM1+2
			lda Ch0LoopBank
			tam #$06
			sta (.ch0 - TIMER_PLAYER)+BASE_SM1+1
    jmp (.sm8 - TIMER_PLAYER)+BASE_SM1

.ch1_loop
			lda Ch1LoopAddr
			sta (.sm12 - TIMER_PLAYER)+BASE_SM1+1
			lda Ch1LoopAddr+1
			sta (.sm12 - TIMER_PLAYER)+BASE_SM1+2
			lda Ch1LoopBank
			tam #$06
			sta (.ch1 - TIMER_PLAYER)+BASE_SM1+1
    jmp (.sm12 - TIMER_PLAYER)+BASE_SM1

.ch2_loop
			lda Ch2LoopAddr
			sta (.sm16 - TIMER_PLAYER)+BASE_SM1+1
			lda Ch2LoopAddr+1
			sta (.sm16 - TIMER_PLAYER)+BASE_SM1+2
			lda Ch2LoopBank
			tam #$06
			sta (.ch2 - TIMER_PLAYER)+BASE_SM1+1
    jmp (.sm16 - TIMER_PLAYER)+BASE_SM1

.ch3_loop
			lda Ch3LoopAddr
			sta (.sm20 - TIMER_PLAYER)+BASE_SM1+1
			lda Ch3LoopAddr+1
			sta (.sm20 - TIMER_PLAYER)+BASE_SM1+2
			lda Ch3LoopBank
			tam #$06
			sta (.ch3 - TIMER_PLAYER)+BASE_SM1+1
    jmp (.sm20 - TIMER_PLAYER)+BASE_SM1

;//...................................................................
;//
;// Need to make some private labels->public
;// 
    

DriverAllocation = *-TIMER_PLAYER
	.bss
		ram_driver:	.ds  DriverAllocation
	.code

PCMDriverSize = DriverAllocation

BASE_SM1 = ram_driver

PCM_DRIVER = (.PCM_DRIVER - TIMER_PLAYER)+BASE_SM1

CHN0.bnk = (.ch0 - TIMER_PLAYER)+BASE_SM1+1
CHN0.mode = (.chn0on - TIMER_PLAYER)+BASE_SM1
CHN0.brn = (.chn0on - TIMER_PLAYER)+BASE_SM1+1
CHN0.on  =  $a9
CHN0.off =  $80
CHN0.skip = (.chn1on - .chn0on)-2                               
CHN0.lo  = (.cn0 - TIMER_PLAYER) + BASE_SM1+1
CHN0.mid = (.cn1 - TIMER_PLAYER) + BASE_SM1+1
CHN0.hi  = (.sm7 - TIMER_PLAYER) +BASE_SM1+1
CHN0.ptr = (.sm8 - TIMER_PLAYER) + BASE_SM1+1
CHN0.Plo = (.sm5 - TIMER_PLAYER) + BASE_SM1+1
CHN0.Phi = (.sm6 - TIMER_PLAYER) + BASE_SM1+1

CHN1.bnk = (.ch1 - TIMER_PLAYER)+BASE_SM1+1                               
CHN1.mode = (.chn1on - TIMER_PLAYER)+BASE_SM1
CHN1.brn = (.chn1on - TIMER_PLAYER)+BASE_SM1+1
CHN1.on  =  $a9
CHN1.off =  $80
CHN1.skip = (.chn2on - .chn1on)-2                               
CHN1.lo  = (.cn2 - TIMER_PLAYER)+BASE_SM1+1
CHN1.mid = (.cn3 - TIMER_PLAYER)+BASE_SM1+1
CHN1.hi  = (.sm11 - TIMER_PLAYER)+BASE_SM1+1
CHN1.ptr = (.sm12 - TIMER_PLAYER)+BASE_SM1+1
CHN1.Plo = (.sm9 - TIMER_PLAYER) + BASE_SM1+1
CHN1.Phi = (.sm10 - TIMER_PLAYER) + BASE_SM1+1

CHN2.bnk = (.ch2 - TIMER_PLAYER)+BASE_SM1+1                               
CHN2.mode = (.chn2on - TIMER_PLAYER)+BASE_SM1
CHN2.brn = (.chn2on - TIMER_PLAYER)+BASE_SM1+1
CHN2.on  =  $a9
CHN2.off =  $80
CHN2.skip = (.chn3on - .chn2on)-2                               
CHN2.lo  = (.cn4 - TIMER_PLAYER)+BASE_SM1+1
CHN2.mid = (.cn5 - TIMER_PLAYER)+BASE_SM1+1
CHN2.hi  = (.sm15 - TIMER_PLAYER)+BASE_SM1+1
CHN2.ptr = (.sm16 - TIMER_PLAYER)+BASE_SM1+1
CHN2.Plo = (.sm13 - TIMER_PLAYER) + BASE_SM1+1
CHN2.Phi = (.sm14 - TIMER_PLAYER) + BASE_SM1+1

CHN3.bnk = (.ch3 - TIMER_PLAYER)+BASE_SM1+1
CHN3.mode = (.chn3on - TIMER_PLAYER)+BASE_SM1
CHN3.brn = (.chn3on - TIMER_PLAYER)+BASE_SM1+1
CHN3.on  =  $a9
CHN3.off =  $80
CHN3.skip = (.do_fix_chan - .chn3on)-2                                
CHN3.lo  = (.cn6 - TIMER_PLAYER)+BASE_SM1+1
CHN3.mid = (.cn7 - TIMER_PLAYER)+BASE_SM1+1
CHN3.hi  = (.sm19 - TIMER_PLAYER)+BASE_SM1+1
CHN3.ptr = (.sm20 - TIMER_PLAYER)+BASE_SM1+1
CHN3.Plo = (.sm17 - TIMER_PLAYER) + BASE_SM1+1
CHN3.Phi = (.sm18 - TIMER_PLAYER) + BASE_SM1+1

CHN4.bnk = (.ch4 - TIMER_PLAYER)+BASE_SM1+1
CHN4.mode = (.chn4on - TIMER_PLAYER)+BASE_SM1
CHN4.brn = (.chn4on - TIMER_PLAYER)+BASE_SM1+1
CHN4.on  =  $a9
CHN4.off =  $80
CHN4.skip = (.chn5on - .chn4on)-2                                
CHN4.ptr = (.ch4sm - TIMER_PLAYER)+BASE_SM1+1

CHN5.bnk = (.ch5 - TIMER_PLAYER)+BASE_SM1+1
CHN5.mode = (.chn5on - TIMER_PLAYER)+BASE_SM1
CHN5.brn = (.chn5on - TIMER_PLAYER)+BASE_SM1+1
CHN5.on  =  $a9
CHN5.off =  $80
CHN5.skip = (.end - .chn5on)-2                                
CHN5.ptr = (.ch5sm - TIMER_PLAYER)+BASE_SM1+1

EnableTimerDriver = (.EnablePlayer - TIMER_PLAYER)+BASE_SM1

TIMER_PLAYER_END:


;............................................................................
;
;	Notes: Case scenarios.
;
;	TIRQ overhead is 43+23, and +4 for any channel turned off.
;
;		lsb overflow: chan 0-3
;		@ cycle 48, branch taken.
;			+32cycle if no bank change = 80
;			+48cycle if bank change = 96
;		base is 58cycles.
;		max is 96cycles. 38 cycle difference.
;
;		loop reload: chan 0-3
;		@ cycle 55, branch taken.
;			+61 loop applied = 116
;		base is 58 cycles
;		max is 116cycles. 58 cycle difference.
;				














;//...................................................................
;//
;//
;// END OF FILE 
