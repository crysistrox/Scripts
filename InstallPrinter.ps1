# Specify the network printer details
$printerName = "\\DC1WPCUTAPP1P\Accounting Check Printer"
$driverName = "C:\Windows\system32\NtPrint.exe"
$portName = "10.12.6.210"  # Replace with the actual IP address or port name

# Install the network printer
Add-Printer -Name $printerName -DriverName $driverName -PortName $portName
