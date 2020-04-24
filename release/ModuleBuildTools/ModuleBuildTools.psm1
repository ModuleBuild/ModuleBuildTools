## Pre-Loaded Module code ##

<#
 Put all code that must be run prior to function dot sourcing here.

 This is a good place for module variables as well. The only rule is that no 
 variable should rely upon any of the functions in your module as they 
 will not have been loaded yet. Also, this file cannot be completely
 empty. Even leaving this comment is good enough.
#>

## PRIVATE MODULE FUNCTIONS AND DATA ##

function Get-CallerPreference {
    <#
    .Synopsis
       Fetches "Preference" variable values from the caller's scope.
    .DESCRIPTION
       Script module functions do not automatically inherit their caller's variables, but they can be
       obtained through the $PSCmdlet variable in Advanced Functions.  This function is a helper function
       for any script module Advanced Function; by passing in the values of $ExecutionContext.SessionState
       and $PSCmdlet, Get-CallerPreference will set the caller's preference variables locally.
    .PARAMETER Cmdlet
       The $PSCmdlet object from a script module Advanced Function.
    .PARAMETER SessionState
       The $ExecutionContext.SessionState object from a script module Advanced Function.  This is how the
       Get-CallerPreference function sets variables in its callers' scope, even if that caller is in a different
       script module.
    .PARAMETER Name
       Optional array of parameter names to retrieve from the caller's scope.  Default is to retrieve all
       Preference variables as defined in the about_Preference_Variables help file (as of PowerShell 4.0)
       This parameter may also specify names of variables that are not in the about_Preference_Variables
       help file, and the function will retrieve and set those as well.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Imports the default PowerShell preference variables from the caller into the local scope.
    .EXAMPLE
       Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState -Name 'ErrorActionPreference','SomeOtherVariable'

       Imports only the ErrorActionPreference and SomeOtherVariable variables into the local scope.
    .EXAMPLE
       'ErrorActionPreference','SomeOtherVariable' | Get-CallerPreference -Cmdlet $PSCmdlet -SessionState $ExecutionContext.SessionState

       Same as Example 2, but sends variable names to the Name parameter via pipeline input.
    .INPUTS
       String
    .OUTPUTS
       None.  This function does not produce pipeline output.
    .LINK
       about_Preference_Variables
    #>

    [CmdletBinding(DefaultParameterSetName = 'AllVariables')]
    param (
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_.GetType().FullName -eq 'System.Management.Automation.PSScriptCmdlet' })]
        $Cmdlet,

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.SessionState]$SessionState,

        [Parameter(ParameterSetName = 'Filtered', ValueFromPipeline = $true)]
        [string[]]$Name
    )

    begin {
        $filterHash = @{}
    }
    
    process {
        if ($null -ne $Name)
        {
            foreach ($string in $Name)
            {
                $filterHash[$string] = $true
            }
        }
    }

    end {
        # List of preference variables taken from the about_Preference_Variables help file in PowerShell version 4.0

        $vars = @{
            'ErrorView' = $null
            'FormatEnumerationLimit' = $null
            'LogCommandHealthEvent' = $null
            'LogCommandLifecycleEvent' = $null
            'LogEngineHealthEvent' = $null
            'LogEngineLifecycleEvent' = $null
            'LogProviderHealthEvent' = $null
            'LogProviderLifecycleEvent' = $null
            'MaximumAliasCount' = $null
            'MaximumDriveCount' = $null
            'MaximumErrorCount' = $null
            'MaximumFunctionCount' = $null
            'MaximumHistoryCount' = $null
            'MaximumVariableCount' = $null
            'OFS' = $null
            'OutputEncoding' = $null
            'ProgressPreference' = $null
            'PSDefaultParameterValues' = $null
            'PSEmailServer' = $null
            'PSModuleAutoLoadingPreference' = $null
            'PSSessionApplicationName' = $null
            'PSSessionConfigurationName' = $null
            'PSSessionOption' = $null

            'ErrorActionPreference' = 'ErrorAction'
            'DebugPreference' = 'Debug'
            'ConfirmPreference' = 'Confirm'
            'WhatIfPreference' = 'WhatIf'
            'VerbosePreference' = 'Verbose'
            'WarningPreference' = 'WarningAction'
        }

        foreach ($entry in $vars.GetEnumerator()) {
            if (([string]::IsNullOrEmpty($entry.Value) -or -not $Cmdlet.MyInvocation.BoundParameters.ContainsKey($entry.Value)) -and
                ($PSCmdlet.ParameterSetName -eq 'AllVariables' -or $filterHash.ContainsKey($entry.Name))) {
                
                $variable = $Cmdlet.SessionState.PSVariable.Get($entry.Key)
                
                if ($null -ne $variable) {
                    if ($SessionState -eq $ExecutionContext.SessionState) {
                        Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                    }
                    else {
                        $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                    }
                }
            }
        }

        if ($PSCmdlet.ParameterSetName -eq 'Filtered') {
            foreach ($varName in $filterHash.Keys) {
                if (-not $vars.ContainsKey($varName)) {
                    $variable = $Cmdlet.SessionState.PSVariable.Get($varName)
                
                    if ($null -ne $variable)
                    {
                        if ($SessionState -eq $ExecutionContext.SessionState)
                        {
                            Set-Variable -Scope 1 -Name $variable.Name -Value $variable.Value -Force -Confirm:$false -WhatIf:$false
                        }
                        else
                        {
                            $SessionState.PSVariable.Set($variable.Name, $variable.Value)
                        }
                    }
                }
            }
        }
    }
}

