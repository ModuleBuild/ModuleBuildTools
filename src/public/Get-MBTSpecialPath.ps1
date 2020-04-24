Function Get-MBTSpecialPath {
    <#
    .SYNOPSIS
        Get SpecialFolder defined in Environment variables
    .DESCRIPTION
        Get SpecialFolder defined in Environment variables
    .EXAMPLE
        Get-MBTSpecialPath
    #>
    Param (

    )
    $SpecialFolders = @{}
    $names = [Environment+SpecialFolder]::GetNames([Environment+SpecialFolder])
    ForEach ($name in $names) {
        $SpecialFolders[$name] = [Environment]::GetFolderPath($name)
    }
    $SpecialFolders
}