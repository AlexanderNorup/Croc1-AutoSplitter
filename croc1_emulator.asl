/*
    Croc: Leged of the Gobbos (NTSC-U) Autosplitter
    By: Alexander Nørup
    Based on the work of: FranklyGD (https://gist.github.com/FranklyGD/c2cb3e35a14ba42f4b3890852b86a320)
*/

state ("EmuHawk", "2.6.1") { }
state ("EmuHawk", "2.6.2") { }
state ("EmuHawk", "2.6.3") { }
state ("EmuHawk", "2.9.1-octo") { }
state ("EmuHawk", "2.9.1-nyma") { }
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
    settings.Add("titleReset", true, "Reset timer when returning to title screen");

    // Duckstation Vars
    vars.duckstationProcessNames = new List<string> {
        "duckstation-qt-x64-ReleaseLTCG",
        "duckstation-nogui-x64-ReleaseLTCG",
    };

    Func<IEnumerable<MemoryBasicInformation>, IntPtr> defaultDynamicFinder = (memoryPages) => IntPtr.Zero;

    vars.dynamicFinder = defaultDynamicFinder;
    vars.dynamicAddressSearch  = false;
    vars.dynamicBaseRAMAddressFound  = false;
    vars.dynamicStopwatch = new Stopwatch();
    vars.ADDRESS_SEARCH_INTERVAL = 1000;

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
            case 0x482000:
            
            // Assuming they are running nymashock to start with
            version = "2.9.1-nyma"; 
            Func<IEnumerable<MemoryBasicInformation>, IntPtr> nymashock = (memoryPages) => {

                var baseEmulatorPage = memoryPages.Where(p => p.Type == MemPageType.MEM_MAPPED && p.RegionSize == (UIntPtr)0x1f2000).FirstOrDefault().BaseAddress;
                if(baseEmulatorPage != IntPtr.Zero){
                    print("Found nymashock at: " + baseEmulatorPage );
                    return baseEmulatorPage - 0xfd58;
                }
                
                // Could not find it. Maybe they're actually using octoshock?
                var otcoshock = modules.Where(x => x.ModuleName == "octoshock.dll").FirstOrDefault();
                if(otcoshock != null)
                {
                    version = "2.9.1-octo"; 
                    vars.dynamicAddressSearch = false;
                    print("Found otcoshock at: " + otcoshock.BaseAddress );
                    return otcoshock.BaseAddress + 0x124b30; 
                }

                return IntPtr.Zero;
            };

            vars.dynamicFinder = nymashock; 
            vars.dynamicAddressSearch = true;
            vars.baseRAMAddress = IntPtr.Zero;
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
        Func<IEnumerable<MemoryBasicInformation>, IntPtr> duckstationDynamicFinder = (memoryPages) => {
            var normalMemoryBlock = memoryPages.Where(p => p.Type == MemPageType.MEM_MAPPED && p.RegionSize == (UIntPtr)0x200000).FirstOrDefault().BaseAddress;

            if(normalMemoryBlock != IntPtr.Zero){
                print("Found Duckstation at: " + normalMemoryBlock + " (Normal block value)");
                return normalMemoryBlock;
            }

            var internalBlock = memoryPages.Where(p => p.Type == MemPageType.MEM_MAPPED && p.RegionSize == (UIntPtr)0x796000).FirstOrDefault().BaseAddress;
            if(internalBlock != IntPtr.Zero){
                print("Found Duckstation at: " + internalBlock + " (Internal block value)");
                return internalBlock - 0x6a000;
            }

            return IntPtr.Zero;
        };
        
        vars.dynamicFinder = duckstationDynamicFinder; 
        vars.dynamicAddressSearch = true;
        version = "any";
        vars.baseRAMAddress = IntPtr.Zero;
    }
}

update {
    if (version == "") {
        //print("This emulator is not supported!");
        return false;
    }

    if (vars.dynamicAddressSearch) {
        // Find base RAM address by searching it memory pages.
        // Do this periodically (using stopwatch to determine when to search again) 
        // instead of every update to reduce unnecessary computation.
        if (!vars.dynamicBaseRAMAddressFound) {
            if (!vars.dynamicStopwatch.IsRunning || vars.dynamicStopwatch.ElapsedMilliseconds > vars.ADDRESS_SEARCH_INTERVAL) {
                vars.dynamicStopwatch.Start();

                vars.baseRAMAddress = vars.dynamicFinder(game.MemoryPages(true));
                if (vars.baseRAMAddress == IntPtr.Zero) {
                    vars.dynamicStopwatch.Restart();
                    print("Failed to find dynamic baseRAMAddress :(");
                    return false;
                }
                else {
                    print("Succesfully found dynamic baseRAMAddress");
                    vars.dynamicStopwatch.Reset();
                    vars.dynamicBaseRAMAddressFound = true;
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
            vars.dynamicBaseRAMAddressFound = false;
            vars.baseRAMAddress = IntPtr.Zero;
            
            print("Dynamically found baseRAMAddress is no longer valid..");
            return false;
        }
    }

    
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
    // Debug logging 
    //print("MenuState read as: " + current.menuState);
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