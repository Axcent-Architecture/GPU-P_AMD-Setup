#################
### Variables ###
#################

$currentDate = $(Get-date -f "yyyy-MM-dd_hh-mm-ss")
$backupDirectory = "$HOME\Downloads\AMD-Display-Drivers-Backup_$currentDate"

class BackupObject {
    [string]$Destination
    [string]$Source
    [string[]]$SourceFiles
}

$system32 = [BackupObject]::new()
$system32.Destination = "$backupDirectory\System32"
$system32.Source = "$env:windir\System32"
$system32.SourceFiles = @(
    'amd_comgr.dll',
    'amdave64.dll',
    'amdgfxinfo64.dll',
    'amdhip64.dll',
    'amdihk64.dll',
    'amdlogum.exe',
    'amdlvr64.dll',
    'amdmiracast.dll',
    'amdpcom64.dll',
    'amdxc64.dll',
    'amf-mft-mjpeg-decoder64.dll',
    'amfrt64.dll',
    'atiacm64.dll',
    'atiacmLocalisation.ini',
    'atiadlxx.dll',
    'atiapfxx.blb',
    'aticfx64.dll',
    'atidemgy.dll',
    'atidxx64.dll',
    'atieah64.exe',
    'atieclxx.exe',
    'atig6txx.dll',
    'atimpc64.dll',
    'atimuixx.dll',
    'atisamu64.dll',
    'atiumd6a.cap',
    'ativvsva.dat',
    'ativvsvl.dat',
    'branding.bmp',
    'brandingRSX.bmp',
    'brandingWS_RSX.bmp',
    'clinfo.exe',
    'detoured.dll',
    'dgtrayicon.exe',
    'EEURestart.exe',
    'GameManager64.dll',
    'kapp_ci.sbin',
    'kapp_si.sbin',
    'mantle64.dll',
    'mantleaxl64.dll',
    'mcl64.dll',
    'OpenCL.dll',
    'Rapidfire64.dll',
    'RapidfireServer64.dll',
    'samu_krnl_ci.sbin',
    'samu_krnl_isv_ci.sbin',
    'vulkan-1.dll',
    'vulkan-1-999-0-0-0.dll',
    'vulkaninfo.exe',
    'vulkaninfo-1-999-0-0-0.exe'
)

$amd = [BackupObject]::new()
$amd.Destination = "$backupDirectory\System32\AMD\amdkmpfd"
$amd.Source = "$env:windir\System32\AMD\amdkmpfd"
$amd.SourceFiles = @(
    'amdkmpfd.ctz',
    'amdkmpfd.itz',
    'amdkmpfd.stz'
)

$driverStore = [BackupObject]::new()
$driverStore.Destination = "$backupDirectory\System32\HostDriverStore\FileRepository"
$driverStore.Source = $(Get-ChildItem "$env:windir\System32\DriverStore\FileRepository\u0*").FullName

$sysWOW64 = [BackupObject]::new()
$sysWOW64.Destination = "$backupDirectory\SysWOW64"
$sysWOW64.Source = "$env:windir\SysWOW64"
$sysWOW64.SourceFiles = @(
    'amd_comgr32.dll',
    'amdave32.dll',
    'amdgfxinfo32.dll',
    'amdihk32.dll',
    'amdlvr32.dll',
    'amdpcom32.dll',
    'amdxc32.dll',
    'amf-mft-mjpeg-decoder32.dll',
    'amfrt32.dll',
    'atiadlxx.dll',
    'atiapfxx.blb',
    'aticfx32.dll',
    'atidxx32.dll',
    'atieah32.exe',
    'atigktxx.dll',
    'atimpc32.dll',
    'atisamu32.dll',
    'atiumdva.cap',
    'ativvsva.dat',
    'ativvsvl.dat',
    'detoured.dll',
    'GameManager32.dll',
    'mantle32.dll',
    'mantleaxl32.dll',
    'mcl32.dll',
    'OpenCL.dll',
    'Rapidfire.dll',
    'RapidfireServer.dll',
    'vulkan-1.dll',
    'vulkan-1-999-0-0-0.dll',
    'vulkaninfo.exe',
    'vulkaninfo-1-999-0-0-0.exe'
)

