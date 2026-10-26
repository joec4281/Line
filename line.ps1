param(
    [Parameter(Position = 0)]
    [string] $Source,

    [Parameter(Position = 1)]
    [string] $NumberText
)

if ($args.Count -gt 0 -or $null -eq $Source -or $null -eq $NumberText) {
    [Console]::Error.WriteLine('Usage: LINES <file|CLIP:> <line-number>')
    exit 1
}

$optionBase = 0
$optionBaseValue = [Environment]::GetEnvironmentVariable('OptionBase')

if ($null -ne $optionBaseValue) {
    $parsedOptionBase = 0

    if (
        -not [int]::TryParse($optionBaseValue, [ref] $parsedOptionBase) -or
        ($parsedOptionBase -ne 0 -and $parsedOptionBase -ne 1)
    ) {
        [Console]::Error.WriteLine('OptionBase must be 0 or 1.')
        exit 1
    }

    $optionBase = $parsedOptionBase
}

$isNegative = $NumberText.StartsWith('-', [StringComparison]::Ordinal)
$magnitudeText = if ($isNegative) {
    $NumberText.Substring(1)
}
else {
    $NumberText
}

[long] $requestedNumber = 0
if (
    -not [long]::TryParse($magnitudeText, [ref] $requestedNumber) -or
    $requestedNumber -lt 0
) {
    [Console]::Error.WriteLine(
        'The line number must be a non-negative integer, optionally preceded by ''-''.'
    )
    exit 1
}

try {
    $lines = New-Object 'System.Collections.Generic.List[string]'

    if ([string]::Equals($Source, 'CLIP:', [StringComparison]::OrdinalIgnoreCase)) {
        $text = [TakeCommand.PowerShellHost]::InvokeCommand('type clip:')

        if ($null -eq $text) {
            [Console]::Error.WriteLine('The TCC callback returned no text.')
            exit 1
        }

        $reader = [System.IO.StringReader]::new([string] $text)
        try {
            while ($null -ne ($line = $reader.ReadLine())) {
                $lines.Add($line)
            }
        }
        finally {
            $reader.Dispose()
        }
    }
    else {
        $reader = [System.IO.StreamReader]::new(
            $Source,
            [System.Text.Encoding]::Default,
            $true
        )
        try {
            while ($null -ne ($line = $reader.ReadLine())) {
                $lines.Add($line)
            }
        }
        finally {
            $reader.Dispose()
        }
    }

    if ($isNegative) {
        $index = [long] $lines.Count - 1 - $requestedNumber
    }
    else {
        $index = $requestedNumber - $optionBase
    }

    if ($index -lt 0 -or $index -ge $lines.Count) {
        Write-Output 'EOF'
    }
    else {
        Write-Output $lines[[int] $index]
    }

    exit 0
}
catch {
    [Console]::Error.WriteLine($_.Exception.Message)
    exit 1
}
