Function ConvertTimestamp ($pumpTime, $timeStamp) {
    return ($timeStamp/1000) - ($pumpTime/1000)
}

Function TrimCoinName ($coinKey) {
    if($coinKey.IndexOf(" ") -gt 0) {return $coinKey.SubString(0, $coinKey.IndexOf(" "))}
    else {return $coinKey}
}

$coins = [ordered]@{}
(Get-Content "$PSScriptRoot/coindata.json" | ConvertFrom-Json).psobject.properties | %{$coins[$_.Name] = $_.Value}

foreach($x in $coins.Keys)
{
    if(Get-ChildItem "$($x).csv"){continue;}

    $unixTimestamp = ([System.DateTime]::Parse($coins[$x]) - [System.DateTime]::new(1970, 1, 1)).TotalMilliseconds;
    $tenMinsBefore = $unixTimestamp - (10*60*1000);
    $tenMinsAfter = $unixTimestamp + (10*60*1000);

    $data = curl "https://api.binance.com/api/v1/aggTrades?symbol=$(TrimCoinName $x)BTC&startTime=$tenMinsBefore&endTime=$tenMinsAfter"
    $json = $data.Content.Replace("""M""", """Mm""") | ConvertFrom-Json
    $json | Select-Object -Property ProcessName,{$_.StartTime.DayOfWeek}

    $timestampProperty = @{label="Time";expression={(ConvertTimestamp $unixTimestamp $_.T)}}
    $priceProperty = @{label="Price";expression={$_.p}}

    $json | Select $timestampProperty, $priceProperty | ConvertTo-Csv -NoTypeInformation | %{$_ -replace '"',''} | Out-File "$($x).csv" 
}