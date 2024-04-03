# Specify the network printer details
$printerName = "\\DC1WPCUTAPP1P\Accounting Check Printer"
$driverName = "C:\Windows\system32\NtPrint.exe"
# $portName = "IP_192.168.1.100"  # Replace with the actual IP address or port name

# Install the network printer
Add-Printer -Name $printerName -DriverName $driverName 
# those -PortName $portName
