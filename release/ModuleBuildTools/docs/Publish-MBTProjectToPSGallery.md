---
external help file: ModuleBuildTools-help.xml
Module Name: ModuleBuildTools
online version:
schema: 2.0.0
---

# Publish-MBTProjectToPSGallery

## SYNOPSIS
Upload module project to Powershell Gallery

## SYNTAX

```
Publish-MBTProjectToPSGallery [-Name] <String> [[-Repository] <String>] [[-NuGetApiKey] <String>]
 [[-RequiredVersion] <Object>] [<CommonParameters>]
```

## DESCRIPTION
Upload module project to Powershell Gallery

## EXAMPLES

### EXAMPLE 1
```
.\Publish-MBTProjectToPSGallery.ps1
```

## PARAMETERS

### -Name
Path to module to upload.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Repository
Destination gallery (default is PSGallery)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: PSGallery
Accept pipeline input: False
Accept wildcard characters: False
```

### -NuGetApiKey
API key for the powershellgallery.com site.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RequiredVersion
Version to upload.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
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
Site: http://www.the-little-things.net/

## RELATED LINKS
