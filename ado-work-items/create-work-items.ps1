<#
.SYNOPSIS
    Creates ADO work items (Epics, Features, User Stories) from JSON definitions.
    Demonstrates AI-generated work item hierarchy pushed into Azure DevOps.

.DESCRIPTION
    Reads epics.json, features.json, and user-stories.json and creates them in
    Azure DevOps via the REST API, preserving the parent-child hierarchy.

.PARAMETER Org
    Azure DevOps organization URL (e.g., https://dev.azure.com/contoso)

.PARAMETER Project
    Azure DevOps project name

.PARAMETER Pat
    Personal Access Token with Work Items (Read & Write) scope

.PARAMETER DryRun
    If set, prints what would be created without making API calls

.EXAMPLE
    .\create-work-items.ps1 -Org "https://dev.azure.com/contoso" -Project "SelfService" -Pat $pat
    .\create-work-items.ps1 -Org "https://dev.azure.com/contoso" -Project "SelfService" -Pat $pat -DryRun
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory = $false)]
    [string]$Org = $env:ADO_ORG,

    [Parameter(Mandatory = $false)]
    [string]$Project = $env:ADO_PROJECT,

    [Parameter(Mandatory = $false)]
    [string]$Pat = $env:ADO_PAT,

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

Or: .\create-work-items.ps1 -Org "..." -Project "..." -Pat "..."
"@
    exit 1
}

# ── Paths ────────────────────────────────────────────────────────────────────
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$itemsDir  = Join-Path $scriptDir "sample-items"

# ── Auth header ──────────────────────────────────────────────────────────────
$base64Auth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(":$Pat"))
$headers = @{
    Authorization  = "Basic $base64Auth"
    "Content-Type" = "application/json-patch+json"
}

# ── API helper ───────────────────────────────────────────────────────────────
function New-WorkItem {
    param(
        [string]$Type,
        [string]$Title,
        [string]$Description,
        [string]$AcceptanceCriteria,
        [int]$StoryPoints,
        [int]$Priority,
        [string]$Tags,
        [string]$AreaPath,
        [int]$ParentId
    )

    $body = @(
        @{ op = "add"; path = "/fields/System.Title";       value = $Title }
        @{ op = "add"; path = "/fields/System.Description"; value = $Description }
    )

    if ($AcceptanceCriteria) {
        # Convert newlines to HTML for ADO rich text field
        $htmlAC = ($AcceptanceCriteria -replace "`n", "<br/>")
        $body += @{ op = "add"; path = "/fields/Microsoft.VSTS.Common.AcceptanceCriteria"; value = $htmlAC }
    }

    if ($StoryPoints -gt 0) {
        $field = if ($Type -eq "User Story") {
            "/fields/Microsoft.VSTS.Scheduling.StoryPoints"
        } else {
            "/fields/Microsoft.VSTS.Scheduling.Effort"
        }
        $body += @{ op = "add"; path = $field; value = $StoryPoints }
    }

    if ($Priority -gt 0) {
        $body += @{ op = "add"; path = "/fields/Microsoft.VSTS.Common.Priority"; value = $Priority }
    }

    if ($Tags) {
        $body += @{ op = "add"; path = "/fields/System.Tags"; value = ($Tags -replace ";", "; ") }
    }

    if ($AreaPath) {
        $body += @{ op = "add"; path = "/fields/System.AreaPath"; value = $AreaPath }
    }

    if ($ParentId -gt 0) {
        $body += @{
            op    = "add"
            path  = "/relations/-"
            value = @{
                rel = "System.LinkTypes.Hierarchy-Reverse"
                url = "$Org/$Project/_apis/wit/workItems/$ParentId"
            }
        }
    }

    $url = "$Org/$Project/_apis/wit/workitems/`$$Type`?api-version=7.1"
    $json = $body | ConvertTo-Json -Depth 5

    if ($DryRun) {
        Write-Host "[DRY RUN] Would create $Type`: $Title" -ForegroundColor Cyan
        return @{ id = -1; fields = @{ "System.Title" = $Title } }
    }

    try {
        $response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $json
        Write-Host "[CREATED] $Type #$($response.id): $Title" -ForegroundColor Green
        return $response
    }
    catch {
        Write-Host "[ERROR]   $Type`: $Title — $($_.Exception.Message)" -ForegroundColor Red
        return $null
    }
}

