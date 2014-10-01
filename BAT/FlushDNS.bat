::Add this script to your Windows Task Scheduler (this is setup for Server 2008 r2)
ping 8.8.8.8 -n 1 | find "Reply"
IF ERRORLEVEL 1 GOTO FIX
EXIT
:FIX
@echo Off
Net Stop DNS
Net Stop Dnscache
Net Start DNS
Net Start Dnscache
ipconfig /flushdns
ipconfig /registerdns
EXIT
