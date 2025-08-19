## Import PSADT Module
. "$PSScriptRoot\AppDeployToolkit\AppDeployToolkitMain.ps1"

## Example: Install MSI
Execute-MSI -Action Install -Path "MyApp.msi"

## Example: Uninstall MSI
# Execute-MSI -Action Uninstall -Path "{PRODUCT-CODE-GUID}"
