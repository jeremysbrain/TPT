# Check for -verbose switch
if ($MyInvocation.Line -match '-Verbose') {
    $VerbosePreference = 'Continue'
}
    
# Get public and private function definition files.
$Public = @( Get-ChildItem -Path $PSScriptRoot\Public\*.ps1 -ErrorAction SilentlyContinue )
$Private = @( Get-ChildItem -Path $PSScriptRoot\Private\*.ps1 -ErrorAction SilentlyContinue )
    
# Dot source the files
foreach ($import in @($Public + $Private)) {
    Try {
        Write-Verbose "Importing $($import.fullname)"
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}
    
# Export the Public modules
Export-ModuleMember -Function $Public.Basename