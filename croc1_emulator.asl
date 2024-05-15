/*
    Croc: Leged of the Gobbos (NTSC-U) Autosplitter
    By: Alexander Nørup
    Based on the work of: FranklyGD (https://gist.github.com/FranklyGD/c2cb3e35a14ba42f4b3890852b86a320)
*/

state ("EmuHawk", "2.6.1") { }
state ("EmuHawk", "2.6.2") { }
state ("EmuHawk", "2.6.3") { }
state ("mednafen", "1.24.1 32bit") { }
state ("mednafen", "1.24.1 64bit") { }
state ("mednafen", "1.24.2 32bit") { }
state ("mednafen", "1.24.2 64bit") { }
state ("mednafen", "1.24.3 32bit") { }
state ("mednafen", "1.24.3 64bit") { }
state ("mednafen", "1.26.1 32bit") { }
state ("mednafen", "1.26.1 64bit") { }
state ("mednafen", "1.27.1 32bit") { }
state ("mednafen", "1.27.1 64bit") { }
state ("mednafen", "1.29.0 32bit") { }
state ("mednafen", "1.29.0 64bit") { }
state ("ePSXe", "1.9.0") { }
state ("ePSXe", "1.9.25") { }
state ("ePSXe", "2.0.0") { }
state ("XEBRA", "210423d") { }
state ("duckstation-qt-x64-ReleaseLTCG", "any") { }
state ("duckstation-nogui-x64-ReleaseLTCG", "any") { }

startup {
    settings.Add("loadPause", true, "Pause loadless timer when loading levels (does not apply to Real Time)");
    // settings.Add("dragonPause", true, "Pause loadless timer during dragon loads (does not apply to Real Time)");
    settings.Add("titleReset", true, "Reset timer when returning to title screen");
    // settings.Add("balloonSplit", true, "Split when traveling between homeworlds");
    // settings.Add("levelSplit", true, "Split when traveling within a homeworld (i.e. returning home and specific level entries defined below)");
    // settings.Add("gnexusSplit", false, "(Any%) Do not split when returning from Gnorc Cove and Twilight Harbor, split upon entering Gnasty Gnorc");
    // settings.Add("gnastySplit", true, "(Any%) Split on final hit on Gnasty Gnorc");
    // settings.Add("lootSplit", false, "(120%) Split when entering Gnasty's Loot");
    // settings.Add("tucoSplit", false, "(Vortex) Split when Tuco warps you to another world that he suggests to go to");
    // settings.Add("vortexSplit", false, "(Vortex) Do not split when returning from Dry Canyon or Cliff Town, split upon entering Dr. Shemp");
    // settings.Add("dragonSplit", false, "(80 Dragons) Split when the freed dragon count reaches 80");
    // settings.Add("eggSplit", false, "(All Eggs) Split when 12th egg is collected"); //debated split time, this should do though
    // settings.Add("pinkSplit", false, "(Pink Gem%) Split on final Pink Gem collected by Gnasty Gnorc");
    // settings.Add("balloonStart", false, "(Homeworld Practice) Start timer when travelling between homeworlds");

    // Duckstation Vars
    vars.duckstationProcessNames = new List<string> {
        "duckstation-qt-x64-ReleaseLTCG",
        "duckstation-nogui-x64-ReleaseLTCG",
    };
    vars.duckstation = false;
    vars.duckstationBaseRAMAddressFound  = false;
    vars.duckstationStopwatch = new Stopwatch();
    vars.DUCKSTATION_ADDRESS_SEARCH_INTERVAL = 1000;

    vars.baseRAMAddress = IntPtr.Zero;
    
    // Controller states
    vars.startPressed = (1 << 3);
    vars.xPressed = (1 << 14);
    // Used to ensure debounce on start-detection
    vars.hasBeenOneFrameOnMenuWithoutButtons = false;
    // Debounce on splits
    vars.splitOnLevelComplete = false;
}

init {
    refreshRate = 60;

    var mainModule = modules.First();
    switch (mainModule.ModuleMemorySize) {
        // Bizhawk
        case 0x456000:
            version = "2.6.1";
            vars.baseRAMAddress = modules.Where(x => x.ModuleName == "octoshock.dll").First().BaseAddress + 0x310f80;
            break;
            case 0x454000:
            version = "2.6.2";
            vars.baseRAMAddress = modules.Where(x => x.ModuleName == "octoshock.dll").First().BaseAddress + 0x30df80;
            break;
            case 0x45a000:
            version = "2.6.3";
            vars.baseRAMAddress = modules.Where(x => x.ModuleName == "octoshock.dll").First().BaseAddress + 0x30df80;
            break;
        // Mednafen
        case 0x42c9000:
            version = "1.24.1 32bit";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x1c96560;
            break;
        case 0x5eef000:
            version = "1.24.1 64bit";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x25bf280;
            break;
        case 0x42c6000:
            version = "1.24.2 32bit";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x1c93560;
            break;
        case 0x5eec000:
            version = "1.24.2/1.24.3 64bit";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x25bc280;
            break; 
        case 0x42c7000:
            version = "1.24.3/1.26.1 32bit";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x1c94560;
            break;
        case 0x5e83000:
            version = "1.26.1 64 bit";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x2553280;
            break;
        case 0x3a44000:
            version = "1.27.1 32bit";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x13ff160;
            break;
        case 0x55f1000:
            version = "1.27.1 64bit";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x1cade80;
            break;
        case 0x3C81000:
            version = "1.29.0 32bit";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x1438160;
            break;
        case 0x574B000:
            version = "1.29.0 64bit";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x1C03E80;
            break;
        // ePSXe
        case 0x9d3000:
            version = "1.9.0";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x6579A0;
            break;
        case 0xa08000:
            version = "1.9.25";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x68b6a0;
            break;
        case 0x1359000:
            version = "2.0.0";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x81a020;
            break;
        // XEBRA
        case 0xbd000:
            version = "210423d";
            vars.baseRAMAddress = mainModule.BaseAddress + 0x3110000;
            break;
        // DuckStation or unsupported
        default:
            break;
    }

    // Unfortunately, duckstation doesn't have a static base RAM address,
    // so we'll have to keep track of it in the update block.
    if (vars.duckstationProcessNames.Contains(game.ProcessName)) {
        vars.duckstation = true;
        version = "any";
        vars.baseRAMAddress = IntPtr.Zero;
    }
}

