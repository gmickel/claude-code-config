# Non-destructive install of Claude Code config to ~/.claude/
# Never overwrites existing files

$ErrorActionPreference = "Stop"

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$TargetDir = Join-Path $env:USERPROFILE ".claude"

Write-Host "Installing to $TargetDir..."

# Create target dirs if needed
@("skills", "commands", "agents") | ForEach-Object {
    $dir = Join-Path $TargetDir $_
    if (!(Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
}

$copied = 0
$skipped = 0

function Copy-IfMissing {
    param($Source, $Dest)

    if (Test-Path $Dest) {
        $rel = $Dest.Replace($TargetDir, "").TrimStart("\", "/")
        Write-Host "  SKIP (exists): $rel"
        $script:skipped++
    } else {
        $parent = Split-Path -Parent $Dest
        if (!(Test-Path $parent)) {
            New-Item -ItemType Directory -Path $parent -Force | Out-Null
        }
        Copy-Item -Path $Source -Destination $Dest -Recurse
        $rel = $Dest.Replace($TargetDir, "").TrimStart("\", "/")
        Write-Host "  COPY: $rel"
        $script:copied++
    }
}

# Copy skills (each skill is a directory)
Get-ChildItem -Path (Join-Path $ScriptDir "skills") -Directory -ErrorAction SilentlyContinue | ForEach-Object {
    Copy-IfMissing $_.FullName (Join-Path $TargetDir "skills" $_.Name)
}

# Copy commands (each command is a file)
Get-ChildItem -Path (Join-Path $ScriptDir "commands") -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    Copy-IfMissing $_.FullName (Join-Path $TargetDir "commands" $_.Name)
}

# Copy agents (each agent is a file)
Get-ChildItem -Path (Join-Path $ScriptDir "agents") -Filter "*.md" -ErrorAction SilentlyContinue | ForEach-Object {
    Copy-IfMissing $_.FullName (Join-Path $TargetDir "agents" $_.Name)
}

Write-Host ""
Write-Host "Done: $copied copied, $skipped skipped (already exist)"
