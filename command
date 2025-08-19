Set-ExecutionPolicy -ExecutionPolicy Remotesigned -Scope CurrentUser -Force
repair - Execute-MSI -Action Repair -ProductCode "{12345678-ABCD-1234-ABCD-1234567890AB}"
product code access command - Get-WmiObject Win32_Product | Where-Object { $_.Name -like "*Visual Studio Code*" } | Select-Object Name, IdentifyingNumber
