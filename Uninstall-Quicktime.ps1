#------------------------------------------------------------
# Name:QuickTime-Uninstall.ps1
# This script will uninstall the Product based on ARP name.
#------------------------------------------------------------
$LogFile = "$env:HOMEDRIVE\WBG\Logs\Uninstall-QuickTime.log"

Function Uninstall-QuickTime
{ 
 "--------------------------------------------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append
" QuickTime Uninstall Script Started at" + (Get-Date).DateTime | Out-File -FilePath $LogFile -Append
"---------------------------------------------------------------------------------------------------------------------" | Out-File -FilePath $LogFile -Append


If (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] “Administrator”))
{
"Error : you don't have Admin privileges to uninstall this Product"| Out-File -FilePath $LogFile -Append 
}

else
{

# Reboot suppresion - comment out if not needed

$SupReb = "REMOVE=ALL REBOOT=ReallySuppress"

$flag32 = 0

$flag64 =0

#-----------------
$pinfo = New-Object System.Diagnostics.ProcessStartInfo
    $p = New-Object System.Diagnostics.Process
#-----------------------------------------

$apps32 = Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall| Get-ItemProperty | Where-Object {$_.DisplayName -like '*QuickTime*' } 


$apps64 = Get-ChildItem -Path HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | Get-ItemProperty | Where-Object {$_.DisplayName -like '*QuickTime*' } 



if (![string]::IsNullOrEmpty($apps32)) 

{ 

$Apps = $apps32 

$flag32 =1 


} 

if (![string]::IsNullOrEmpty($apps64))
{ 

$Apps = $apps64

$flag64 =1

}

if( ($flag32 -eq 1) -or ($flag64 -eq 1))

{


$output = $Apps.UninstallString

$final = $output -replace "MSIEXEC.EXE" -replace "" -replace "/I" -replace "" -replace "/X" -replace ""

$GUID = $final.Trim() 

$ArgList = "/x $GUID $supreb /QN " 

     $pinfo.FileName = "msiexec.exe"
     $pinfo.RedirectStandardError = $true
     $pinfo.RedirectStandardOutput = $true
     $pinfo.UseShellExecute = $false
     $pinfo.Arguments = $ArgList

     

     If($GUID.Length -ne 0)
{ 

"performing Msiexec.exe $ArgList on $env:computername" | Out-File -FilePath $LogFile -Append
#Start-Process MSIExec $ArgList -Wait
     $p.StartInfo = $pinfo
     $p.Start() | Out-Null
     $p.WaitForExit()
     if(($p.ExitCode -eq 0) -or ($p.ExitCode -eq 3010) -or ($p.ExitCode -eq 1605))
     {
      "Success::" + $p.ExitCode | Out-File -FilePath $LogFile -Append
     }
     else
     {
     "Failed::" + $p.ExitCode | Out-File -FilePath $LogFile -Append
     }
}
}
else
{
    "Product Not Found" | Out-File -FilePath $LogFile -Append
}
}
}

Uninstall-QuickTime
