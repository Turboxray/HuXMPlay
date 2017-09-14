;............................................
;                                           .
;     XM Player                             .
;     Ver. 1.0.0                            .
;                                           .
;     Rick Leverton '16                     .
;                                           .
;............................................


;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
;// Pattern decoder
XM_GetPatternLine:

        ;// Pattern line read every <n> ticks
        dec RegPlayerTick
        beq .FetchPattern
  rts
.FetchPattern
        lda PlayerTick
        sta RegPlayerTick 

        ;....
        PUSHBANK_2 MPR4

        ;// Get current Pattern
        
        ;....
        MAP_BANK_WIDE RegPtrnBank, MPR4       

        ;// Setup pointer to Pattern
        MOVE_w RegPtrnAddr, <A0   
        
      
                
        ;// Read in channel data 
        clx
.loop
        jsr __GetChannelData
        inx
        cpx #$04
        bcc .loop                       
        
        ;//
        tma #$04
        sta RegPtrnBank
        MOVE_w <A0, RegPtrnAddr
        
        ;// Goto next patter if current one ended.
        jsr __CheckPatternEnd
        inc RegPtrnLine

        ;....
        PULLBANK_2 MPR4

  rts






;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
;// Update PCMDriver
XM_UpdateRegs:

        clx
.loop
        lda __EntryMask,x
      beq .skip
        jsr __ProcessChannel  
.skip
        inx
        cpx #$04
        bcc .loop

  rts



;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
;// Update PCMDriver
__ProcessChannel:
        
        ; Control code format:
        ;   
        ; 1xx11111
        ; |  ||||- Note
        ; |  |||-- Sample
        ; |  ||--- Subcode (mini FX)
        ; |  |---- FX
        ; |  ----- FX arg
        ; |------- Compression flag
        
        
        ;// Note: Macro preserves X reg
        lda __EntryMask,x
        __CreateCaseBit __ProcessNote
        __CreateCaseBit __ProcessSample
        __CreateCaseBit __Subcode
        __CreateCaseBit __FX
        stz __EntryMask,x
  rts
  
__ProcessNote
          pha
        
        ;// Transpose note
        lda __EntryNote,x
        clc
        adc #__TransPoseNote
        cmp #$0c
      bcc .skip
        sbc #$0c
        inc __EntryOctave,x 
.skip
        sta __ChanNote,x
          pha
        ;// Transpose octave
        lda __EntryOctave,x
        sec
        sbc #__TransPoseOctave
        sta __EntryOctave,x
        tay
          pla
        ;ldy __EntryOctave,x
        say
        sta __ChanOctave,x
        say
        stz __ChanFinestep,x
        stx ChanSelect
          phx
        sxy
        cly
                
                                ;// A=note
                                ;// X=octave
                                ;// Y=finestep
        jsr _SetChanFreq        ;// Driver routine.
          plx
        
        lda #31
        sta __ChanVol,x
        SetChannelVol_IX        ;// Set the default volume. 
        lda __PanChanMaxHardLeftRight,x
        sta __ChanPan,x
        SetChannelPanVol_IX     ;// Set the default pan volume.
        RestartChannel_IX       ;// Enable note play
          pla
  rts

__PanChanMaxHardLeftRight: .db $6f,$f6,$6f,$f6,$6f
  
__ProcessSample
        
          pha

        PUSHBANK_2 MPR4
        MAP_BANK_WIDE #SampleAddr, MPR4 
        
        ;// indirect SampleAddr table
        LEA #SampleAddr, $8000, A1
  
        ;// indirect SampleBank table
        LEA #SampleBank, $8000, A2
        
        
        lda LastSample          ;// <-Backwards compare for inverse Carry logic
        cmp __EntrySample,x
      bcc .out                  ;// out of range
        stx ChanSelect
          phx
          lda __EntrySample,x
          dec a                 ;// Important! XM samples start with index 1
          tay                   ;// +1 inc
          asl a
          tax                   ;// *2 inc
          
          sxy
          lda [A1],y
            pha
          iny
          lda [A1],y
          and #$1f
          ora #$A0              ;// Driver interface expects this to be address range $a000-dfff
            pha
          sxy
          lda [A2],y    
          tay                 ;// Y=bank
            pla               ;// A=msb addr
            plx               ;// X=lsb addr
        jsr LoadSample        ;// Driver routine.
          plx
