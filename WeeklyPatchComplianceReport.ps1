
<#
.Synopsis
   This script will Import csv files into excel, create pivot table, calculate the compliance percentage.
.DESCRIPTION
   This script is used to import csv files into excel, create pivot table, calcute the compliance percentage.
#>

# Weekly ComplianceReport Clients

cd C:\temp\ComplianceReport

import-Csv "All Clients - Region NA.csv" | Export-Excel "Weekly ComplianceReport Clients.xlsx" -WorksheetName "All Clients - Region NA" -AutoSize
import-Csv "NonCompliant Clients - Region NA.csv" | Export-Excel "Weekly ComplianceReport Clients.xlsx" -WorksheetName "NonCompliant Clients -Region NA" `
-AutoSize

$data = Import-Excel "Weekly ComplianceReport Clients.xlsx" -WorksheetName "NonCompliant Clients -Region NA" -StartColumn 4 -EndColumn 4 
$data."Ip Address" | select -Unique | Export-Excel "Weekly ComplianceReport Clients.xlsx" -WorksheetName "NonCompliant Clients -Region NA" -StartColumn 13 -AutoSize -TitleSize 11 `
-Title "Unique IP Address"

$newdata = Open-ExcelPackage "Weekly ComplianceReport Clients.xlsx"
$nullvar = Add-WorkSheet -ExcelPackage $newdata -WorksheetName "Compliance Percentage clients"

$ws = $newdata.Workbook.Worksheets["Compliance Percentage clients"]
$cell1 = $ws.Cells["A1"]
$cell1.Value = "All Clients - Region NA"
$cell1.Style.Font.Bold = "true"
$cell2 = $ws.Cells["A2"]
$cell2.Value = "NonCompliant Clients -Region NA"
$cell2.Style.Font.Bold = "true"
$cell3 = $ws.Cells["A3"]
$cell3.Value = "Compliance Percentage clients"
$cell3.Style.Font.Bold = "true"

$newdata.Workbook.Worksheets["Compliance Percentage clients"].Cells[1,2].Formula ="COUNTA('All Clients - Region NA'!A:A)"
$newdata.Workbook.Worksheets["Compliance Percentage clients"].Cells[1,2].Style.Font.Bold = "true"                                                                                  
$newdata.Workbook.Worksheets["Compliance Percentage clients"].Cells[2,2].Formula="COUNTA('NonCompliant Clients -Region NA'!M:M)"
$newdata.Workbook.Worksheets["Compliance Percentage clients"].Cells[2,2].Style.Font.Bold = "true"
$newdata.Workbook.Worksheets["Compliance Percentage clients"].Cells[3,2].Formula='1-(B2/B1)'
$newdata.Workbook.Worksheets["Compliance Percentage clients"].Cells[3,2].Style.Font.Bold = "true"

Add-PivotTable -PivotTableName "Compliance Percentage clients" -address $newdata."Compliance Percentage clients".Cells["A5"] -SourceWorkSheet $newdata."NonCompliant Clients -Region NA" `
-PivotRows 'Plugin Name' -PivotData 'Plugin Name'

Close-ExcelPackage $newdata