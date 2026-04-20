<#
.SYNOPSIS
    Pushes context documents from ado-wiki/ folder to Azure DevOps Wiki pages.

.DESCRIPTION
    Creates or updates wiki pages in ADO from local markdown files.
    These pages provide domain context (glossary, architecture, DoR, etc.)
    that the AI requirements analyst agent pulls from ADO Wiki during analysis.

.PARAMETER Org
    Azure DevOps organization URL (e.g., https://dev.azure.com/contoso)

.PARAMETER Project
    Azure DevOps project name

.PARAMETER Pat
    Personal Access Token with Wiki (Read & Write) scope

.PARAMETER WikiName
    Name of the wiki to create pages in. If not specified, uses the project wiki.

.PARAMETER ParentPath
    Parent path in the wiki for all pages (e.g., /Requirements-Context)

.PARAMETER DryRun
    If set, prints what would be created without making API calls

.EXAMPLE
    .\push-wiki-pages.ps1 -Org "https://dev.azure.com/contoso" -Project "SelfService" -Pat $pat
    .\push-wiki-pages.ps1 -Org "https://dev.azure.com/contoso" -Project "SelfService" -Pat $pat -ParentPath "/AI-Context"
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Org = $env:ADO_ORG,

    [Parameter(Mandatory = $false)]
    [string]$Project = $env:ADO_PROJECT,

    [Parameter(Mandatory = $false)]
    [string]$Pat = $env:ADO_PAT,

    [Parameter(Mandatory = $false)]
    [string]$WikiName,

    [Parameter(Mandatory = $false)]
    [string]$ParentPath = "/Requirements-Context",

    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

# ── Validate inputs ──────────────────────────────────────────────────────────
if (-not $Org -or -not $Project -or -not $Pat) {
    Write-Error @"
Missing required parameters. Set environment variables or pass parameters:

  `$env:ADO_ORG     = "https://dev.azure.com/your-org"
  `$env:ADO_PROJECT = "YourProject"
  `$env:ADO_PAT     = "your-pat"

Or: .\push-wiki-pages.ps1 -Org "..." -Project "..." -Pat "..."
"@
    exit 1
}

# ── Auth header ──────────────────────────────────────────────────────────────
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
$headers = @{
    Authorization = "Basic $base64Auth"
}

# ── Find the wiki ────────────────────────────────────────────────────────────
function Get-WikiId {
    $url = "$Org/$Project/_apis/wiki/wikis?api-version=7.1"
    $response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

    if ($WikiName) {
        $wiki = $response.value | Where-Object { $_.name -eq $WikiName }
        if (-not $wiki) {
            Write-Error "Wiki '$WikiName' not found. Available wikis: $($response.value.name -join ', ')"
            exit 1
        }
        return $wiki.id
    }

    # Default: use the project wiki (type = projectWiki)
    $wiki = $response.value | Where-Object { $_.type -eq "projectWiki" } | Select-Object -First 1
    if (-not $wiki) {
        # Fall back to any wiki
        $wiki = $response.value | Select-Object -First 1
    }
    if (-not $wiki) {
        Write-Error "No wikis found in project '$Project'. Create a wiki first in ADO."
        exit 1
    }

    Write-Host "Using wiki: $($wiki.name) (id: $($wiki.id))" -ForegroundColor Cyan
    return $wiki.id
}

# ── Create or update a wiki page ─────────────────────────────────────────────
function Set-WikiPage {
    param(
        [string]$WikiId,
        [string]$Path,
        [string]$Content
    )

    $encodedPath = [Uri]::EscapeDataString($Path)
    $url = "$Org/$Project/_apis/wiki/wikis/$WikiId/pages?path=$encodedPath&api-version=7.1"

    if ($DryRun) {
        Write-Host "[DRY RUN] Would create/update wiki page: $Path" -ForegroundColor Cyan
        return $true
    }

    # Try to get existing page first (to get ETag for update)
    $eTag = $null
    try {
        $existing = Invoke-WebRequest -Uri $url -Method Get -Headers $headers -ErrorAction Stop
        $eTag = $existing.Headers["ETag"]
    }
    catch {
        # Page doesn't exist — that's fine, we'll create it
    }

    $putHeaders = @{
        Authorization  = "Basic $base64Auth"
        "Content-Type" = "application/json"
    }

    if ($eTag) {
        $putHeaders["If-Match"] = $eTag
    }

    $body = @{ content = $Content } | ConvertTo-Json -Depth 3

    try {
        $response = Invoke-RestMethod -Uri $url -Method Put -Headers $putHeaders -Body $body
        $action = if ($eTag) { "UPDATED" } else { "CREATED" }
        Write-Host "[$action] Wiki page: $Path" -ForegroundColor Green
        return $true
    }
    catch {
        Write-Host "[ERROR]   Wiki page: $Path — $($_.Exception.Message)" -ForegroundColor Red
        return $false
    }
}

# ── Map local files to wiki page names ───────────────────────────────────────
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$wikiDir = Join-Path (Split-Path -Parent $scriptDir) "ado-wiki"

$pageMap = @(
    @{ File = "domain-glossary.md";          PageName = "Domain-Glossary" }
    @{ File = "architecture-context.md";     PageName = "Architecture-Context" }
    @{ File = "requirements-standards.md";   PageName = "Requirements-Standards" }
    @{ File = "definition-of-ready.md";      PageName = "Definition-of-Ready" }
    @{ File = "acceptance-criteria-guide.md"; PageName = "Acceptance-Criteria-Guide" }
)

# ── Run ──────────────────────────────────────────────────────────────────────
Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  Push Wiki Context Pages → Azure DevOps" -ForegroundColor Yellow
Write-Host "  Org:         $Org" -ForegroundColor Yellow
Write-Host "  Project:     $Project" -ForegroundColor Yellow
Write-Host "  Parent Path: $ParentPath" -ForegroundColor Yellow
Write-Host "  Mode:        $(if ($DryRun) { 'DRY RUN' } else { 'LIVE' })" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Yellow

if (-not $DryRun) {
    $wikiId = Get-WikiId
}

$success = 0
$failed = 0

foreach ($page in $pageMap) {
    $filePath = Join-Path $wikiDir $page.File
    if (-not (Test-Path $filePath)) {
        Write-Host "[SKIP]    File not found: $($page.File)" -ForegroundColor Yellow
        continue
    }

    $content = Get-Content $filePath -Raw
    $pagePath = "$ParentPath/$($page.PageName)"

    if ($DryRun) {
        Set-WikiPage -WikiId "n/a" -Path $pagePath -Content $content
        $success++
    }
    else {
        $result = Set-WikiPage -WikiId $wikiId -Path $pagePath -Content $content
        if ($result) { $success++ } else { $failed++ }
    }
}

# ── Summary ──────────────────────────────────────────────────────────────────
Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  Summary" -ForegroundColor Yellow
Write-Host "  Pages pushed: $success" -ForegroundColor Yellow
if ($failed -gt 0) {
    Write-Host "  Failed:       $failed" -ForegroundColor Red
}
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow

if (-not $DryRun -and $success -gt 0) {
    Write-Host "`nView in ADO Wiki: $Org/$Project/_wiki" -ForegroundColor Cyan
}
