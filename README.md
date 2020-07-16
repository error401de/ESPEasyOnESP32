# ESPEasyOnESP32
ESPEasyOnESP32 is a PowerShell script for initialization of ESPEasy on ESP32 devices. It flashes ESPEasy and configures the required wifi settings.
It's based on the [highly experimental installation routine](https://www.letscontrolit.com/wiki/index.php/ESPEasy32) by LetsControlIt plus configuration via a serial connection.

## Usage
- Download via 'Code' -> 'Download ZIP'
- Extract archive
- Run PowerShell as admin
- Change into the directory (e.g. 'cd C:\temp\ESPEasyOnESP32-master')
- Connect your ESP32 module via USB
- Run '.\ESPEasyOnESP32.ps1' and follow the instructions

## Configuration
- The script comes with firmware version R20100. If you want to use another version, replace the release.bin file with your version of choice. [Find releases](https://github.com/letscontrolit/ESPEasy/releases)

## Restrictions
This minimalistic script has been tested on a ESP32-WROM-32 by "EspressIf" only.

## Dependencies
The script comes with [ESPEasy](https://github.com/letscontrolit/ESPEasy) and [esptool](https://github.com/espressif/esptool) and is therefore licensed under GNU  GPL v3.
