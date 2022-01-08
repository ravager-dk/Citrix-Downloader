<#
.SYNOPSIS
Download multiple VDA and ISO versions from Citrix.com
.DESCRIPTION
Download various Citrix components through a GUI without spending hours navigating through the various Citrix sub-sites.

.NOTES
  Version:          0.01.6
  Author:           Dan Challinor
  Creation Date:    2021-10-22

  // NOTE: Purpose/Change
  2020-06-20    Initial Version by Ryan Butler
  2021-10-22    Customization
  2021-12-22    Import of the download list into the script, no helper files needed anymore / Add Version Number and Version Check with Auto Update Function / Add Citrix 1912 CU4 and 2112 content / Add shortcut creation
  2021-12-23    Change password fields
  2022-01-07	Added Citrix ADC Downloads

#>


$CSV = @"
"dlnumber","filename","name"
"19993","Citrix_Virtual_Apps_and_Desktops_7_1912_4000.iso","Citrix Virtual Apps and Desktops 7 1912 CU4 ISO"
"20115","Citrix_Virtual_Apps_and_Desktops_7_2112.iso","Citrix Virtual Apps and Desktops 7 2112 ISO"

"19994","VDAServerSetup_1912.exe","Multi-session OS Virtual Delivery Agent 1912 LTSR CU4"
"19995","VDAWorkstationSetup_1912.exe","Single-session OS Virtual Delivery Agent 1912 LTSR CU4"
"19996","VDAWorkstationCoreSetup_1912.exe","Single-session OS Core Services Virtual Delivery Agent 1912 LTSR CU4"

"20116","VDAServerSetup_2112.exe","Multi-session OS Virtual Delivery Agent 2112"
"20117","VDAWorkstationSetup_2112.exe","Single-session OS Virtual Delivery Agent 2112"
"20118","VDAWorkstationCoreSetup_2112.exe","Single-session OS Core Services Virtual Delivery Agent 2112"

"19997","ProfileMgmt_1912.zip","Profile Management 1912 LTSR CU4"
"19803","ProfileMgmt_2112.zip","Profile Management 2112"

"19999","Citrix_Provisioning_1912_19.iso","Citrix Provisioning 1912 CU4"
"20119","Citrix_Provisioning_2112.iso","Citrix Provisioning 2112"

"9803","Citrix_Licensing_11.17.2.0_BUILD_37000.zip","License Server for Windows - Version 11.17.2.0 Build 37000"

"19998","CitrixStoreFront-x64.exe ","StoreFront 1912 LTSR CU4"

"20209","Workspace-Environment-Management-v-2112-01-00-01.zip","Workspace Environment Management 2112"

"20248","CitrixWorkspaceApp.exe","Citrix Workspace app 2112.1 for Windows"
"20217","CitrixWorkspaceApp.dmg","Citrix Workspace app 2112 for Mac"
"20213","CitrixWorkspaceApp.exe","Citrix Workspace app 19.12.6000 for Windows, LTSR Cumulative Update 6"

"20204","build-13.0-84.11_nc_64.tgz","Citrix ADC Release 13.0 Build 84.11(nCore)"
"20205","NSVPX-XEN-13.0-84.11_nc_64.xva.gz","Citrix ADC VPX for Citrix Hypervisor 13.0 Build 84.11"
"20206","NSVPX-ESX-13.0-84.11_nc_64.zip","Citrix ADC VPX for ESXi 13.0 Build 84.11"
"20252","NSVPX-HyperV-13.0-84.11_nc_64.zip","Citrix ADC VPX for Hyper-V 13.0 Build 84.11"
"20251","NSVPX-KVM-13.0-84.11_nc_64.tgz","Citrix ADC VPX for KVM 13.0 Build 84.11"
"20253","NSVPX-GCP-13.0-84.11_nc.tar.gz","Citrix ADC VPX for GCP 13.0 Build 84.11"
"20265","build-sdx-13.0-84.11.tgz","SDX Platform Software Bundle 13.0 Build 84.11"