.out
          pla
          PULLBANK_2 MPR4
  rts
  
__Subcode
            pha
          lda __EntrySub,x
          cmp #$41
        bcs .out
          cmp #$10
        bcc .out
          sec
          sbc #$10
          tay
          lda Lin2PCEVol,y
          sta __ChanVol,x
          SetChannelVol_IX        

.out
            pla
  rts
  
__FX
            pha
          lda __EntryFX,x
          jsr __DecodeMainFX
            pla
  rts


;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
;// Support routines

;//.......................................
;Address passed A0. Bank passed D0.l
;
__LoadXMFile:

        ;....
        PUSHBANK_2 MPR4
        
        ;....
        MAP_BANK_WIDE D0, MPR4        
        
        ;....
        MOVE_Y_I  #$40
        MOVE_b  [A0],y ,PatternListLen

        ;....
        MOVE_Y_I  #$46
        MOVE_b  [A0],y ,LastPattern

        ;....
        MOVE_Y_I  #$48
        MOVE_b  [A0],y ,LastSample

        ;....
        MOVE_Y_I  #$4C
        MOVE_b  [A0],y ,PlayerTick
        inc PlayerTick
        
        ;// Read in playlist
        ADD_b_w #$50, <A0
        MOVE_Y_I  #$00
.GetPatternList
        MOVE_b  [A0],y , PatternList,y
        iny
      bne .GetPatternList
      
        ;// Reposition to Pattern list.
        ADD_b #$01, <A0+1
        ;MOVE_Y_I #$00
        
        
        ;// D0 = number of patterns to parse
        ;// X  = index number into pattern pointer array
        ;// D2 = temp
        MOVE_b  LastPattern, <D0
        MOVE_b  #$00, <D1

        ;// Clear X
        MOVE_X_I  #$00
.ParsePatterns

        ;// Skip the first seven bytes
        ADD_b_w #$07, <A0

        ;// Get sizeOf current pattern
        ;MOVE_w [A0], PatternSizeOf,x
        MOVE_w  [A0], <D2
            lda <D2.l
            sta PatternSizeOf,x
            lda <D2.h
            sta PatternSizeOf+1,x
        
        ;// Get bank and relative address
        ADD_b_w #$02, <A0
            lda <A0
            sta PatternAddr,x
            lda <A0.h
            cmp #$a0
          bcc .cont
              tay
            tma #$05
            tam #$04
            inc a
            tam #$04
              tya
            and #$1f
            ora #$80    
.cont
            sta PatternAddr+1,x
            tma #$04
              phx
            sax
            lsr a
            tay
            txa
            sta PatternBank,y
              plx
            inx                   ;// Need X to be index by 1's, not doubles
            inx
            
            
              
              
        ;// Jump to next pattern
        ADD_w <D2, <A0
        CMP_w <A0, #$A000
        bcc .NoBankOverflow
            tma #$05
            tam #$04
            inc a
            tam #$05
            lda <A0.h
            and #$1f
            ora #$80
            sta <A0.h
        
.NoBankOverflow

        dec <D0
        bne .ParsePatterns
        
        
        ;//Get first Pattern of list and set internal regs for playback
        ;// Initialize the current track pointer
    
            
            ;// build pointers
            lda PatternList
            tay
            asl a
            tax
            
            ;// Pattern address
            lda PatternAddr,x
            sta RegPtrnAddr
            lda PatternAddr+1,x
            sta RegPtrnAddr+1

            ;// Pattern bank
            lda PatternBank,y
            sta RegPtrnBank

            ;// Pattern size
            lda PatternSizeOf,x
            sta RegPtrnSize
            lda PatternSizeOf+1,x
            sta RegPtrnSize+1
            
            ;// Song speed
            lda PlayerTick
            sta RegPlayerTick
            
            ;// PatternList offset
            stz RegPtrnLstPos
            
            ;// Pattern line #
            stz RegPtrnLine
            
            
            
        
        
          
        ;....
        PULLBANK_2 MPR4

  rts



