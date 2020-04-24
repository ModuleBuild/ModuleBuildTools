---
external help file: ModuleBuildTools-help.xml
Module Name: ModuleBuildTools
online version: http://www.the-little-things.net
schema: 2.0.0
---

# Remove-MBTSignature

## SYNOPSIS
Finds all signed ps1 and psm1 files recursively from the current  or defined path and removes any digital signatures attached to them.

## SYNTAX

```
Remove-MBTSignature [[-Path] <String>] [-Recurse] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Finds all signed ps1 and psm1 files recursively from the current  or defined path and removes any digital signatures attached to them.

## EXAMPLES

### EXAMPLE 1
```
Remove-Signature -Recurse
```

Removes all digital signatures from ps1/psm1 files found in the current path.

## PARAMETERS

### -Path
Path you want to parse for digital signatures.

```yaml
Type: String
Parameter Sets: (All)
Aliases: FilePath

Required: False
Position: 1
Default value: $(Get-Location).Path
Accept pipeline input: True (ByPropertyName, ByValue)
Accept wildcard characters: False
```

### -Recurse
Recurse through all subdirectories of the path provided.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf
Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm
Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES
Author: Zachary Loeber

## RELATED LINKS

[http://www.the-little-things.net](http://www.the-little-things.net)

