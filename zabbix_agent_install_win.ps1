# Begin of script

# Variables
param($bucket)
# Go to de directory zabbix
cd C:\
mkdir zabbix
cd zabbix

# Download Zabbix Agent 3.4, Unzip and move files
wget "https://www.zabbix.com/downloads/3.4.6/zabbix_agents_3.4.6.win.zip" -outfile "zabbix_agents_3.4.6.win.zip"
unzip zabbix_agents_3.4.6.win.zip
# Download of .conf at a bucket or another repository
wget "https://s3.amazonaws.com/$bucket/zabbix_agentd.win.conf" -outfile "zabbix_agentd.win.conf"

# Move files
cd C:\zabbix\bin\win64
mv zabbix_* C:\zabbix
cd ..\..\

# Check if Zabbix Agent is installed and running, if not start the service.
If (get-service -Name "Zabbix Agent" -ErrorAction SilentlyContinue | Where-Object -Property Status -eq "Running")
{
    Exit
}
Elseif (get-service -Name "Zabbix Agent" -ErrorAction SilentlyContinue | Where-Object -Property Status -eq "Stopped") 
{
    # Starts service if it exists in a Stopped state.
    Start-Service "Zabbix Agent"
    Exit    
}

# Copy Zabbix Agent folder, Create new service, then start service.
New-Service -Name "Zabbix Agent" -BinaryPathName "C:\zabbix\zabbix_agentd.exe --config C:\zabbix\zabbix_agentd.win.conf" -DisplayName "Zabbix Agent" -Description "Provides system monitoring" -StartupType "Automatic" -ErrorAction SilentlyContinue
(Get-WmiObject win32_service -Filter "name='Zabbix Agent'").StartService()

rmdir .\conf -r
rmdir .\bin -r
del zabbix_agents_*

# End of Script !!!!