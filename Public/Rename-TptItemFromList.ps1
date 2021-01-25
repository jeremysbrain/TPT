function Rename-TptItemFromList {

    <#
    .SYNOPSIS
        Renames files to supplied list.
    .DESCRIPTION
        Renames files specified in $Path to names supplied in $Names.
        By default extensions are preserved from $Path
        $Path defaults to the current folder
        Creates a .csv log of renames.  The csv log is named .rename[DATE].csv (DATE is represented in the yyyyMMdd_HHmmss format)
    .EXAMPLE
        Rename-TptItemFromList -Names @('One','Two','Three','Four') -Path (Get-ChildItem -Filter *.mp3)
    #>

    [CmdletBinding(SupportsShouldProcess = $true)]
    param (
        # Files to rename
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string[]]$Path,

        # List (array) of names to rename to
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [String[]]
        $Names,

        # Forces rename even if source name exists
        [Parameter()]
        [switch]$Force,
        
        # Ignores count mismatch between names and files
        # SUGGESTION - Use -WhatIf to preview rename FIRST
        [Parameter()]
        [switch]$IgnoreCountMismatch,

        # Fixes sorting filenames as strings when numbers are involved.
        # Defaulted to True (on) use -FixSorting $false to disable
        [Parameter()]
        [switch]
        $FixSorting = $true,

        # Prefix - Add this text at the beginning of the every filename
        [Parameter()]
        [string]
        $Prefix,

        # Suffix - Add this text at the end of every filename (not after the extension)
        [Parameter()]
        [string]
        $Suffix
    )
    
    begin {
        # Verify there is a name for each file
        $NumFiles = $Path | Measure-Object | Select-Object -ExpandProperty Count
        $NumNames = $Names | Measure-Object | Select-Object -ExpandProperty Count
        Write-Verbose -Message "Number of files: $NumFiles"
        Write-Verbose -Message "Number of names: $NumNames"

        if (($NumFiles -ne $NumNames) -and (-not $IgnoreCountMismatch)) {
            if ($PSCmdlet.ShouldProcess("Target", "Operation")) { #Not using -whatif
                Throw 'Number of files does not match the number of names. Use -IgnoreCountMismatch parameter to continue.  Preview results with -WhatIf.'                
            }
        }

        if ($FixSorting) {
            # Fix file sorting when numbers are represented as strings. '\D' represents non-digit characters
            # ONLY WORKS WHEN PASSING FILES AS PARAMETER NOT THROUGH PIPELINE
            Write-Verbose -Message "Fixing sorting"
            $Path = $Path | Sort-Object -Property {( (Get-Item $_).BaseName -replace '\D','' ) -as [int]}
        }

        [int]$Index = 0
        [PSCustomObject]$Result = @( )
    }
    
    process {
        foreach ($File in $Path) {
            $File = Get-Item $File
            $NewName = $Prefix + $Names[$Index] + $Suffix + $File.Extension

            if ($PSCmdlet.ShouldProcess("Target", "Operation")) { #Not using -whatif
                try {
                    Rename-Item -Path $File -NewName $NewName -Force:$Force
                    Write-Verbose -Message "Renaming $File to $NewName"
                }
                catch {
                    Write-Warning -Message "Error renaming $File to $NewName"
                    $Errors ++
                }
                $Result += [PSCustomObject]@{
                    Directory = $File.Directory
                    Original = $File.Name
                    New = $NewName
                }
            }

            else { #Using -whatif
                Write-Output "Will attempt to rename the file $File to $NewName"
            }
            
            $Index ++
        }
    }
    
    end {
        Write-Verbose -Message "Processed $Index Files. Encountered $Errors Errors"

        if ($PSCmdlet.ShouldProcess("Target", "Operation")) { #Not using -whatif
            $Date = Get-Date -Format 'yyyyMMdd_HHmmss'
            $Result | Export-Csv -Path ".rename$Date.csv" -NoTypeInformation
        }
        else { #Using -whatif
            Write-Output "Will Attempt to rename $Index files using $NumNames names"
        }

        if ( $Index -ne $NumNames ) {
            Write-Warning -Message 'Number of names provided does not match the number of files.'
        }
    }
}