update {
    if (version == "") {
        //print("This emulator is not supported!");
        return false;
    }

    if (vars.duckstation) {
        // Find base RAM address in Duckstation by searching its memory pages.
        // Do this periodically (using stopwatch to determine when to search again) 
        // instead of every update to reduce unnecessary computation.
        if (!vars.duckstationBaseRAMAddressFound) {
            if (!vars.duckstationStopwatch.IsRunning || vars.duckstationStopwatch.ElapsedMilliseconds > vars.DUCKSTATION_ADDRESS_SEARCH_INTERVAL) {
                vars.duckstationStopwatch.Start();
                
                vars.baseRAMAddress = game.MemoryPages(true).Where(p => p.Type == MemPageType.MEM_MAPPED && p.RegionSize == (UIntPtr)0x200000).FirstOrDefault().BaseAddress;
                if (vars.baseRAMAddress == IntPtr.Zero) {
                    vars.duckstationStopwatch.Restart();
                    print("Failed to find DuckStations's baseRAMAddress :(");
                    return false;
                }
                else {
                    print("Succesfully found DuckStation's baseRAMAddress");
                    vars.duckstationStopwatch.Reset();
                    vars.duckstationBaseRAMAddressFound = true;
                }
            }
            else {
                return false;
            }
        }
        
        // Verify base RAM address is still valid on each update
        IntPtr temp1 = vars.baseRAMAddress;
        IntPtr temp2 = IntPtr.Zero;
        if (!game.ReadPointer(temp1, out temp2)) {
            vars.duckstationBaseRAMAddressFound = false;
            vars.baseRAMAddress = IntPtr.Zero;
            
            print("DuckStation's baseRAMAddress is no longer valid..");
            return false;
        }
    }

    // Address assignment has been moved to update block to support Duckstation's
    // changing base RAM address. The performance impact of this should
    // be negligible for non-Duckstation users, 
    // and it reduces code complexity to have it once here.
    
    // States
    vars.levelCompleteShown = vars.baseRAMAddress + 0x074acc;
    vars.levelCompleteConfirmed = vars.baseRAMAddress + 0x074e70;
    vars.menuState = vars.baseRAMAddress + 0x0748ec;
    vars.menuSelectedIndex = vars.baseRAMAddress + 0x0751dc;
    vars.controllerState = vars.baseRAMAddress + 0x07bf42;

    // Counters
    vars.framesSinceBoot = vars.baseRAMAddress + 0x073ac0;
    // framesSinceBootWithoutLoading is a bad name, because it does count the frames, the value just isn't updated when loading.
    // So you can check the loading state by checking if framesSinceBoot != framesSinceBootWithoutLoading
    vars.framesSinceBootWithoutLoading = vars.baseRAMAddress + 0x0729a8;

    // Read memory
    current.levelCompleteShown = memory.ReadValue<uint>((IntPtr)vars.levelCompleteShown);
    current.levelCompleteConfirmed = memory.ReadValue<uint>((IntPtr)vars.levelCompleteConfirmed);
    current.menuState = memory.ReadValue<uint>((IntPtr)vars.menuState);
    current.menuSelectedIndex = memory.ReadValue<uint>((IntPtr)vars.menuSelectedIndex);
    current.controllerState = memory.ReadValue<uint>((IntPtr)vars.controllerState);
    
    current.framesSinceBoot = memory.ReadValue<uint>((IntPtr)vars.framesSinceBoot);
    current.framesSinceBootWithoutLoading = memory.ReadValue<uint>((IntPtr)vars.framesSinceBootWithoutLoading);
    
    // Set controller buttons
    current.startPressed = (current.controllerState & vars.startPressed) == 0;
    current.xPressed = (current.controllerState & vars.xPressed) == 0;
}
 
start {
    if(current.menuState == 0) // MenuState 0: The "press start" on the title screen
    {
        vars.hasBeenOneFrameOnMenuWithoutButtons = false;
    }
    else if(current.menuState == 1 && !current.startPressed && !current.xPressed )
    {
        vars.hasBeenOneFrameOnMenuWithoutButtons = true;
        return false;
    }
    
    if(vars.hasBeenOneFrameOnMenuWithoutButtons 
        && current.menuState == 1 // MenuState 1: The main title screen
        && current.menuSelectedIndex == 0
        && ( current.startPressed || current.xPressed ))
    {
        return true;
    }
    
    return false;
}

reset {
    // Reset when the game is currently on the main menu ("press start"-part)
    return settings["titleReset"] && current.menuState == 0;
}

split {
   
    if(current.levelCompleteShown == 0){
        vars.splitOnLevelComplete = false;
        return false;
    }
   
    if(!vars.splitOnLevelComplete
        && current.levelCompleteShown == 1 
        && current.levelCompleteConfirmed == 1){
        vars.splitOnLevelComplete = true;
        return true;
    }
 
    return false;
}

isLoading {
    return settings["loadPause"] && 
            ( current.framesSinceBoot - current.framesSinceBootWithoutLoading ) > 1;
}