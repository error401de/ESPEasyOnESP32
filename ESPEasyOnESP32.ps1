##################################################################
#Script Name:	ESPEasyOnESP32
#Description:	Installs and configures ESPEasy on a ESP32 device
#Author:		error401de / https://github.com/error401de
##################################################################

Write-Host "Checking permissions..."
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
	Write-Warning "Please run this script as Administrator."
	Break
}
else {
	Write-Host "Scanning COM ports..."
	$comPorts = (Get-WmiObject -query "SELECT * FROM Win32_PnPEntity" | Where {$_.Name -Match "COM\d+"}).name
	
	if ($comPorts.Count -lt 1) {
		Write-Warning "No COM device found. Please plug in the device and restart this script."
		Break
	}
	elseIf ($comPorts.Count -eq 1) {
		Write-Host $comPorts
	} else {
		for ($i = 0; $i -lt $comPorts.Count; $i++) {
			Write-Host $comPorts[$i]
		}
	}
	$comInput = Read-Host "Enter the COM number of the device you want to flash (only the number, no 'COM')"
	$wifiSSID = Read-Host "Enter the SSID you want to connect"
	$wifiPassword = Read-Host "Enter the Wifi Password" -AsSecureString
	$wifiPasswordPlain = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto([System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($wifiPassword))
	Write-Host "Wiping the device..."
	$wipe = start-process .\esptool.exe -ArgumentList "--chip esp32 --port COM$($comInput) erase_flash" -PassThru -Wait -RedirectStandardError "error.log"
	
	if ( $wipe.ExitCode -eq 0 ) {
		Write-Host "Flashing the device..."
		$flash = start-process .\esptool.exe -ArgumentList "--chip esp32 --port COM$($comInput) --baud 256000 --before default_reset --after hard_reset write_flash -z --flash_mode dio --flash_freq 80m --flash_size detect 0xe000 boot_app0.bin 0x1000 bootloader.bin 0x10000 release.bin 0x8000 ESPEasy.ino.partitions.bin" -PassThru -Wait -RedirectStandardError "error.log"
		if ( $flash.ExitCode -eq 0 ) {
			Write-Host "Waiting 30 seconds..."
			Start-Sleep -Seconds 30
			Write-Host "Set SSID..."
			$port = new-Object System.IO.Ports.SerialPort "COM$($comInput)",115200,None,8,one
			$port.Open()
			Start-Sleep -Seconds 5
			$port.writeLine("WifiSSID " + $wifiSSID)
			Start-Sleep -Seconds 3
			$port.readLine()
			Write-Host "Set password..."
			$port.WriteLine("WifiKey " + $wifiPasswordPlain)
			Start-Sleep -Seconds 3
			Write-Host "Save settings..."
			$port.WriteLine("Save")
			Start-Sleep -Seconds 3
			$port.readLine()
			Write-Host "Device will now be rebooted. All done."
			$port.WriteLine("Reboot")
			$port.close()
		} else {
			Write-Warning "An error occured. Check error.log for more information."
		}
	} else {
		Write-Warning "An error occured. Check error.log for more information."
		Break
	}
}