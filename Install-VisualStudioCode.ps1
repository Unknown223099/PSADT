# Install-VisualStudioCode.ps1

# Path to the MSI installer
$msiPath = "C:\Users\win10\Desktop\MyAppDeployment\Visual Studio Code.msi"

# Check if the file exists
if (-Not (Test-Path -Path $msiPath)) {
    Write-Host "MSI file not found at: $msiPath"
    exit 1
}

# Install silently
Write-Host "Installing Visual Studio Code..."
Start-Process "msiexec.exe" -ArgumentList "/i `"$msiPath`" /qn /norestart" -Wait -NoNewWindow

# Optional verification
$installed = Get-WmiObject Win32_Product | Where-Object { $_.Name -like "Visual Studio Code*" }
if ($installed) {
    Write-Host "Visual Studio Code installed successfully."
} else {
    Write-Host "Installation may have failed."
}
