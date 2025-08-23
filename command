Set-ExecutionPolicy -ExecutionPolicy Remotesigned -Scope CurrentUser -Force
repair - Execute-MSI -Action Repair -ProductCode "{12345678-ABCD-1234-ABCD-1234567890AB}"
product code access command - Get-WmiObject Win32_Product | Where-Object { $_.Name -like "*Visual Studio Code*" } | Select-Object Name, IdentifyingNumber
 Set-ExecutionPolicy -ExecutionPolicy Bypass -Scope Process -Force; .\Invoke-AppDeployToolkit.ps1 -DeploymentType Install -DeployMode Interactive


Step 1 — Get PSADT

1. Download the PowerShell App Deployment Toolkit (PSADT) from GitHub (zip).


2. Extract it somewhere (e.g., C:\Packages\MyApp).

Inside, you’ll see Deploy-Application.ps1, Toolkit, Files, AppDeployToolkitConfig.xml, etc.





---

🔹 Step 2 — Prepare folders

Inside your PSADT package folder (C:\Packages\MyApp):

Put the app installer in:
.\Files

Create a folder for Active Setup script:
.\Files\ActiveSetup


So you now have:

C:\Packages\MyApp\
   Deploy-Application.ps1
   Files\
      ActiveSetup\
         Run-PerUser.ps1   <-- this you will create


---

🔹 Step 3 — Create per-user script

Open Notepad/VS Code → paste your per-user setup code → save as:
.\Files\ActiveSetup\Run-PerUser.ps1

Example:

# Run-PerUser.ps1
New-Item -Path 'HKCU:\Software\MyApp' -Force | Out-Null
New-ItemProperty -Path 'HKCU:\Software\MyApp' -Name 'FirstRun' -Value 1 -PropertyType DWord -Force | Out-Null


---

🔹 Step 4 — Edit Deploy-Application.ps1 (Install section)

1. Open Deploy-Application.ps1 in an editor.


2. Scroll down to:

##*===============================================
##* INSTALLATION
##*===============================================


3. Insert this block:



# --- Active Setup configuration ---
$AsId        = 'MyApp_AS'
$AsVersion   = '1,0,0,0'
$AsBasePath  = 'C:\ProgramData\MyApp\ActiveSetup'
$AsScript    = Join-Path $AsBasePath 'Run-PerUser.ps1'

# 1) Copy per-user script to ProgramData
New-Item -ItemType Directory -Path $AsBasePath -Force | Out-Null
Copy-File -Path (Join-Path $dirFiles 'ActiveSetup\Run-PerUser.ps1') -Destination $AsScript -Force

# 2) Register Active Setup keys
$stubPath = '%SystemRoot%\System32\WindowsPowerShell\v1.0\powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%ProgramData%\MyApp\ActiveSetup\Run-PerUser.ps1"'
$asKey    = "HKLM:\Software\Microsoft\Active Setup\Installed Components\$AsId"
$asKeyWow = "HKLM:\Software\WOW6432Node\Microsoft\Active Setup\Installed Components\$AsId"

Set-RegistryKey -Key $asKey -Name 'StubPath' -Value $stubPath -Type String
Set-RegistryKey -Key $asKey -Name 'Version' -Value $AsVersion -Type String
Set-RegistryKey -Key $asKey -Name 'IsInstalled' -Value 1 -Type DWord
Set-RegistryKey -Key $asKey -Name 'DisplayName' -Value 'MyApp Active Setup' -Type String

Set-RegistryKey -Key $asKeyWow -Name 'StubPath' -Value $stubPath -Type String
Set-RegistryKey -Key $asKeyWow -Name 'Version' -Value $AsVersion -Type String
Set-RegistryKey -Key $asKeyWow -Name 'IsInstalled' -Value 1 -Type DWord
Set-RegistryKey -Key $asKeyWow -Name 'DisplayName' -Value 'MyApp Active Setup' -Type String

# 3) Run per-user script immediately for current user
$loggedOnUserSession = Get-LoggedOnUser
if ($loggedOnUserSession -and (Test-Path $AsScript)) {
    Execute-ProcessAsUser -Path 'powershell.exe' -Parameters "-NoProfile -ExecutionPolicy Bypass -File "$AsScript""
}


---

🔹 Step 5 — Edit Deploy-Application.ps1 (Uninstall section)

Scroll to:

##*===============================================
##* UNINSTALLATION
##*===============================================

Insert:

# --- Remove Active Setup ---
$AsId = 'MyApp_AS'
Remove-RegistryKey -Key "HKLM:\Software\Microsoft\Active Setup\Installed Components\$AsId" -Recurse -ErrorAction SilentlyContinue
Remove-RegistryKey -Key "HKLM:\Software\WOW6432Node\Microsoft\Active Setup\Installed Components\$AsId" -Recurse -ErrorAction SilentlyContinue
Remove-Folder -Path 'C:\ProgramData\MyApp\ActiveSetup' -ContinueOnError $true
🔹 Step 6 — Test it

1. Run Deploy-Application.exe Install as admin → package installs + Active Setup is registered.


2. Sign in with a new test user → Windows runs your Run-PerUser.ps1.


3. Verify:

Check registry HKCU\Software\MyApp

Look at HKLM\Software\Microsoft\Active Setup\Installed Components\MyApp_AS

🔹 Step 7 — Upgrade scenario

Open Deploy-Application.ps1

Change:

$AsVersion = '1,0,1,0'

Redeploy package → next logon, all users get script again.
