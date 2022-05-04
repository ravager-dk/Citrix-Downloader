#requires -Modules Microsoft.PowerShell.ConsoleGuiTools
<#
.SYNOPSIS
Download multiple VDA and ISO versions from Citrix.com
.DESCRIPTION
Download various Citrix components without a GUI without spending hours navigating through the various Citrix sub-sites.

.NOTES
  Version:          0.02.3
  Author:           Martin Nygaard Jensen
  Creation Date:    2021-10-22

  // NOTE: Purpose/Change
  2020-06-20    Initial Versions by Ryan Butler and Dan Challinor
  2021-10-22    Customization
  2021-12-22    Import of the download list into the script, no helper files needed anymore / Add Version Number and Version Check with Auto Update Function / Add Citrix 1912 CU4 and 2112 content / Add shortcut creation
  2021-12-23    Change password fields
  2022-01-07	  Added Citrix ADC Downloads
  2022-01-11    Made crossplatform - removing GUI components
  2022-01-11    Made into own solution

#>
[CmdletBinding()]
param (
  [string]$path = $PSScriptRoot,
  [switch]$AutoUpdate,
  [switch]$DoNotRefresh
)
import-module Microsoft.PowerShell.ConsoleGuiTools
$eVersion = "0.02.3"
$CSV = Get-Content -Path ($PSScriptRoot + "/resources/downloads.csv")

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

  $outfile = join-path -Path $DLPATH -ChildPath $DLEXE
  #Download
  Invoke-WebRequest -Uri $dlurl -WebSession $websession -Method POST -Body $webform -ContentType "application/x-www-form-urlencoded" -UseBasicParsing -OutFile $outfile
  return $outfile
}

function get-updatedlist {
  param ()
  If (!(Test-Path -Path "$PSScriptRoot\resources")) { New-Item -Path "$PSScriptRoot\resources" -ItemType Directory | Out-Null }
  Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ravager-dk/Citrix-Downloader/main/resources/downloads.csv" -OutFile ("$PSScriptRoot\resources\downloads.csv")
}

# Disable progress bar while downloading
$ProgressPreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'

If ((!($DoNotRefresh)) -or (!(Test-Path -Path "$PSScriptRoot\resources\downloads.csv")))
{
  get-updatedlist
}

# Is there a newer Evergreen Script version?
# ========================================================================================================================================

[bool]$NewerVersion = $false
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$WebResponseVersion = Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/ravager-dk/Citrix-Downloader/main/Citrix-Downloader.ps1"
If (!$WebVersion) {
  $WebVersion = (($WebResponseVersion.tostring() -split "[`r`n]" | select-string "Version:" | Select-Object -First 1) -split ":")[1].Trim()
}
If ($WebVersion -gt $eVersion) {
  $NewerVersion = $true
}

# Script Version
# ========================================================================================================================================
Write-Output ""
write-output "                     Citrix Downloader                      "
write-output "                   Martin Nygaard Jensen                    "
write-output "                      Version $eVersion                        "

Write-Output ""
Write-Output "Is there a newer Citrix Downloader version?"


If ($NewerVersion -eq $false) {
  # No new version available
  Write-Output "OK, script is newest version!"0.
  Write-Output ""
}
Else {
  # There is a new Evergreen Script Version
  Write-Output "Attention! There is a new version of Citrix Downloader."
  Write-Output ""
  If ($AutoUpdate) {
    $update = {
      param (
        [string]$path,
        [switch]$AutoUpdate,
        [switch]$DoNotRefresh
      )
                Remove-Item -Path "$PSScriptRoot\Citrix-Downloader.ps1" -Force
                Invoke-WebRequest -Uri "https://raw.githubusercontent.com/ravager-dk/Citrix-Downloader/main/Citrix-Downloader.ps1" -OutFile ("$PSScriptRoot\" + "Citrix-Downloader.ps1")
                & "$PSScriptRoot\Citrix-Downloader.ps1" -Path $Path -AutoUpdate:$AutoUpdate -DoNotRefresh:$DoNotRefresh
              }
              Invoke-Command -ScriptBlock $update -NoNewScope -ArgumentList $path,$AutoUpdate,$DoNotRefresh
    exit
  }
}



$creds = Get-Credential -Message "Citrix Credentials"
$CitrixUserName = $creds.UserName
$CitrixPW = $creds.GetNetworkCredential().Password

#Imports $CSV with download information
$downloads = $CSV | ConvertFrom-Csv -Delimiter ","

#Use CTRL to select multiple
$dls = $downloads | Out-ConsoleGridView -Title "Select Installer or ISO to download. CTRL to select multiple"

#Processes each download
foreach ($dl in $dls) {
  Write-Output "Downloading $($dl.filename)..."
  Get-CTXBinary -DLNUMBER $dl.dlnumber -DLEXE $dl.filename -CitrixUserName $CitrixUserName -CitrixPW $CitrixPW -DLPATH $path
}