"20184","build-13.1-12.51_nc_64.tgz","Citrix ADC Release 13.1 Build 12.51(nCore)"
"20185","NSVPX-XEN-13.1-12.51_nc_64.xva.gz","Citrix ADC VPX for Citrix Hypervisor 13.1 Build 12.51"
"20186","NSVPX-ESX-13.1-12.51_nc_64.zip","Citrix ADC VPX for ESXi 13.1 Build 12.51"
"20188","NSVPX-HyperV-13.1-12.51_nc_64.zip","Citrix ADC VPX for Hyper-V 13.1 Build 12.51"
"20187","NSVPX-KVM-13.1-12.51_nc_64.tgz","Citrix ADC VPX for KVM 13.1 Build 12.51"
"20189","NSVPX-GCP-13.1-12.51_nc.tar.gz","Citrix ADC VPX for GCP 13.1 Build 12.51"
"20201","build-sdx-13.1-12.51.tgz","SDX Platform Software Bundle 13.1 Build 12.51"

"20138","build-mas-13.1-12.50.tgz","Citrix ADM Upgrade Package - 13.1 Build 12.50"
"20142","MAS-XEN-13.1-12.50.xva.gz","Citrix ADM image for Citrix Hypervisor, 13.1 Build 12.50"
"20139","MAS-ESX-13.1-12.50.zip","Citrix ADM image for ESX, 13.1 Build 12.50"
"20140","ADM-HyperV-13.1-12.50.zip","Citrix ADM image for HyperV, 13.1 Build 12.50"

"8343","StorageCenter_5.11.21.msi","ShareFile StorageZones Controller 5.11.21"

"17421","CitrixHypervisor-8.2.1-install-cd.iso","Citrix Hypervisor 8.2 Base Installation ISO with Cumulative Update 1"
"17423","CitrixHypervisor-8.2.1-update.iso","Citrix Hypervisor 8.2 Cumulative Update 1"
"17426","CitrixHypervisor-8.2.4-XenCenter.msi","XenCenter 8.2.4"

"14254","XenServer-7.1.2-install-cd.iso","XenServer 7.1 Base Installation ISO with Cumulative Update 2"
"14257","XenServer-7.1.2-update.iso","XenServer 7.1 Cumulative Update 2"
"17348","XenServer-7.1.2-XenCenter-7.1.4.msi","XenCenter 7.1 CU2 Windows Management Console"

"19814","xms_10.14.0.6.xenserver.xva","XenMobile Server 10.14.0.6 (XenServer)"
"19815","xms_10.14.0.6.HyperV.zip","XenMobile Server 10.14.0.6 (HyperV)"
"19816","xms_10.14.0.6.vmware.ova","XenMobile Server 10.14.0.6 (VMWare)"
"19817","xms_10.14.0.6.bin","XenMobile Server 10.14.0.6 upgrade from 10.13 or 10.12"
"@

#Folder dialog
#https://stackoverflow.com/questions/25690038/how-do-i-properly-use-the-folderbrowserdialog-in-powershell
Function Get-Folder($initialDirectory)