;//.......................................
;//Note returned in A, Octave return in X
__GetChannelData:

        ;// Copy data
        cly

        lda [A0],y
        sta __EntryMask,x
          pha
      bpl .FullEntry
      bra .Separate

.FullEntry
        ;// Full access mode: no control code.
        ;// "preset" extract mask, don't decrement length counter or inc pointer!!! 
        lda #$9f
        sta __EntryMask,x
        bra .skip

.Separate
        ;// Control Code encountered. Advance pointer, and decrement length counter.
        iny
        jsr __DecPatternCounter
    
.skip
          ;pha              ;// <- Need to save the mask as 'flag' for the call routine
          
      ; Control code format:
      ;   
      ; 1xx11111
      ; |  ||||- Note
      ; |  |||-- Sample
      ; |  ||--- Subcode (mini FX)
      ; |  |---- FX
      ; |  ----- FX arg
      ; |------- Compression flag

        jsr .ClearArgs    ;// <- Probably not really needed. Only FXargs needs to be initilized
                          ;;//   because of compression scheme: values of 00 aren't store for "arg".
        
        __GetChanEntry __EntryMask,x, [A0],y ,__EntryNote,x     
        __GetChanEntry __EntryMask,x, [A0],y ,__EntrySample,x     
        __GetChanEntry __EntryMask,x, [A0],y ,__EntrySub,x    
        __GetChanEntry __EntryMask,x, [A0],y ,__EntryFX,x   
        __GetChanEntry __EntryMask,x, [A0],y ,__EntryFXarg,x      
        
        ;// Get note and octave in separate regs.
          phy
        jsr __XM_Note_deconstruct
          ply
        ;// __EntryMask,x is destroyed by __GetChanEntry. Restore it.
          pla
        sta __EntryMask,x

        ;//Advance pointer, bank, etc
        tya
        clc
        adc <A0.l
        sta <A0.l
        lda <A0.h
        adc #$00
        sta <A0.h
        cmp #$a0
      bcc .cont
        and #$1f
        ora #$80
        sta <A0.h
        tma #$05
        tam #$04
        inc a
        tam #$05
.cont
      
  rts

.ClearArgs
        
        stz __EntryNote,x
        stz __EntryOctave,x
        stz __EntrySample,x
        stz __EntrySub,x
        stz __EntryFX,x
        stz __EntryFXarg,x
.NoArgs
        
  rts



;__PrimeInternalRegs = .EndOfPattern

;//.......................................
;//Note returned in __EntryNote, Octave return in __EntryOctave
__XM_Note_deconstruct:
      
        ;// Notes/octaves start at $00. 
        ;// Divide by 12 -> octave. Remainder -> note.  

        cly                 ;// <- Needed in case note is 00!
        lda __EntryNote,x
        cmp #$00
        beq .out
.loop
        iny
        sec
        sbc #$0c
        bcs .loop
.out
        adc #$0c
        dey
        sta __EntryNote,x
        tya
        sta __EntryOctave,x

  rts

;//.........................................
__DecPatternCounter:
        lda RegPtrnSize
        sec
        sbc #$01
        sta RegPtrnSize
      bcs .skip
        dec RegPtrnSize+1
.skip
        rts
          



;//.......................................
__CheckPatternEnd:
        
        lda RegPtrnSize
        ora RegPtrnSize+1
      bne .NoPatternChange

.__FX_0D
        lda #$ff
        sta RegPtrnLine
        
        ;//Increment Pattern Pointer
        lda RegPtrnLstPos
        inc a
        cmp PatternListLen
      bcc .NoReLoopOver
        cla
.NoReLoopOver
        sta RegPtrnLstPos
        
        ;// Load next pattern attribs into regs
        tay
        lda PatternList,y
        tay 
        asl a
        tax
        ;// Pattern Addr
        lda PatternAddr,x
        sta RegPtrnAddr
        lda PatternAddr+1,x
        sta RegPtrnAddr+1
        ;// Pattern bank
        lda PatternBank,y
        sta RegPtrnBank
        ;// Pattern length
        lda PatternSizeOf,x
        sta RegPtrnSize
        lda PatternSizeOf+1,x
        sta RegPtrnSize+1
        
.NoPatternChange
  rts
