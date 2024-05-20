# Croc1 AutoSplitter

This is an ASL autosplitter for Croc: Legend of the Gobbos for PS1.

It's built on the ground work of [FranklyGD](https://gist.github.com/FranklyGD)'s autosplitter for Spyro the Dragon (https://gist.github.com/FranklyGD/c2cb3e35a14ba42f4b3890852b86a320).

It is currently in "Beta" (might be forever, who knows).

## Features
1. Auto-splitting on level complete (when x-pressed)
2. Load-time removal (maybe a bit pointless for emulator runs)
3. Auto-reset on return to the title-screen
4. Auto-start on "Start Game" on the title-screen.

The auto-reset and load-time remover can be disabled through config.

Please note that this (as of writing) only as support for splitting individual levels! 

**FOR BEST EXPERIENCE**: Start LiveSplit AFTER your emulator is running. While it should™ technically find and attach dynamically, it works best if the autosplitter is started after the game. Especially for Bishawk and detecting which core to use. For Duckstation it should be fine if you start it afterwards. Restaring your emulator once attached should also be fine. But if you find it is not working, restarting LiveSplit is your best bet.

Demo:

https://github.com/AlexanderNorup/Croc1-AutoSplitter/assets/5619812/2d1dd0f4-b694-46a2-8d5a-a25ed9e62205

## Installing the autosplitter
1. Download the [`croc1_emulator.asl`](croc1_emulator.asl) file from this repository.
2. Open LiveSplit
3. Right Click your splits and select "Edit Layout.."
4. Click the "+" icon, expand "Control" and select "Scriptable Auto Splitter"
5. Double-click the "Scriptable Auto Splitter" from the layout list
6. Click "Browse..." and select the downloaded ASL file. 
7. Adjust any settings and press OK

If you want to make use of the load-less timer, press the "+" button again and add a "Timer" under "Timer". Double-click it and change the timing method to "Game Time". 

Since the leaderboards for Croc 1 only use RTA (Real Time Attack) you should still keep a real-time timer for getting your submission time.

## Supported emulators
**Tested to work**:
- ePSXe 1.9.0
- duckstation-qt-x64
- EmuHawk (BizHawk) (2.9.1) : Both otcoshock and nymashock cores

**Should would™**:
- ePSXe 1.9.25
- ePSXe 2.0.0
- XEBRA v. 210423d
- mednafen (1.24.1 -> 1.29.0) 32/64 bit
- EmuHawk (BizHawk) (2.6.1, 2.6.2 & 2.6.3)

## Known issues:
- The autosplitter sometimes is unable to attach to ePSXe. Starting LiveSplit as administrator should fix the issue. 

You can view logs using [Sysinternals DebugView](https://learn.microsoft.com/en-us/sysinternals/downloads/debugview).
