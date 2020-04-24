---
external help file: ModuleBuildTools-help.xml
Module Name: ModuleBuildTools
online version:
schema: 2.0.0
---

# New-MBTCommentBasedHelp

## SYNOPSIS
Create comment based help for a function.

## SYNTAX

```
New-MBTCommentBasedHelp [[-Code] <String[]>] [-ScriptParameters] [<CommonParameters>]
```

## DESCRIPTION
Create comment based help for a function.

## EXAMPLES

### EXAMPLE 1
```
$testfile = 'C:\temp\test.ps1'
```

PS \> $test = Get-Content $testfile -raw
PS \> $test | New-CommentBasedHelp | clip

Takes C:\temp\test.ps1 as input, creates basic comment based help and puts the result in the clipboard
to be pasted elsewhere for review.

### EXAMPLE 2
```
$CBH = Get-Content 'C:\EWSModule\Get-EWSContact.ps1' -Raw | New-CommentBasedHelp -Verbose -Advanced
```

PS \> ($CBH | Where {$FunctionName -eq 'Get-EWSContact'}).CBH

Consumes Get-EWSContact.ps1 and generates advanced CBH templates for all functions found within.
Print out to the screen the advanced
CBH for just the Get-EWSContact function.

## PARAMETERS

### -Code
Multi-line or piped lines of code to process.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -ScriptParameters
Process the script parameters as the source of the comment based help.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber
Site: http://www.the-little-things.net/
Requires: Powershell 3.0

Version History
1.0.0 - Initial release
1.0.1 - Updated for ModuleBuild
1.0.2 - Update for ModuleBuild.
Base64 workaround for CBH variables.
This was added since having the % % strings caused the top part of the function to be removed during a build.

## RELATED LINKS
