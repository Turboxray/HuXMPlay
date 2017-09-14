

  HuPCM: Example using HuXMPlayer
  ===============================
  
  
    What is it?
    ==========
    
       This is a example build of HuPCM driver using HuXMPlayer to output 4
      channels of realtime frequency scaled waveforms to play songs. Please
      read the README.txt in the HuPCM folder for a detailed explanation of
      how the driver works and how to interface it.
      
       Sorry, not a lot of comments on how things are setup. It's on my todo
      list. Also, all files are in a single directory because of some problems
      PCEAS used to have with certain setups. It might not apply to this project,
      but I kept it simple to keep things in working order.
      
      
    How to use
    ==========
    
       A batch file is included, go.bat, for windows command environment. The
      compiler PCEAS2 is also provided, but it's a windows build as well. The
      file output is main.pce. It's a binary rom file for the PC-Engine/Turbo-
      Grafx 16 machine. It can used with an emulator. Mednafen (PC/mac/linux)
      is highly recommended because of ita accuracy in timer and audio emulation.
      Other emulators might produced subpar audio performance (it's already a
      low playback rate with nearest neighbor scaling, and 5bit per waveform
      output).      
      
      
      
      Rick Leverton '2017