## PUBLIC MODULE FUNCTIONS AND DATA ##

function Get-MBTFunctionParameter {
    <#
        .EXTERNALHELP ModuleBuildTools-help.xml
        .LINK
            https://github.com/ModuleBuild/ModuleBuildTools/tree/master/release/0.0.1/docs/Get-MBTFunctionParameter.md
        #>
    [CmdletBinding()]
    param(
        [parameter(ValueFromPipeline=$true, HelpMessage='Lines of code to process.')]
        [string[]]$Code,
        [parameter(Position=1, HelpMessage='Name of function to process.')]
        [string]$Name,
        [parameter(Position=2, HelpMessage='Try to parse for script parameters as well.')]
        [switch]$ScriptParameters
    )
    begin {
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
        $Codeblock = @()
        $ParseError = $null
        $Tokens = $null
        # These are essentially our AST filters
        $functionpredicate = { ($args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst]) }
        $parampredicate = { ($args[0] -is [System.Management.Automation.Language.ParameterAst]) }
        $typepredicate = { ($args[0] -is [System.Management.Automation.Language.TypeConstraintAst]) }
        $paramattributes = { ($args[0] -is [System.Management.Automation.Language.NamedAttributeArgumentAst]) }
        $output = @()
    }
    process {
        $Codeblock += $Code
    }
    end {
        $ScriptText = ($Codeblock | Out-String).trim("`r`n")
        Write-Verbose "$($FunctionName): Attempting to parse AST."
        $AST = [System.Management.Automation.Language.Parser]::ParseInput($ScriptText, [ref]$Tokens, [ref]$ParseError)
        if($ParseError) {
            $ParseError | Write-Error
            throw "$($FunctionName): Will not work properly with errors in the script, please modify based on the above errors and retry."
        }
        if (-not $ScriptParameters) {
            $functions = $ast.FindAll($functionpredicate, $true)
            if (-not [string]::IsNullOrEmpty($Name)) {
                $functions = $functions | Where-Object {$_.Name -eq $Name}
            }
            # get the begin and end positions of every for loop
            foreach ($function in $functions) {
                Write-Verbose "$($FunctionName): Processing function - $($function.Name.ToString())"
                $Parameters = $function.FindAll($parampredicate, $true)
                foreach ($p in $Parameters) {
                    $ParamType = $p.FindAll($typepredicate, $true)
                    Write-Verbose "$($FunctionName): Processing Parameter of type [$($ParamType.typeName.FullName)] - $($p.Name.VariablePath.ToString())"
                    $OutProps = @{
                        'FunctionName' = $function.Name.ToString()
                        'ParameterName' = $p.Name.VariablePath.ToString()
                        'ParameterType' = $ParamType[0].typeName.FullName
                    }
                    # This will add in any other parameter attributes if they are specified (default attributes are thus not included and output may not be normalized)
                    $p.FindAll($paramattributes, $true) | ForEach-Object {
                        $OutProps.($_.ArgumentName) = $_.Argument.Value
                    }
                    $Output += New-Object -TypeName PSObject -Property $OutProps
                }
            }
        }
        else {
            Write-Verbose "$($FunctionName): Processing Script parameters"
            if ($ast.ParamBlock -ne $null) {
                $scriptparams = $ast.ParamBlock
                $Parameters = $scriptparams.FindAll($parampredicate, $true)
                foreach ($p in $Parameters) {
                    $ParamType = $p.FindAll($typepredicate, $true)
                    Write-Verbose "$($FunctionName): Processing Parameter of type [$($ParamType.typeName.FullName)] - $($p.Name.VariablePath.ToString())"
                    $OutProps = @{
                        'FunctionName' = 'Script'
                        'ParameterName' = $p.Name.VariablePath.ToString()
                        'ParameterType' = $ParamType[0].typeName.FullName
                    }
                    # This will add in any other parameter attributes if they are specified (default attributes are thus not included and output may not be normalized)
                    $p.FindAll($paramattributes, $true) | ForEach-Object {
                        $OutProps.($_.ArgumentName) = $_.Argument.Value
                    }
                    $Output += New-Object -TypeName PSObject -Property $OutProps
                }
            }
            else {
                Write-Verbose "$($FunctionName): There were no script parameters found"
            }
        }
        $Output
        Write-Verbose "$($FunctionName): End."
    }
}


