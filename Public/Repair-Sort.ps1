function Repair-Sort {

    <#
    .SYNOPSIS
        Sorts objects when numbers are stored in strings without leading zeros
    .EXAMPLE
        PS C:\> @('File1.txt', 'File2.txt', 'File10.txt', 'File5.txt') | Repair-Sort
        Output of standard Sort-Object would be File1.txt, File10.txt, File2.txt, File5.txt
        Repaired sort output is File1.txt, File2.txt, File5.txt, File10.txt
    .EXAMPLE
        PS C:\> Repair-Sort @('File1.txt', 'File2.txt', 'File10.txt', 'File5.txt')
        Output of standard Sort-Object would be File1.txt, File10.txt, File2.txt, File5.txt
        Repaired sort output is File1.txt, File2.txt, File5.txt, File10.txt
    #>

    [CmdletBinding()]
    param (
        # Input object to ensure is sorted numericaly (ie. 2 before 10)
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
        $InputObject
    )
    begin {
        $ObjectList = @( )
    }

    process {
        $ObjectList += $InputObject
    }

    end {
        $ParamSort = @{
            InputObject = $ObjectList
            Property    = { [int]( $_ -replace '\D','') }
        }

        Sort-Object @ParamSort
    }
}