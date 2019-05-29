<#
.Synopsis
   This script will get details of perticular patch installed on remote computer.
.DESCRIPTION
   This script will get details of perticular patch installed on remote computer, in this case I am trying to get recent emergency patch installed on remote computer.
.EXAMPLE
   get-content "C:\temp\Hareesh\Script\Computers.txt" | get-installedpatch
.EXAMPLE
   get-installedpatch -computers computer1,computer2
.INPUTS
   computername
.FUNCTIONALITY
   This cmdlet is useful to check the recent emergency patch (KB4499175 or KB4499180) is installed on remote computer or not.
#>

function get-installedpatch
{
[cmdletbinding()]
param
(
[Parameter(
Mandatory=$true,
ValueFromPipeline=$true
)]
[string[]]$computers
)
Begin
{
    $Results = @()
}
    
    Process
    {
        foreach ($computer in $computers)
        {
            if (Test-Connection -ComputerName $computer -Count 1 -ea SilentlyContinue)
            {
                try
                {
                    $hotfix = get-wmiobject win32_quickfixengineering -ComputerName $computer | where {$_.hotfixid -eq "KB4499175" -or $_.hotfixid -eq "KB4499180"} -ErrorAction stop
                    if ($hotfix.HotfixId -eq 'KB4499175'-or $hotfix.HotfixId -eq 'KB4499180')
                    {
                    $results += [pscustomobject] @{
                    ComputerName = $computer
                    HotfixId = $hotfix.HotfixID
                    Installdate = $hotfix.Installedon
                    }
                    }
                    else
                    {
                    $results += [pscustomobject] @{
                    ComputerName = $computer
                    }
                    }
                }
                catch
                {
                Write-output "$computer is giving exception"
                $Computer | out-file 'C:\temp\Hareesh\Script\KB4499175_ExceptionComputers.txt' -Append
                }
            }
            else
            {
            Write-output "$computer is not online" | Out-File "C:\temp\Hareesh\Script\KB4499175_Notonline.txt"
            }
        $Results | export-csv "C:\temp\Hareesh\Script\KB4499175_Installed.csv" -NoTypeInformation
        }
     }
end {}
}
get-content "C:\temp\Hareesh\Script\Computers.txt" | get-installedpatch