Function Get-MBTSpecialPath {
    <#
        .EXTERNALHELP ModuleBuildTools-help.xml
        .LINK
            https://github.com/ModuleBuild/ModuleBuildTools/tree/master/release/0.0.1/docs/Get-MBTSpecialPath.md
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


function New-MBTCommentBasedHelp {
    <#
        .EXTERNALHELP ModuleBuildTools-help.xml
        .LINK
            https://github.com/ModuleBuild/ModuleBuildTools/tree/master/release/0.0.1/docs/New-MBTCommentBasedHelp.md
        #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "",Scope="function",Justification="")]
    param(
        [parameter(Position=0, ValueFromPipeline=$true, HelpMessage='Lines of code to process.')]
        [string[]]$Code,
        [parameter(Position=1, HelpMessage='Process the script parameters as the source of the comment based help.')]
        [switch]$ScriptParameters
    )
    begin {
        $FunctionName = $MyInvocation.MyCommand.Name
        Write-Verbose "$($FunctionName): Begin."
        $CBH_PARAM = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("LlBBUkFNRVRFUiAlJVBBUkFNJSUNCiUlUEFSQU1IRUxQJSUNCg=="))
        $CBHTemplate = [System.Text.Encoding]::UTF8.GetString([System.Convert]::FromBase64String("PCMNCi5TWU5PUFNJUw0KVEJEDQouREVTQ1JJUFRJT04NClRCRA0KJSVQQVJBTUVURVIlJQ0KLkVYQU1QTEUNClRCRA0KIz4="))
        $Codeblock = @()
    }
    process {
        $Codeblock += $Code
    }
    end {
        #$ScriptText = ($Codeblock | Out-String).trim("`r`n")
        Write-Verbose "$($FunctionName): Attempting to parse parameters."
        $FuncParams = @{}
        if ($ScriptParameters) {
            $FuncParams.ScriptParameters = $true
        }
        $AllParams = Get-MBTFunctionParameter @FuncParams -Code $Codeblock | Sort-Object -Property FunctionName
        $AllFunctions = @($AllParams.FunctionName | Select-Object -unique)

        foreach ($f in $AllFunctions) {
            $OutCBH = @{}
            $OutCBH.FunctionName = $f
            [string]$OutParams = ''
            $fparams = @($AllParams | Where-Object {$_.FunctionName -eq $f} | Sort-Object -Property Position)
            $fparams | ForEach-Object {
                $ParamHelpMessage = if ([string]::IsNullOrEmpty($_.HelpMessage)) {$_.ParameterName + " explanation`n`r"} else { $_.HelpMessage + "`n`r"}
                $OutParams += $CBH_PARAM -replace '%%PARAM%%',$_.ParameterName -replace '%%PARAMHELP%%',$ParamHelpMessage
            }

            $OutCBH.CBH = $CBHTemplate -replace '%%PARAMETER%%',$OutParams

            New-Object PSObject -Property $OutCBH
        }

        Write-Verbose "$($FunctionName): End."
    }
}


