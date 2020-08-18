###
#
#   Parse NPS logs for yesterday, gets 6272 event (auth), groups and sends xml to email.
#   
#   had to fill in
#   $from=
#   $to=
#   $smtp=   
#
###

$day=1
$cur_date=(Get-Date -Date (Get-Date).Date)
$dt_s=((get-date -UFormat "%s") -split '\.')[0]

$from='from@local'
$to='to@local'
$smtp='smtp.local'

$filename=".\wifi_auth_$dt_s$dt_s.csv"


Get-EventLog -LogName Security -Message "*Network Policy Server*" -After $cur_date.AddDays(-$day) -Before $cur_date.AddDays((-$day+1)) | 
Where-Object {$_.EntryType -eq "SuccessAudit"} | Where-Object { $_.instanceId -eq 6272 } | ForEach-Object { ((($_.message -split '\r\n' | 
Select-String -Pattern 'Account Name') -split ':' )[1] -replace '\s','' -replace '.*\\','' -replace '@.','') } | group | select -Property count,Name | sort -Property count | Export-Csv -Path $filename -NoTypeInformation

 
Send-MailMessage -From $from -to $to -Subject 'wifi log auth' -Attachments $filename -SmtpServer $smtp
