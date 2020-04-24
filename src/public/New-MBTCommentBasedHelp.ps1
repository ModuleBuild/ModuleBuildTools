function New-MBTCommentBasedHelp {
    <#
    .SYNOPSIS
        Create comment based help for a function.
    .DESCRIPTION
        Create comment based help for a function.
    .PARAMETER Code
        Multi-line or piped lines of code to process.
    .PARAMETER ScriptParameters
        Process the script parameters as the source of the comment based help.
    .EXAMPLE
       PS > $testfile = 'C:\temp\test.ps1'
       PS > $test = Get-Content $testfile -raw
       PS > $test | New-CommentBasedHelp | clip

       Takes C:\temp\test.ps1 as input, creates basic comment based help and puts the result in the clipboard
       to be pasted elsewhere for review.
    .EXAMPLE
        PS > $CBH = Get-Content 'C:\EWSModule\Get-EWSContact.ps1' -Raw | New-CommentBasedHelp -Verbose -Advanced
        PS > ($CBH | Where {$FunctionName -eq 'Get-EWSContact'}).CBH

        Consumes Get-EWSContact.ps1 and generates advanced CBH templates for all functions found within. Print out to the screen the advanced
        CBH for just the Get-EWSContact function.
    .NOTES
       Author: Zachary Loeber
       Site: http://www.the-little-things.net/
       Requires: Powershell 3.0

       Version History
       1.0.0 - Initial release
       1.0.1 - Updated for ModuleBuild
       1.0.2 - Update for ModuleBuild. Base64 workaround for CBH variables. This was added since having the % % strings caused the top part of the function to be removed during a build.
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