#################
### Functions ###
#################

<#
.SYNOPSIS
Verifies that the specified files exist in the specified directory.

.DESCRIPTION
Verifies that the specified files exist in the specified directory. This ensures we didn't miss copying any files.

.PARAMETER Directory
Directory where the files are expected to be present.

.PARAMETER Files
The files array of which files should be present.

.EXAMPLE
Test-Files -Directory "C:\Windows" -Files @('test.dll', 'test2.dll)
#>
Function Test-Files
{
    [CmdletBinding()]
    param([string]$Directory, [string[]]$Files)

    if(!(Test-Path $Directory))
    {
        Write-Error "Could not find directory: $Directory"
        Exit 1
    }

    $DirectoryName = $(Get-ChildItem -Filter $Directory).Name

    # Return if directory was found and no files were present
    if($null -eq $Files)
    {
        Write-Host -BackgroundColor Green -ForegroundColor Black "Found the $DirectoryName directory!"
        Return $true
    }

    # If files were found and the directory was found,
    # check if files exist.
    $FilesNotFound = [System.Collections.ArrayList]@()

    $Files | ForEach-Object{
        if(!(Test-Path -Path "$Directory\$_"))
        {
            $FilesNotFound.Add($_) > $null
        }
    }


    if($FilesNotFound.Length -gt 0) {
        Write-Error "Could not find $DirectoryName files: $($FilesNotFound | ForEach-Object{ $_ + "`r`n" })"
        Exit 2
    }

    Write-Host -BackgroundColor Green -ForegroundColor Black "Found all $DirectoryName files!"
    Return $true
}

<#
.SYNOPSIS
Copies files from directories or just directories if files are not specified.

.DESCRIPTION
Copies files from directories or just directories if files are not specified.

.PARAMETER Destination
Destination to copy files to

.PARAMETER Source
Source to copy files from

.PARAMETER SourceFiles
Specific files to copy

.EXAMPLE
Just copy directory
Copy-Files -BackupDirectory $backupDriversDirectory -Directory $driversDirectory

Copy specific files
Copy-Files -BackupDirectory $backupDriversDirectory -Directory $driversDirectory -Files @('test1', 'test2.txt')
#>
Function Copy-Files
{
    param([string]$Destination, [string]$Source, [string[]] $SourceFiles)
    mkdir $Destination

    if($null -eq $SourceFiles)
    {
        Copy-Item -Recurse $Source $Destination
    }
    else
    {
        $SourceFiles | ForEach-Object{
            Copy-Item -Recurse "$Source\$_" $Destination
        }
    }
}

#####################
### END Functions ###
#####################

###################
### DO THE WORK ###
###################

##############################
### PART I: Checking Files ###
##############################

Test-Files -Directory $system32.Source -Files $system32.SourceFiles
Test-Files -Directory $amd.Source -Files $amd.SourceFiles
Test-Files -Directory $driverStore.Source
Test-Files -Directory $sysWOW64.Source -Files $sysWOW64.SourceFiles

############################################
### PART II: Creating Backup Directories ###
############################################

Copy-Files -Destination $system32.Destination -Source $system32.Source -SourceFiles $system32.SourceFiles
Copy-Files -Destination $amd.Destination -Source $amd.Source -SourceFiles $amd.SourceFiles
Copy-Files -Destination $driverStore.Destination -Source $driverStore.Source
Copy-Files -Destination $sysWOW64.Destination -Source $sysWOW64.Source -SourceFiles $sysWOW64.SourceFiles

###############################
### PART III: Zip the files ###
###############################

Compress-Archive -Path $backupDirectory -DestinationPath "$backupDirectory.zip" -CompressionLevel Optimal

#####################
### DONE THE WORK ###
#####################