#TESTING ARGS MANUALLY
#$EmailTo = 'James.DiBernardo@molinahealthcare.com'
#$rptUser = 'MMC\DiBernaj'
#$IHA_Assignments = 'RO'
#$DIAB_YN = '0'
#$REDs = 'ALL'
#$Risk_Priority = 'Medium'
#$Plan_State = 'CA'
#$LOB = 'Marketplace'
#$Target_Type = 'ACE'
#$Target_Provider = 'SP: Onboarding'
#$Outreach_Status = 'In Progress'
#$Phone_Type = 'Cell_Phone'
#$Campaign_type = 'EN'


###################################
#Build the CSV from the TEMP Table#
###################################

#Configuration Variables for CSV
$SQLServer = "DC01CIDBPV01"
$db = "MMM_CI"
$query = "SET NOCOUNT ON; SELECT [COL] FROM TEMP.AUTO_DAILER_EMAIL_ATTACHMENT_GENESYS_TELEHEALTH Order by ROWNUM, [Priority], [ZipCode], [TargetProv], [TargetType/s Priority]"
$User = $env:USERNAME
$domain = $env:USERDOMAIN
$time = $(get-date -f MMddyyyy_hhmmss)
$CSV = "\\Molina-Azure-NAS.molina.mhc\EpicCINAS\External File Share\Genesys\STG\Auto_Dialer_Extract_Genesys_Telehealth_$time.csv"

#Build CSV to CI Nas

Invoke-Sqlcmd -Database $db -HostName $SQLServer -ServerInstance $SQLServer -Query $query |
#send the result set to a CSV format
ConvertTo-Csv -Delimiter "," -NoTypeInformation |
#skip 1 removes the [COL] header
Select-Object -Skip 1 | 
#Replacing all Quoted text with nothing
% {$_ -replace '"', ""} | 
#ASCII seams to be right... 
Out-File ($CSV) -Force -Encoding ascii

###################################
#Stage the Summary Table          #
###################################
$SQLServer = "DC01CIDBPV01"
$db = "MMM_CI"
$querySummary = "
DECLARE @SUMMARY_TABLE NVARCHAR(MAX) = 
		CAST(( 
		SELECT 
		 [td] = [State],''
		,[td] = [TargetType],''
		,[td] = COUNT(CONCAT(LTRIM(RTRIM([LASTNAME])),',',LTRIM(RTRIM([FIRSTNAME]))))
		FROM TEMP.AUTO_DAILER_GENESYS_TELEHEALTH_EMAIL_SUMMARY
		GROUP BY [State], [TargetType]
		ORDER BY [State], [TargetType]
		FOR XML PATH('tr'), ELEMENTS ) AS NVARCHAR(MAX));
Select @SUMMARY_TABLE;"

$Summary = Invoke-Sqlcmd -Database $db -HostName $SQLServer -ServerInstance $SQLServer -Query $querySummary |
#send the result set to a CSV format
ConvertTo-Csv -Delimiter "," -NoTypeInformation |
#skip 1 removes the [COL] header
Select-Object -Skip 1 |
#Replacing all Quoted text with nothing
% {$_ -replace '"', ""}  

#test the output
#$Summary

################################################
#Next, lets just send the email from powershell#
################################################

#Configuration Variables for E-mail
$SmtpServer = "MHCORPMAIL.molina.mhc"
$SMTPPort = "25"
$EmailFrom = "CI_AUTOMATION@Molinahealthcare.com"
$EmailTo = $args[0]
$EmailCC = "CI_Reporting@Molinahealthcare.com"
$EmailSubject = "Auto Dialer Report for Genesys - Telehealth"
$EMailAttachemnt = $CSV
#$EMailAttachemnt = "\\Molina-Azure-NAS.molina.mhc\EpicCINAS\External File Share\Genesys\STG\Auto_Dialer_Extract_Genesys_Telehealth_02242022_021547.csv"

#Grab all Report variables that were passed in the command line (must be in order)
$rptUser = $args[1]
$IHA_Assignments = $args[2]
$DIAB_YN = $args[3]
$REDs = $args[4]
$Risk_Priority = $args[5]
$Plan_State = $args[6]
$LOB = $args[7]
$Target_Type = $args[8]
$Target_Provider = $args[9]
$Outreach_Status = $args[10]
$Phone_Type = $args[11]
$Campaign_type = $args[12]

$EmailBody = @"
Please find your latest report attached for the Auto Dialer Campaign for Genesys - Telehealth Only<br/>
<br/>
This report used the following Parameters: <br/>
<font color="red"> User Ran Report: </font> $rptUser <br/>   
<font color="red"> IHA Assignments: </font> $IHA_Assignments <br/>
<font color="red"> Diabetics: </font> $DIAB_YN <br/>
<font color="red"> RED Days: </font> $REDs <br/>
<font color="red"> Risk Priority(s): </font> $Risk_Priority <br/>
<font color="red"> Plan State: </font> $Plan_State <br/>
<font color="red"> LOB(s): </font> $LOB <br/>
<font color="red"> Target Type(s): </font> $Target_Type <br/>
<font color="red"> Target Provider(s): </font> $Target_Provider <br/>
<font color="red"> Outreach Status(s): </font> $Outreach_Status <br/>
<font color="red"> Phone Type: </font> $Phone_Type <br/>
<font color="red"> Campaign Type: </font> $Campaign_type <br/>
<br/>
<html>
    <head>
        <style>
            table, th, td {
                           padding:5px;
                           font-family:Verdana;
                           font-size:9pt;
                           border-collapse: collapse;
                           border: 1px solid #808080;
                           } 

        </style>
    </head>
<body>
    <table border = 1> 
        <tr bgcolor=#4b6c9e>
            <th><font color=White>State</font></th>
            <th><font color=White>Target Type</font></th>
			<th><font color=White>Record Count</font></th>
        </tr>
            $Summary
    </table>
</body>
</html>
"@

#Send E-mail from PowerShell script
Send-MailMessage -SmtpServer $SmtpServer -Port $SMTPPort -From $EmailFrom -To $EmailTo -Cc $EmailCC -Subject $EmailSubject -BodyAsHTML -Body $EmailBody -Attachments $EMailAttachemnt
#no longer need the staged CSV on the NAS
Remove-Item -Path $CSV
