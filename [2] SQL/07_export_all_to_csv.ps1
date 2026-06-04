# Exports every table and view in MelbourneArterialNetwork to CSV (headers included).
# Run in PowerShell. Uses bcp + sqlcmd (already installed). Windows auth (-T / -E).

$server = "localhost\SQLEXPRESS"
$db     = "MelbourneArterialNetwork"
$out    = "C:\01_Data_Projects\1_Melbourne_Arterial_Network_Performance\1_Data\2_Processed"
$delim  = ","        # switch to "|" if any text value contains a comma (e.g. a site name)

New-Item -ItemType Directory -Force -Path $out | Out-Null

# Get every table + view in the three schemas, straight from the catalogue.
$listSql = "SET NOCOUNT ON; SELECT s.name+'.'+o.name FROM sys.objects o " +
           "JOIN sys.schemas s ON s.schema_id=o.schema_id " +
           "WHERE o.type IN ('U','V') AND s.name IN ('stg','dim','rpt') ORDER BY s.name,o.name;"
$objects = sqlcmd -S $server -d $db -E -h -1 -W -y 0 -Q $listSql |
           Where-Object { $_.Trim() -ne "" }

foreach ($obj in $objects) {
    $obj  = $obj.Trim()
    $file = $obj -replace '\.','_'
    $csv  = Join-Path $out "$file.csv"
    $tmp  = Join-Path $out "$file.tmp"
    $hdr  = Join-Path $out "$file.hdr"

    # Header line = the column names, in order.
    $hdrSql = "SET NOCOUNT ON; SELECT STRING_AGG(CAST(name AS NVARCHAR(MAX)), '$delim') " +
              "WITHIN GROUP (ORDER BY column_id) FROM sys.columns WHERE object_id = OBJECT_ID('$obj');"
    $cols = (sqlcmd -S $server -d $db -E -h -1 -W -y 0 -Q $hdrSql |
             Where-Object { $_.Trim() -ne "" } | Select-Object -First 1).Trim()
    $cols | Out-File -FilePath $hdr -Encoding ascii

    Write-Host "Exporting $obj ..."
    bcp "SELECT * FROM $obj" queryout $tmp -c -t"$delim" -S $server -d $db -T

    # Glue header + data into the final CSV (byte copy, safe for multi-GB files).
    cmd /c "copy /b `"$hdr`" + `"$tmp`" `"$csv`"" | Out-Null
    Remove-Item $tmp, $hdr -Force
}

Write-Host "Done. CSV files are in $out"