{
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms")|Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder"
    $foldername.rootfolder = "MyComputer"

    if($foldername.ShowDialog() -eq "OK")
    {
        $folder += $foldername.SelectedPath
    }
    return ($folder + "\") 
}

#Prompt for folder path
$path = Get-Folder

function get-ctxbinary {
	<#
.SYNOPSIS
  Downloads a Citrix VDA or ISO from Citrix.com utilizing authentication
.DESCRIPTION
  Downloads a Citrix VDA or ISO from Citrix.com utilizing authentication.
  Ryan Butler 2/6/2020
.PARAMETER DLNUMBER
  Number assigned to binary download
.PARAMETER DLEXE
  File to be downloaded
.PARAMETER DLPATH
  Path to store downloaded file. Must contain following slash (c:\temp\)
.PARAMETER CitrixUserName
  Citrix.com username
.PARAMETER CitrixPW
  Citrix.com password
.EXAMPLE
  Get-CTXBinary -DLNUMBER "16834" -DLEXE "Citrix_Virtual_Apps_and_Desktops_7_1912.iso" -CitrixUserName "mycitrixusername" -CitrixPW "mycitrixpassword" -DLPATH "C:\temp\"
#>
	Param(
		[Parameter(Mandatory = $true)]$DLNUMBER,
		[Parameter(Mandatory = $true)]$DLEXE,
		[Parameter(Mandatory = $true)]$DLPATH,
		[Parameter(Mandatory = $true)]$CitrixUserName,
		[Parameter(Mandatory = $true)]$CitrixPW
	)
	#Initialize Session 
	Invoke-WebRequest "https://identity.citrix.com/Utility/STS/Sign-In?ReturnUrl=%2fUtility%2fSTS%2fsaml20%2fpost-binding-response" -SessionVariable websession -UseBasicParsing | Out-Null

	#Set Form
	$form = @{
		"persistent" = "on"
		"userName"   = $CitrixUserName
		"password"   = $CitrixPW
	}

	#Authenticate
	try {
		Invoke-WebRequest -Uri ("https://identity.citrix.com/Utility/STS/Sign-In?ReturnUrl=%2fUtility%2fSTS%2fsaml20%2fpost-binding-response") -WebSession $websession -Method POST -Body $form -ContentType "application/x-www-form-urlencoded" -UseBasicParsing -ErrorAction Stop | Out-Null
	}
	catch {
		if ($_.Exception.Response.StatusCode.Value__ -eq 500) {
			Write-Verbose "500 returned on auth. Ignoring"
			Write-Verbose $_.Exception.Response
			Write-Verbose $_.Exception.Message
		}
		else {
			throw $_
		}

	}
	$dlurl = "https://secureportal.citrix.com/Licensing/Downloads/UnrestrictedDL.aspx?DLID=${DLNUMBER}&URL=https://downloads.citrix.com/${DLNUMBER}/${DLEXE}"
	$download = Invoke-WebRequest -Uri $dlurl -WebSession $websession -UseBasicParsing -Method GET
	$webform = @{ 
		"chkAccept"            = "on"
		"clbAccept"            = "Accept"
		"__VIEWSTATEGENERATOR" = ($download.InputFields | Where-Object { $_.id -eq "__VIEWSTATEGENERATOR" }).value
		"__VIEWSTATE"          = ($download.InputFields | Where-Object { $_.id -eq "__VIEWSTATE" }).value
		"__EVENTVALIDATION"    = ($download.InputFields | Where-Object { $_.id -eq "__EVENTVALIDATION" }).value
	}

	$outfile = ($DLPATH + $DLEXE)
	#Download
	Invoke-WebRequest -Uri $dlurl -WebSession $websession -Method POST -Body $webform -ContentType "application/x-www-form-urlencoded" -UseBasicParsing -OutFile $outfile
	return $outfile
}

# Disable progress bar while downloading
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'

# Is there a newer Evergreen Script version?
# ========================================================================================================================================
$eVersion = "0.01.6"
[bool]$NewerVersion = $false
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$WebResponseVersion = Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/eucexpert/Citrix-Downloader/main/Citrix-Downloader.ps1"
If (!$WebVersion) {
    $WebVersion = (($WebResponseVersion.tostring() -split "[`r`n]" | select-string "Version:" | Select-Object -First 1) -split ":")[1].Trim()
}
If ($WebVersion -gt $eVersion) {
    $NewerVersion = $true
}

# Shortcut Creation
If (!(Test-Path -Path "$env:USERPROFILE\Desktop\Citrix Downloader.lnk")) {
    $WScriptShell = New-Object -ComObject 'WScript.Shell'
    $ShortcutFile = "$env:USERPROFILE\Desktop\Citrix Downloader.lnk"
    $Shortcut = $WScriptShell.CreateShortcut($ShortcutFile)
    $Shortcut.TargetPath = "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
    $Shortcut.WorkingDirectory = "C:\Windows\System32\WindowsPowerShell\v1.0"
    If (!(Test-Path -Path "$PSScriptRoot\shortcut")) { New-Item -Path "$PSScriptRoot\shortcut" -ItemType Directory | Out-Null }
    If (!(Test-Path -Path "$PSScriptRoot\shortcut\CitrixDownloaderLogo.ico")) {Invoke-WebRequest -Uri https://raw.githubusercontent.com/eucexpert/Citrix-Downloader/main/shortcut/CitrixDownloaderLogo.ico -OutFile ("$PSScriptRoot\shortcut\" + "CitrixDownloaderLogo.ico")}
    $shortcut.IconLocation="$PSScriptRoot\shortcut\CitrixDownloaderLogo.ico"
    $Shortcut.Arguments = '-noexit -ExecutionPolicy Bypass -file "' + "$PSScriptRoot" + '\Citrix-Downloader.ps1"'
    $Shortcut.Save()
}
If (!(Test-Path -Path "$PSScriptRoot\img\CitrixDownloaderLogo.png")) {
    If (!(Test-Path -Path "$PSScriptRoot\img")) { New-Item -Path "$PSScriptRoot\img" -ItemType Directory | Out-Null }
    Invoke-WebRequest -Uri https://raw.githubusercontent.com/eucexpert/Citrix-Downloader/main/img/CitrixDownloaderLogo.png -OutFile ("$PSScriptRoot\img\" + "CitrixDownloaderLogo.png")
}

# Script Version
# ========================================================================================================================================
Write-Output ""
Write-Host -BackgroundColor DarkGreen -ForegroundColor Yellow "                     Citrix Downloader                      "
Write-Host -BackgroundColor DarkGreen -ForegroundColor Yellow "                       Dan Challinor                        "
Write-Host -BackgroundColor DarkGreen -ForegroundColor Yellow "                      Version $eVersion                        "
$host.ui.RawUI.WindowTitle ="Citrix Downloader - Dan Challinor - Version $eVersion"

If (!($NoUpdate)) {
    Write-Output ""
    Write-Host -Foregroundcolor DarkGray "Is there a newer Citrix Downloader version?"
    
    If ($NewerVersion -eq $false) {
        # No new version available
        Write-Host -Foregroundcolor Green "OK, script is newest version!"0.
        Write-Output ""
    }
    Else {
        # There is a new Evergreen Script Version
        Write-Host -Foregroundcolor Red "Attention! There is a new version of Citrix Downloader."
        Write-Output ""
        If ($file) {
            $update = @'
                Remove-Item -Path "$PSScriptRoot\Citrix-Downloader.ps1" -Force 
                Invoke-WebRequest -Uri https://raw.githubusercontent.com/eucexpert/Citrix-Downloader/main/Citrix-Downloader.ps1 -OutFile ("$PSScriptRoot\" + "Citrix-Downloader.ps1")
                & "$PSScriptRoot\Citrix-Downloader.ps1" -download -file $file
'@
            $update > $PSScriptRoot\update.ps1
            & "$PSScriptRoot\update.ps1"
            Break
        }
        ElseIf ($GUIfile) {
            $update = @'
            Remove-Item -Path "$PSScriptRoot\Citrix-Downloader.ps1" -Force 
            Invoke-WebRequest -Uri https://raw.githubusercontent.com/eucexpert/Citrix-Downloader/main/Citrix-Downloader.ps1 -OutFile ("$PSScriptRoot\" + "Citrix-Downloader.ps1")
                & "$PSScriptRoot\Citrix-Downloader.ps1" -download -GUIfile $GUIfile
'@
            $update > $PSScriptRoot\update.ps1
            & "$PSScriptRoot\update.ps1"
            Break
            
        }
        Else {
            $wshell = New-Object -ComObject Wscript.Shell
            $AnswerPending = $wshell.Popup("Do you want to download the new version?",0,"New Version Alert!",32+4)
            If ($AnswerPending -eq "6") {
                Start-Process
                $update = @'
                    Remove-Item -Path "$PSScriptRoot\Citrix-Downloader.ps1" -Force 
                    Invoke-WebRequest -Uri https://raw.githubusercontent.com/eucexpert/Citrix-Downloader/main/Citrix-Downloader.ps1 -OutFile ("$PSScriptRoot\" + "Citrix-Downloader.ps1")
                    & "$PSScriptRoot\Citrix-Downloader.ps1"
'@
                $update > $PSScriptRoot\update.ps1
                & "$PSScriptRoot\update.ps1"
                Break
            }
        }
    }
}


$creds = Get-Credential -Message "Citrix Credentials"
$CitrixUserName = $creds.UserName
$CitrixPW = $creds.GetNetworkCredential().Password

#Imports $CSV with download information
$downloads = $CSV | ConvertFrom-Csv -Delimiter ","

#Use CTRL to select multiple
$dls = $downloads | Out-GridView -PassThru -Title "Select Installer or ISO to download. CTRL to select multiple"

#Processes each download
foreach ($dl in $dls) {
    write-host "Downloading $($dl.filename)..."
    Get-CTXBinary -DLNUMBER $dl.dlnumber -DLEXE $dl.filename -CitrixUserName $CitrixUserName -CitrixPW $CitrixPW -DLPATH $path
}