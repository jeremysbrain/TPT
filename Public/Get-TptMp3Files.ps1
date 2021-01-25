function Get-TptMp3Files {
    <#
    .SYNOPSIS
    Returns the .mp3 files in the current directory and fixes the sorting when numbers and text are mixed.

    .DESCRIPTION
    Made to be used with Rename-ItemFromList (Example below).

    .EXAMPLE
    Get-MP3Files

    .EXAMPLE
    Get-MP3Files | Rename-ItemFromList -Names @('One','Two','Three')

    #>
 
    Get-ChildItem -Filter '*.mp3' | Sort-Object -Property {( $_.BaseName -replace '\D','') -as [int]}

}