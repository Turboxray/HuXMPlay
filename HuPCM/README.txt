

  HuPCM: PC Engine PCM playback driver
  ====================================
  
  
    What is it?
    ==========
    
       This is a six channel PCM driver that will stream PCM data to any of the six channels
      via DDA mode. Channels 0 to 3 can be frequency scaled via note, octave, and finestep
      parameters.
      
       Channels 4 & 5 are fixed frequency and only playback at roughly 7khz. The PCM format
      is PCE DDA native 5bit. Included with the driver is a conversion utility: wav2sixbit. 
      
       This is ~not~ a music engine. It's a sound driver. If you want to use it in a music
      engine: you'll have to interface with the driver with your own engine.
    
    
    
    How does it work?
    ================
      
       The driver uses a small chunk of ram in order to utilize self modifying code to 
      provide the fastest possible frequency scaling routines. Since the driver is accessing
      the audio regs every Timer interrupt call, a service routine is attached to the vblank
      interrupt to provide an updating window. This window uses buffered software registers.
      
       A series of macros have been created to help facilitate accessing the internal software
      registers. Any channel can be individually turned off or stopped.
      
      
      
    How much CPU resource does it use?
    =================================
    
        It all depends on how many channels you intend to use as once. The base overhead with
       all channels disabled is ~10440 cycles or ~8.7% cpu resource. Each frequency scaled
       channel adds ~5.3% per channel enabled. Each fixed frequency channel adds ~3.0% per
       channel enabled.
       
        The interrupt is setup so that the interrupt flag is immediately cleared after entering
       the routine, allowing for higher priority interrupts to without delay (VDC). 
       
        A secondary mechanism is in place just in case the original Timer interrupt takes too
       long and/or is delayed too long by the VDC interrupt; a sample will be delayed in this
       case. If a second Timer interrupt is called while the first has finished operations, it
       will exit until the busy flag is cleared.
       
        The driver shouldn't use more than 368cycles max per call under normal circumstances,
       for all channels in use, but if a sample crosses page, or hits a loop-point, or reaches
       an end, a small amount of overhead for particular channel will occur. Probably add 
       another 3.8% cpu resource if all channels are enabled.
       
       
       
    How do I use it?
    ===============
      
      Here's a breakdown of how to use it:
         
     [] The driver needs to be copied to ram. Basically define a segment in ram with the player
        size.

          TIMER_PLAYER = the driver address to be copied from.
          PCMDriverSize = the size of the driver to be copied.
          ram_driver = the ram segment define in BSS, to be copied to.

          
     [] The driver needs to be copied into its BSS define. A set of three macros are provided: 
        
          InitializeRamDriver (macro, three args)
            Arguments in order: TIMER_PLAYER, ram_driver, PCMDriverSize

          InitializeRamDriver_FarSingle (macro, four args)
            Arguments in order: TIMER_PLAYER, <address block>, ram_driver, PCMDriverSize

          InitializeRamDriver_FarDouble (macro, four args)
            Arguments in order: TIMER_PLAYER, <address block>, ram_driver, PCMDriverSize

        * Note: 
            1) Address block is the MPR range to be mapped to: $4000,$6000,$8000, etc.
            2) "_FarSingle" assumes the data to be copied does not cross a bank boundary.
            3) "_FarDouble" assumes the data to be copied does cross a bank boundary and
               maps in two banks to cover this scenario. Warning: don't do this for block
               $C000 as it will map out MPR 7 ($E000) and likely crash your code.


     [] After the driver is copied, some internal variables/states need to be initialized.

          InitialRegs (macro, no arguments)

        
     [] The internal working parts of the driver interface need two ZP bytes to work with.
        You can create your own specific set for this or repurpose another already defined
        set using this macro. Either way, pass the ZP label to the macro:

          AssignInternalPointer <zp label>

        
     [] The driver is automatically created in a disabled state. Once
        the internal parts have been initialized, the driver itself
        can be activated.
        
          EnablePCMDriver (macro, no arguments)
          
        
          
          
      A list of the following control/interface macros
      ------------------------------------------------
        
     [] Non channel dependent control/interface macros.
        
            {{ Sets the global pan volume register }}
          SetGlobalVol left_vol, right_ol (two arguments) 
          SetGlobalVol left_right_vol (one argument: byte)
  
  
            {{ Pauses the whole playback driver }}
          PausePCMDriver (no args): pause the driver. No effect on update processor.


            {{ Resumes the playback driver }}
          ResumePCMDriver (no args): Resume the driver. No effect on update processor.
      
        
     [] Channel dependent macros: channel <number> prefixes macro name.
          
            {{ Sets the channel pan volume register }}
          SetChannelPanVol_0 left_vol, right_ol (two arguments; range 0-15) 
          SetChannelPanVol_0 left_right_vol (one argument: byte)


            {{ Sets the global pan volume register }}
          SetChannelVol_0 vol (one argument; range 0-31)
          
          
            {{ Needed when loading a new "instrument" }}
          RestartChannel_0 (no args. Resets phase accumulator state) (*2)
          
          
            {{ Loads a sample to an individual channel }}
          SetSampleChannel_0 (arg; sample label)
          
            Info: Setting a sample to a channel doesn't reset the frequency,
                  volume, phase accumulator, or any other related attributes.
            

            {{ Stops a channel from outputting to DDA port }}
          StopChannel_0 (no args. channel stopped/paused)
          
            Info: Does not affect any of the volume registers.
          
          
            {{ Stops the internal updating process for specific channel }}
          HaltUpdateChan_0 (no args): Halts the internal update processor.


            {{ Resumes the internal updating process for specific channel }}
          ResumeUpdateChan_0 (no args): Resumes the internal update processor.


            {{ Resumes playback of specific channel }}
          ResumeChannel_0  (no args. channel resume)


            {{ Sets the frequency playback of specific channel }}
          SetChannelNote_0 (3 args; note, octave, finestep) (*2)
          
            Info: Note ranges from 0 to 11 
                  Octave ranges from 0 to 7
                  Finestep ranges from 0 to 31


      Special macros: 
      ---------------

             These macros are to be used inside a vblank routine, preferably as
            close to the interrupt call as possible, because these routines are
            what keep the Timer interrupt in sync - so each frame has the same
            timing of TIRQ. This also runs the "update processor".
            
             There are two versions of each set. The 7khz version manually calls
            the TIRQ/driver routine inside the vblank INT. This gives an even
            117 samples per frame. The 6.9kz (6.97khz) does not call inside the
            vblank int routine and thus results in 116 samples per frame.
            
            It's *highly* recommended to use the 6.9khz version for timing reasons.             
          
             The local versions are for the update processor being located locally
            in a fixed bank (something like MPR).

                  ProcessPCM7_0khz_local
                  ProcessPCM6_9khz_local

             The far versions are for the update processor being located in another
            bank that isn't fixed or necessarily mapped at the time of the call.

                  ProcessPCM7_0khz_far
                  ProcessPCM6_9khz_far

            Note: Make sure the update processor routine does not cross a bank
                  boundary for the "far" versions. It only maps in one back for
                  the call.



    Files and Package
    =================
    
         The driver package consists of the following files:
              
              driver.asm
              driver_macros.asm
              driver_interface.asm
              driver_vars.asm
        
          Break down of files
          -------------------
            
            driver.asm: 

                         This contains the driver itself. No other relatable code is
                        located here. The location of this file in rom is irrelevant;
                        it's only purpose is to be copied into ram. So in other words
                        don't bother wasting fixed bank space with this file include.
                        
                        
            driver_macros.asm:

                         As the name implies, only macros are stored in this file.
                        The specific reason for this, is that PCEAS doesn't accurately
                        resolve macro defines in the two-pass processing like it does
                        for equates and other label resolving processing. So it's
                        important that macros be defined at the very start of the main
                        source file, before any code. See the example test rom source
                        code for further visual reference.

                        
            driver_interface.asm
                                  
                         This file contains the interface code and the update processor.
                        If the file is not included in a fixed bank location, say MPR 7
                        for example, then it will have to be mapped in for all macro
                        calls, as well as using "far" version of ProcessPCM main control
                        macro.
            
                        
            driver_vars.asm
            
                         This is rather self-explanatory; it contains all the variables
                        needed for the driver and interface code to operate. Only one
                        ZP byte is defined for the driver. The rest are BSS defines.
                        
                        Note: 
                          The file doesn't need to be included in your ZP/BSS area, but
                          it makes it easier and more simplistic in the listing. 
                                  
   
                              
    Driver and Update Processor
    ===========================
    
       The PCM driver package is made up of two executing processes: the "driver" running
      in the TIRQ routine, and the "update processor" running in the VBLANKIRQ routine.
      Because the driver is constantly accessing the PCE's audio registers, and is a higher
      level of code execution than routines outside it, any attempt to change the audio
      registers (hardware) will result in the corruption. This is true for any routines
      that run a TIRQ for sample playback. To avoid this collision/corruption, you need a
      window of opportunity where you can safely update these registers.
      
       The update processor provides this "window" by resigning the Timer circuit to that
      of the VDC via vblank. Without it, the TIRQ relation to vblank would drift, causing
      timing issues. As an example, PCE games with DDA playback would solve this issue by
      placing the music/sfx engine itself inside the TIRQ routine allowing it to run async.

       In the case of this PCM driver, it's not just hardware registers that corrupt when
      updated; there are internal software registers that will collide/corrupt if updated
      outside the processing window. To take the stress off the programmer, and having to 
      deal directly with this specific window of time, the update processor does this for
      you. Using the macros to interface and make changes to specific channels, these
      routines write to a register buffer system. It allows the programmer to make changes
      during active display or other areas of a single NTSC frame. 
      
       The update processor takes the contents of the buffered registers and applies them
      during VBLANK call. It's advised not to try and update channel registers close to
      (right before) the update processor in the main "thread" because the vblank interrupt
      could execute in the middle of it and you'll get missed updates. The music or SFX
      engine should start/happen after the update processor is finished. There is a check
      system in which a busy flag is set when the update processor is running. This can be
      directly read via __UpdateProcFlag (value of 1 = busy) or via macro "ProcessingState"
      (z=0 is busy).
      
       The "driver" runs in ram (with no alignment limitations), uses self modifying code,
      and is able to play friendly with VDC Hsync interrupts. It has built-in protecting
      for case scenarios in which another TIRQ call is initiated when a previous one hasn't
      finished executing (though this shouldn't happen; it's there as a safety precaution).
      
       In the example test file, I have the TIRQ vector set to the place in ram where the
      driver will reside. It's extremely important that TRIQ's be off until the driver is
      copied to ram. The very-very-very first instruction on power-up should be SEI, for
      rom based projects. Although it's been tested that interrupts are disabled by default
      on power-up state, it's always better to be safe than sorry (this redundancy doesn't
      hurt to implement). Note: the equate label PCM_DRIVER is used for the TIRQ vector.
      
       There are three equates (immediate defines) that are required for setting up the
      driver in ram: TIMER_PLAYER, PCMDriverSize, and ram_driver. TIMER_PLAYER is the 
      localation of the driver in rom (or CDRAM) to be copied from. PCMDriverSize is the 
      size of the contents to be copied over to ram. Because of a specific bug in PCEAS
      involving equates (and compile math) and BSS segment defines (*1), the BSS define is
      created for you inside the driver.asm file. This is "ram_driver". A simple:
      tii TIMER_PLAYER, ram_driver, PCMDriverSize. Again, I provided a macro that does
      this for you: InitializeRamDriver (three args or four args depending). 
       
       Please note that if you're doing any sort of voodoo coding (alignment specific stuff
      in BSS/ram defines), and need specific control over the address of "ram_driver", you
      will need to comment out the define in the driver.asm file and manually define it
      somewhere else. Of course, if you're writing voodoo code, then this should be within
      your skillset.
      
       The driver and update processor can be individually paused. PausePCMDriver and
      ResumePCMDriver only affects the TIRQ driver and not the update processor. Pausing
      the driver results in a minimal resource drain on the processor per frame: 2.7%.
      No output or writes to audio hardware regs will occur. The TIRQ service will still
      run on schedule.
      
       The update processor is handled differently; each channel processing are individually
      turned on/off with a series of macros: HaltUpdateChan_X and ResumeUpdateChan_X. These
      will not stop the PCM driver from streaming samples or such. It only pauses the auto
      update processor that runs in sync with vblank, on a per channel basis. This can be
      effective if you're loading up a new song or such, and anticipate or want to take more
      than a single frame to initialize/setup the channel regs. Updating the regs while the
      update processor is disabled (via channels), will not have any effect on the current
      playing samples until ResumeUpdateChan_X is called (updates will happen next vblank).
            
    
    
    Frequency Control
    =================
    
       Channels 0 to 3 have frequency scaling. While the base driver runs at ~7khz, it's
      possible to playback a sample at a higher or lower rate. To keep things simple, and to
      keep the look-up tables small, I opted for linear scale in frequency. One advantage of
      this, is that the finesteps between note frequencies are the same regardless of what
      octave range you're currently in. One noticeable effect this has is on portamento and 
      vibratos. In a period based system, like the native PCE, Amiga, and NES systems, if you
      set a vibrato (frequency "wobble") to work with a specific range of octave for a note,
      and you slide up in frequency - that "wobble" will be more pronounced because each value
      in a period based system becomes a larger frequency jump. If you setup a vibrato envelope
      for a lower range note, and use it on a higher range note, it will be more pronounced.
      
       Thus such music engines tend to have different defined vibrato envelopes or such for 
      different note ranges. Using a linear frequency scale, like XM modules use, removes this
      side effect. It also requires less processing, and look-up table space, for certain FX 
      that require accuracy. This is all handled in the interface system, because the driver
      is simply using a Phase Accumulator style system.
      
       Now for the important bits. A frequency is made up for a note, octave, and finestep. A
      note ranges from 0 to 11 or C to B. An octave ranges from 0 to 7. And finesteps range
      from 0 to 31. Together the frequency is octave:note:finestep or base8:base12:base32. We
      need a bit of reference here so we can get our bearing; octave 3, note C, finestep 0 has
      a frequency playback of 7khz or 1:1 with the driver. Likewise octave 4, note C, finestep
      0 has a frequency of 14khz or 2:1 with the driver. Every octave greater by 1 from the
      previous, is double in frequency. And every octave less by 1 from the previous value is
      half that frequency. 
      
       This doesn't really have anything to do with the driver itself - it's just fundamental
      of how notes and octaves work. But what's being pointed out here, is that going above the
      nyquist limit, in this case 7khz, artifacts of frequencies will start to reflect back in
      to the output. Some samples are more susceptible to this than others. Likewise, going 
      down in octaves below the 7khz mark won't be of much good below octave 2. This is just
      the nature of sample based synthesis. If you want more "range" from you sampled sound, you
      will need have another pre-recorded one at a higher octave. This was the issue MODS and
      Amiga had to deal with back in the day.
      
       Getting back to the frequency control. If you want to slide a note up or down, to a note
      or just to infinity, it's as easy as choosing the rate. The rate is the tick*step. A tick
      is how ever you define a unit of time (in 1/60 frames obviously), and the step is how wide
      each frequency difference is. You could do something like finestep of +8. So every "tick"
      you add +8 to finestep. Since it's a base8:base12:base32, anything larger than finestep is
      MOD base 32, and the next base is increments (do the carry math) - the note increases. The
      nice thing about this system, is that the frequency slide is the same proportional increase
      regardless of the octave range (again, normally a problem with period based systems). The 
      sample principle works for vibrato FX.
      
       Samples can easily be "finetuned" with a base -16/+15 range via applying a signed offset
      to the finestep range. Because of how the frequency divider is built, and how finetune has
      the same proportions in steps regardless of octave or note ranges, simply adding a signed
      offset every time to the base8:base12:base32 frequency build, will retain its tuned offset
      range all the way through. This feature wasn't included in the macro package, because this
      is music engine domain implementation and not a sound driver related issue.
      
      
       
    Sample Format
    =============
    
       Included with the driver package and example test code is wav2sixbit. The utility outputs
      three files: 5bt, 6ss, and raw. Raw output is just 5bit PCM native PCE DDA format data.
      Raw and 6ss aren't used with specific driver. The 5bt format supports "forward" looping
      and is an automated process in the driver itself.
      
       The 5bt format is as follows:
       
          Header: 4bytes
                  byte 0-1:   Loop address (relative bank boundary: $0000 to $1fff).  
                  byte 2:     Loop bank (relative value).
                  byte 3:     $AB signature.
                  
          Sample data:        5bit PCE PCM in byte format. No compression.
          
          Control codes:
                  $80:        End of Sample.
                  $81:        Load loop start address and bank. 
      
      
       One thing to note: a sample can be loaded into a channel without any other parameters
      being changed or effected (just the sample address and loop information). This can be used
      to change out samples on a 1/60 frame basis. This technique can simulate waveform morphing
      or other type of filter type of FX through the use of multiple samples with the same
      characteristics (length and/or loop points). As of this version, support for this isn't 
      implemented. Future support will probably only include this feature for channels 0 to 3.
      
      
      
    Timing and Logistics
    ====================
       
       I tried to make this driver package as plug 'n play as possible. Unfortunately, there is
      something that needs to be taken into consideration: VDC interrupt. The PCE display is 
      capable of quite a bit of flexibility in its frame design, and this includes where VIRQ
      will fall within a VCE frame. This presents a problem because TIRQ happens every ~2.2505 
      VDC scanlines. If the update processor were to happen inside a TIRQ call, which can very
      well happen since TIRQ routine submits to all other interrupts, bad stuff can happen. A 
      step to correct this issue is re-sync'ing the TIRQ to vblank interrupt service, so that
      TIRQ pretty happens on the same intervals every frame.
      
       So as long as there's only one VIRQ happening per screen (sometimes using wrong settings
      can result in more than one VIRQ per VCE frame), the distance to the next frame is either
      262 scanlines or 263 scanlines (the +1/-1 difference depends on the H-filter used in the
      VCE reg). But it will always be ~that~ fixed distance away. And as long as is always re-
      sync'd via vblank interrupt.
      
       That's not good enough. A TIRQ happens every 1024 cpu clock cycles. The resync mothed
      makes sure there are only 116 TIRQ instances per frame. A quick calculation shows that the
      last TIRQ lands on scanline 261. 116 * 1024 = 118784 cycles. A scanline is ~ 455 cpu cycles.
      118,784 / ~455 = 261. VIRQ happens on scanline 262 (we're using base 1 not 0 here). So the
      TIRQ better finish within that 455 cycle window or vblank interrupt is going to happen in
      the middle of it. 
      
       If all six channels are in service via the driver, the minimum case scenario will pass
      this requirement, but the max case scenario will ~not~. This is unfortunately part of the 
      problem of having the frequency scaling done inside the TIRQ routine instead of outside
      (and buffered). While that method is doable, it also has its own timing logistics to deal
      with.
      
       Some numbers: if ~only~ 4 frequency channels were used, and no looping capable samples,
      the routine would max out at 458 cycles. This is enough room, barely, because the routine
      can be interrupted safely in the last 31 cycles of the routine without effect (it's just
      closing code). Max out refers to each sample stream hitting an LSB overflow and bank 
      overflow condition. The likelihood of all four channels hitting that scenario might be rare,
      but it's still a possibility.
      
       Now for some good news. If you set the VCE H-filter to 263 scanlines, the only thing that
      changes is the number of scanlines per frame. The scanline widths don't change. This mean
      the framerate actually changes slightly (enough for NTSC tolerances). A scanline is still
      roughly ~455 cpu cycles, but now you have 263 between each Vblank interrupt. That gives a
      window of 910cycles for the last TIRQ to finish. According to my calculations, worst case
      with all six channel case scenarios fits within that with some room to spare.
                            
                          
      Recommend use of 263 scanline mode for this driver. 
      
       Also, Txx instructions are bad. Even small ones. This TIRQ routine is going to run during
      vblank, so it's not even safe to use them there. If you like jitter, I mean if you REALLY
      like jitter.. then use Txx instructions during vblank. But don't be surprised if it sounds
      like a Genesis game doing voice samples ;>_>

       Note: Future revisions might ease up this timing issue, but at the cost of some more cpu
      cycle overhead.
      
       And lastly, don't put code in your vblank routine. Keep it short as possible. I mean less
      than 100 cycles short or so. Instead, have code waiting in your vblank loop (outside the
      vblank routine), that executes after a "waitblank" clear. The reason for this, is that the
      next TIRQ is going to happen 1024 cycles after the update processor resets the timer reg.
      If you do decide on an open interrupt for vblank routine (that is, clear interrupt flag) to
      run code inside of it, better use an internal flag/state to avoid overlapping VINTs. But
      of course that's your problem, not mine ;)
      
       There's a specific framework needed for this driver package to run correctly. I hope I
      conveyed enough information to make the apparent problems clear enough. This definitely is
      not a novice package to work it, despite all that I have done to make the interface as 
      seamless and easy as possible. 
      
       The driver code, being self-modifying and need relocation, looks a bit scary. If you are
      not comfortable editing the driver to remove/reduce PCM channel use, send me an email at
      tomaitheous@pcedev.net and I'll see what I can do.
      
    
    
    Equates
    =======
      
       Here are the equates/labels/immedates used for the driver and control interface.
       
       
          PCM_DRIVER      This is the vector label to assign for TIRQ.
          
          ram_driver      The location of the allocated memory for the driver.
          
          TIMER_PLAYER    The location of the driver when assembled into rom (or CDRAM).
          
          PCMDriverSize   The size of the driver.
          
          note_C          A note equate (ranges from 0 to 11). Used as an immediate.
                          All prefix notes are capitalized.
          
                Full list
                ---------
                  note_C        = 0
                  note_C_sharp  = 1
                  note_D        = 2
                  note_D_sharp  = 3
                  note_E        = 4
                  note_E_sharp  = 5
                  note_F        = 6 
                  note_G        = 7
                  note_G_sharp  = 8
                  note_A        = 9
                  note_A_sharp  = 10
                  note_B        = 11
                  
                  
          octave_3        An octave equate (ranges from 0 to 7). Used as an immediate.
          
                Full list
                ---------
                  octave_0      = 0
                  octave_1      = 1
                  octave_2      = 2
                  octave_3      = 3
                  octave_4      = 4
                  octave_5      = 5
                  octave_6      = 6
                  octave_7      = 7
                
                
          finestep_0      A finestep equate (ranges from 0 to 31). Used as an immediate.
          
                Full list
                ---------       
                  finestep_0    = 0
                  finestep_1    = 1
                  finestep_2    = 2
                  finestep_3    = 3
                  finestep_4    = 4
                  finestep_5    = 5
                  finestep_6    = 6
                  finestep_7    = 7
                  finestep_8    = 8
                  finestep_9    = 9
                  finestep_10   = 10
                  finestep_11   = 11
                  finestep_12   = 12
                  finestep_13   = 13
                  finestep_14   = 14
                  finestep_15   = 15
                  finestep_16   = 16
                  finestep_17   = 17
                  finestep_18   = 18
                  finestep_19   = 19
                  finestep_20   = 20
                  finestep_21   = 21
                  finestep_22   = 22
                  finestep_23   = 23
                  finestep_24   = 24
                  finestep_25   = 25
                  finestep_26   = 26
                  finestep_27   = 27
                  finestep_28   = 28
                  finestep_29   = 29
                  finestep_30   = 30
                  finestep_31   = 31       
         
         

    History
    =======
      
      7.03.2016:  Bug fix for channels 2,3,4 for sample looping.
    
      6.28.2016:  First official release. Version 1.2.0





   Further Info
   ============
  
    *1) If you define an equate, it can be used anywhere with code or data because PCEAS does
        a two pass system. But this doesn't apply to ZP/BSS segment areas. When it comes to
        this areas, the equates need to be define before using them in ZP/BSS. If you have the
        habit if putting your ZP/BSS at the top of the source file, this will give you problems
        and the error reported by the assembler won't indicate that it's a missing label. Most
        likely it will error on the next define in that ZP/BSS segment.

    *2) Only affects channels 0 to 3.