# ── Load JSON files ──────────────────────────────────────────────────────────
Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  AI-Generated Work Items → Azure DevOps" -ForegroundColor Yellow
Write-Host "  Org:     $Org" -ForegroundColor Yellow
Write-Host "  Project: $Project" -ForegroundColor Yellow
Write-Host "  Mode:    $(if ($DryRun) { 'DRY RUN' } else { 'LIVE' })" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════`n" -ForegroundColor Yellow

$epics    = Get-Content (Join-Path $itemsDir "epics.json") | ConvertFrom-Json
$features = Get-Content (Join-Path $itemsDir "features.json") | ConvertFrom-Json
$stories  = Get-Content (Join-Path $itemsDir "user-stories.json") | ConvertFrom-Json

# Map local IDs → ADO IDs
$idMap = @{}

# ── Step 1: Create Epics ─────────────────────────────────────────────────────
Write-Host "── Creating Epics ($($epics.Count)) ────────────────────────────" -ForegroundColor Magenta
foreach ($epic in $epics) {
    $result = New-WorkItem `
        -Type "Epic" `
        -Title $epic.title `
        -Description $epic.description `
        -AcceptanceCriteria $epic.acceptanceCriteria `
        -StoryPoints $epic.storyPoints `
        -Priority $epic.priority `
        -Tags $epic.tags `
        -AreaPath $epic.areaPath

    if ($result) { $idMap[$epic.id] = $result.id }
}

# ── Step 2: Create Features (linked to Epics) ────────────────────────────────
Write-Host "`n── Creating Features ($($features.Count)) ─────────────────────" -ForegroundColor Magenta
foreach ($feat in $features) {
    $parentAdoId = $idMap[$feat.parentId]
    $result = New-WorkItem `
        -Type "Feature" `
        -Title $feat.title `
        -Description $feat.description `
        -AcceptanceCriteria $feat.acceptanceCriteria `
        -StoryPoints $feat.storyPoints `
        -Priority $feat.priority `
        -Tags $feat.tags `
        -ParentId $(if ($parentAdoId) { $parentAdoId } else { 0 })

    if ($result) { $idMap[$feat.id] = $result.id }
}

# ── Step 3: Create User Stories (linked to Features) ──────────────────────────
Write-Host "`n── Creating User Stories ($($stories.Count)) ──────────────────" -ForegroundColor Magenta
foreach ($story in $stories) {
    $parentAdoId = $idMap[$story.parentId]
    $result = New-WorkItem `
        -Type "User Story" `
        -Title $story.title `
        -Description $story.description `
        -AcceptanceCriteria $story.acceptanceCriteria `
        -StoryPoints $story.storyPoints `
        -Priority $story.priority `
        -Tags $story.tags `
        -ParentId $(if ($parentAdoId) { $parentAdoId } else { 0 })

    if ($result) { $idMap[$story.id] = $result.id }
}

# ── Summary ──────────────────────────────────────────────────────────────────
Write-Host "`n═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow
Write-Host "  Summary" -ForegroundColor Yellow
Write-Host "  Epics:        $($epics.Count)" -ForegroundColor Yellow
Write-Host "  Features:     $($features.Count)" -ForegroundColor Yellow
Write-Host "  User Stories: $($stories.Count)" -ForegroundColor Yellow
Write-Host "  Total:        $($epics.Count + $features.Count + $stories.Count)" -ForegroundColor Yellow
Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor Yellow

if (-not $DryRun) {
    Write-Host "`nView in ADO: $Org/$Project/_backlogs" -ForegroundColor Cyan
}
