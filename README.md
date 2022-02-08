# GPU-P_AMD-Setup



## Setup GPU-P

### Part 1: Host Machine

TL;DR
Download the PS1 script and run it.
```powershell
powershell.exe -ExecutionPolicy ByPass -File backup-amd-display-drivers.ps1
```

This copies the appropriate AMD Drivers for use in the Hyper-V configuration for GPU-P.

**OR... THE LONG WAY**

1. WIN + R
2. devmgmt.msc
3. Display Adapters > AMD Radeon ABC
4. Right-Click > Properties > Driver > Details
5. Copy files to VM *IN THE EXACT LOCATION* (I used NAS approach from the video to copy)

_**NOTE: The last files starting with "u" are found in the C:\Windows\System32\DriverStore\FileRepository**_

### Part 2: VM Machine

1. Extract files from PART 1 into the exact location on the new VM (except the last folder starting w/ "u" must go in  "C:\Windows\System32\HostDriverStore\FileRepository" like the video says)
2. Restart VM

### Part 3: Verification
1. WIN + R
2. dxdiag
3. "Display" should be "Microsoft Hyper-V Video" BUT "Render" should be "AMD Radeon ABC"
