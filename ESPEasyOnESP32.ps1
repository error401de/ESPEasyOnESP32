##################################################################
#Script Name:	ESPEasyOnESP32
#Description:	Installs and configures ESPEasy on a ESP32 device
#Author:		error401de / https://github.com/error401de
##################################################################

function writeToDevice($message, $command, $var, $com) {
	Write-Host $message
	Start-Sleep -Seconds 3
	$port.writeLine("$($command) " + $var)
}

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
			$port = new-Object System.IO.Ports.SerialPort "COM$($comInput)",115200,None,8,one
			$port.Open()
			writeToDevice -message "Setting SSID..." -command "WifiSSID" -var $wifiSSID -com $comInput
			writeToDevice -message "Setting password..." -command "WifiKey" -var $wifiPasswordPlain -com $comInput
			writeToDevice -message "Saving settings..." -command "Save"
			writeToDevice -message "Device will now be rebooted. All done." -command "Reboot"
			$port.close()
		} else {
			Write-Warning "An error occured. Check error.log for more information."
		}
	} else {
		Write-Warning "An error occured. Check error.log for more information."
		Break
	}
}