function Out-MBTZip {
    <#
        .EXTERNALHELP ModuleBuildTools-help.xml
        .LINK
            https://github.com/ModuleBuild/ModuleBuildTools/tree/master/release/0.0.1/docs/Out-MBTZip.md
        #>
    param (
        [Parameter(Position=0, Mandatory=$true)]
        [string] $Directory,
        [Parameter(Position=1, Mandatory=$true)]
        [string] $FileName,
        [Parameter(Position=2)]
        [switch] $overwrite
    )
    Add-Type -Assembly System.IO.Compression.FileSystem
    $compressionLevel = [System.IO.Compression.CompressionLevel]::Optimal
    if (-not $FileName.EndsWith('.zip')) {$FileName += '.zip'}
    if ($overwrite) {
        if (Test-Path $FileName) {
            Remove-Item $FileName
        }
    }
    [System.IO.Compression.ZipFile]::CreateFromDirectory($Directory, $FileName, $compressionLevel, $false)
}


function Publish-MBTProjectToPSGallery {
    <#
        .EXTERNALHELP ModuleBuildTools-help.xml
        .LINK
            https://github.com/ModuleBuild/ModuleBuildTools/tree/master/release/0.0.1/docs/Publish-MBTProjectToPSGallery.md
        #>
    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseApprovedVerbs", "",Scope="function",Justification="")]
    param(
        [parameter(Mandatory=$true, HelpMessage='Name of the module to upload.')]
        [string]$Name,
        [parameter(HelpMessage='Destination gallery (default is PSGallery)')]
        [string]$Repository = 'PSGallery',
        [parameter(HelpMessage='API key for the powershellgallery.com site.')]
        [string]$NuGetApiKey,
        [parameter(HelpMessage='Version to upload.')]
        $RequiredVersion
    )
    # if no API key is defined then look for psgalleryapi.txt in the local profile directory and try to use it instead.
    if ([string]::IsNullOrEmpty($NuGetApiKey)) {
        $psgalleryapipath = "$(Split-Path $Profile)\psgalleryapi.txt"
        Write-Verbose "No PSGallery API key specified. Attempting to load one from the following location: $($psgalleryapipath)"
        if (-not (test-path $psgalleryapipath)) {
            Write-Error "$psgalleryapipath wasn't found and there was no defined API key, please rerun script with a defined APIKey parameter."
            return
        }
        else {
            $NuGetApiKey = get-content -raw $psgalleryapipath
        }
    }

    Publish-Module -Name $Name -NuGetApiKey $NuGetApiKey -Repository $Repository -RequiredVersion $RequiredVersion
}


function Remove-MBTSignature
{
    <#
        .EXTERNALHELP ModuleBuildTools-help.xml
        .LINK
            https://github.com/ModuleBuild/ModuleBuildTools/tree/master/release/0.0.1/docs/Remove-MBTSignature.md
        #>

    [CmdletBinding( SupportsShouldProcess = $true )]
    Param (
        [Parameter(ValueFromPipeline = $True,ValueFromPipelineByPropertyName = $True)]
        [Alias('FilePath')]
        [string]$Path = $(Get-Location).Path,
        [Parameter()]
        [switch]$Recurse
    )
    Begin {
        $RecurseParam = @{}
        if ($Recurse) {
            $RecurseParam.Recurse = $true
        }
    }

    Process {
        $FilesToProcess = Get-ChildItem -Path $Path -File -Include '*.psm1','*.ps1','*.psd1','*.ps1xml' @RecurseParam

        $FilesToProcess | ForEach-Object -Process {
            $SignatureStatus = (Get-AuthenticodeSignature $_).Status
            $ScriptFileFullName = $_.FullName
            if ($SignatureStatus -ne 'NotSigned') {
                try {
                    $Content = Get-Content $ScriptFileFullName -ErrorAction Stop
                    $StringBuilder = New-Object -TypeName System.Text.StringBuilder -ErrorAction Stop

                    Foreach ($Line in $Content) {
                        if ($Line -match '^# SIG # Begin signature block|^<!-- SIG # Begin signature block -->') {
                            Break
                        }
                        else {
                            $null = $StringBuilder.AppendLine($Line)
                        }
                    }
                    if ($pscmdlet.ShouldProcess( "$ScriptFileFullName")) {
                        Set-Content -Path  $ScriptFileFullName -Value $StringBuilder.ToString()
                        Write-Output "$ScriptFileFullName -> Removed Signature!"
                    }
                }
                catch {
                    Write-Output "$ScriptFileFullName -> Unable to process signed file!"
                    Write-Error -Message $_.Exception.Message
                }
            }
            else {
                Write-Verbose "$ScriptFileFullName -> No signature, nothing done."
            }
        }
    }
}