__FX_0D = .__FX_0D

;//.......................................
;// __DecodeMainFX
;// Input A:X
;// A = FX. X = operand.

__DecodeMainFX:

        ;// Only one FX can be assigned per channel, is it's OK if Acc is destroyed.
        __CreateCase #$0c, __DirectVol
        __CreateCase #$0f, __SetSpeed
        __CreateCase #$0d, __PatternBreak
        __CreateCase #$e9, __NoteReTrigger
  rts

    
    
__DirectVol:
          lda __EntryFXarg,x
          cmp #$41
        bcs .out
          tay
          lda Lin2PCEVol,y
          sta __ChanVol,x
          SetChannelVol_IX        
.out

  rts
  
__SetSpeed:
          lda __EntryFXarg,x
          inc a
          sta PlayerTick
  rts
  
__PatternBreak:
          jsr __FX_0D
  rts

__NoteReTrigger
  rts

;//.......................................
;// __DecodeSubFX
;// Input A:X
;// A = FX. X = operand.
__DecodeSubFX:
  
  rts
  
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
;// Tables/internal equates/etc


__TransPoseNote = 3
__TransPoseOctave = 1

;             *64         0.0  31      0.0          *32        -6.0  27     -6.0
;              63        -0.1  31      0.0           31        -6.3  27     -6.0
;              62        -0.3  31      0.0           30        -6.6  27     -6.0
;              61        -0.4  31      0.0           29        -6.9  27     -6.0
;              60        -0.6  31      0.0           28        -7.2  27     -6.0
;              59        -0.7  31      0.0          *27        -7.5  26     -7.5
;              58        -0.9  31      0.0           26        -7.8  26     -7.5
;              57        -1.0  31      0.0           25        -8.2  26     -7.5
;              56        -1.2  31      0.0           24        -8.5  26     -7.5
;              55        -1.3  31      0.0          *23        -8.9  25     -9.0
;             *54        -1.5  30     -1.5           22        -9.3  25     -9.0
;              53        -1.6  30     -1.5           21        -9.7  25     -9.0
;              52        -1.8  30     -1.5           20       -10.1  25     -9.0
;              51        -2.0  30     -1.5          *19       -10.5  24     -10.5
;              50        -2.1  30     -1.5           18       -11.0  24     -10.5
;              49        -2.3  30     -1.5           17       -11.5  24     -10.5
;              48        -2.5  30     -1.5          *16       -12.0  23     -12.0
;              47        -2.7  30     -1.5           15       -12.6  23     -12.0
;             *46        -2.9  29     -3.0           14       -13.2  23     -12.0
;              45        -3.1  29     -3.0          *13       -13.8  22     -13.5
;              44        -3.3  29     -3.0           12       -14.5  22     -13.5
;              43        -3.5  29     -3.0           11       -15.3  21     -15.0
;              42        -3.7  29     -3.0          *10       -16.1  20     -16.5
;              41        -3.9  29     -3.0            9       -17.0  20     -16.5
;              40        -4.1  29     -3.0          * 8       -18.1  19     -18.0
;              39        -4.3  29     -3.0          * 7       -19.2  18     -19.5
;             *38        -4.5  28     -4.5          * 6       -20.6  17     -21.0
;              37        -4.8  28     -4.5            5       -22.1  17     -21.0
;              36        -5.0  28     -4.5          * 4       -24.1  15     -24.0
;              35        -5.2  28     -4.5          * 3       -26.6  13     -27.0
;              34        -5.5  28     -4.5          * 2       -30.1  11     -30.0
;              33        -5.8  28     -4.5          * 1       -36.1   7     -36.0


Lin2PCEVol:

        ;    0  1  2  3  4  5  6  7  8  9  A  B  C  D  E  F
        .db 00,07,11,13,15,17,17,18,19,20,20,21,22,22,23,23
        .db 23,24,24,24,25,25,25,25,26,26,26,26,27,27,27,27
        .db 27,28,28,28,28,28,28,29,29,29,29,29,29,29,29,30
        .db 30,30,30,30,30,30,30,31,31,31,31,31,31,31,31,31
        .db 31


;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;/////////////////////////////////////////////////////////////////////////////////
;
; END OF FILE