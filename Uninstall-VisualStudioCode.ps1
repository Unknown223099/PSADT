# Search for Visual Studio Code installation via MSI
$vsCode = Get-WmiObject Win32_Product | Where-Object { $_.Name -like "Visual Studio Code*" }

if ($vsCode) {
    Write-Host "Uninstalling Visual Studio Code..."
    
    # Run the uninstall method
    $vsCode.Uninstall()
    
    # Optional confirmation
    Start-Sleep -Seconds 5
    $stillInstalled = Get-WmiObject Win32_Product | Where-Object { $_.Name -like "Visual Studio Code*" }

    if (-not $stillInstalled) {
        Write-Host "Visual Studio Code was uninstalled successfully."
    } else {
        Write-Host "Uninstallation may have failed."
    }
} else {
    Write-Host "Visual Studio Code is not installed via MSI."
}