## Post-Load Module code ##

# Use this variable for any path-sepecific actions (like loading dlls and such) to ensure it will work in testing and after being built
$MyModulePath = $(
    Function Get-ScriptPath {
        $Invocation = (Get-Variable MyInvocation -Scope 1).Value
        if($Invocation.PSScriptRoot) {
            $Invocation.PSScriptRoot
        }
        Elseif($Invocation.MyCommand.Path) {
            Split-Path $Invocation.MyCommand.Path
        }
        elseif ($Invocation.InvocationName.Length -eq 0) {
            (Get-Location).Path
        }
        else {
            $Invocation.InvocationName.Substring(0,$Invocation.InvocationName.LastIndexOf("\"));
        }
    }

    Get-ScriptPath
)

# Load any plugins found in the plugins directory
if (Test-Path (Join-Path $MyModulePath 'plugins')) {
    Get-ChildItem (Join-Path $MyModulePath 'plugins') -Directory | ForEach-Object {
        if (Test-Path (Join-Path $_.FullName "Load.ps1")) {
            Invoke-Command -NoNewScope -ScriptBlock ([Scriptblock]::create(".{$(Get-Content -Path (Join-Path $_.FullName "Load.ps1") -Raw)}")) -ErrorVariable errmsg 2>$null
        }
    }
}

$ExecutionContext.SessionState.Module.OnRemove = {
    # Action to take if the module is removed
    # Unload any plugins found in the plugins directory
    if (Test-Path (Join-Path $MyModulePath 'plugins')) {
        Get-ChildItem (Join-Path $MyModulePath 'plugins') -Directory | ForEach-Object {
            if (Test-Path (Join-Path $_.FullName "UnLoad.ps1")) {
                Invoke-Command -NoNewScope -ScriptBlock ([Scriptblock]::create(".{$(Get-Content -Path (Join-Path $_.FullName "UnLoad.ps1") -Raw)}")) -ErrorVariable errmsg 2>$null
            }
        }
    }
}

$null = Register-EngineEvent -SourceIdentifier ( [System.Management.Automation.PsEngineEvent]::Exiting ) -Action {
    # Action to take if the whole pssession is killed
    # Unload any plugins found in the plugins directory
    if (Test-Path (Join-Path $MyModulePath 'plugins')) {
        Get-ChildItem (Join-Path $MyModulePath 'plugins') -Directory | ForEach-Object {
            if (Test-Path (Join-Path $_.FullName "UnLoad.ps1")) {
                Invoke-Command -NoNewScope -ScriptBlock [Scriptblock]::create(".{$(Get-Content -Path (Join-Path $_.FullName "UnLoad.ps1") -Raw)}") -ErrorVariable errmsg 2>$null
            }
        }
    }
}

# Use this in your scripts to check if the function is being called from your module or independantly.
# Call it immediately to avoid PSScriptAnalyzer 'PSUseDeclaredVarsMoreThanAssignments'
$ThisModuleLoaded = $true
$ThisModuleLoaded

# Non-function exported public module members might go here.
#Export-ModuleMember -Variable SomeVariable -Function  *


