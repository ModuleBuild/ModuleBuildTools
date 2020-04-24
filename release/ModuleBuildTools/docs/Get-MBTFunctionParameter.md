---
external help file: ModuleBuildTools-help.xml
Module Name: ModuleBuildTools
online version:
schema: 2.0.0
---

# Get-MBTFunctionParameter

## SYNOPSIS
Return all parameters for each function found in a code block.

## SYNTAX

```
Get-MBTFunctionParameter [-Code <String[]>] [[-Name] <String>] [-ScriptParameters] [<CommonParameters>]
```

## DESCRIPTION
Return all parameters for each function found in a code block.

## EXAMPLES

### EXAMPLE 1
```
$testfile = 'C:\temp\test.ps1'
```

PS \> $test = Get-Content $testfile -raw
PS \> $test | Get-FunctionParameter -ScriptParameters
Takes C:\temp\test.ps1 as input, gathers any script's parameters and prints the output to the screen.

## PARAMETERS

### -Code
Multi-line or piped lines of code to process.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Name
Name of fuction to process.
If no funciton is given first the entire script will be processed for general parameters.
If none are found every function in the script will be processed.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ScriptParameters
Parse for script parameters only.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
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
1.0.1 - Updated function name to remove plural format
            Added Name parameter and logic for getting script parameters if no function is defined.
            Added ScriptParameters parameter to include parameters for a script (not just ones associated with defined functions)

## RELATED LINKS
