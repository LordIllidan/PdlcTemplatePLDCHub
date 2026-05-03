$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'PdlcConfig.psm1') -Force

$repoRoot = Get-RepoRoot

$eventPath = $env:GITHUB_EVENT_PATH
if ([string]::IsNullOrWhiteSpace($eventPath)) {
  throw 'Missing GITHUB_EVENT_PATH'
}

$event = Get-Content -LiteralPath $eventPath -Raw | ConvertFrom-Json
$issueNumber = [int]$event.issue.number
if ($issueNumber -le 0) {
  throw 'Invalid issue.number in event payload'
}

$currentPath = Join-Path $repoRoot 'config/current-solution.json'
if (-not (Test-Path -LiteralPath $currentPath)) {
  throw "Missing config/current-solution.json"
}

$current = Get-Content -LiteralPath $currentPath -Raw | ConvertFrom-Json
if ($null -eq $current.active_profile_file) {
  throw "config/current-solution.json: missing active_profile_file"
}

$profilePath = Resolve-UnderConfig -RepoRoot $repoRoot -ConfigRelativePath ([string]$current.active_profile_file)
$profile = Get-Content -LiteralPath $profilePath -Raw | ConvertFrom-Json

if ($null -eq $profile.project) { throw "Profile missing project" }
Assert-NonEmptyString ([string]$profile.project.name) 'project.name'
Assert-NonEmptyString ([string]$profile.project.code) 'project.code'

if ($null -eq $profile.repos) { throw "Profile missing repos" }

Assert-GitHubHttpsRepoUrl ([string]$profile.repos.frontend) 'repos.frontend'
Assert-GitHubHttpsRepoUrl ([string]$profile.repos.backend_dotnet) 'repos.backend_dotnet'
Assert-GitHubHttpsRepoUrl ([string]$profile.repos.gitops) 'repos.gitops'

$relProfile = ConvertTo-RepoRelativePath -RepoRoot $repoRoot -AbsolutePath $profilePath

$lines = @()
$lines += '### PDLC routing (auto-generated)'
$lines += ''
$lines += ('Aktywny profil: `{0}`' -f $relProfile)
$lines += ''
$lines += '**Project**'
$lines += ('- name: `{0}`' -f $profile.project.name)
$lines += ('- code: `{0}`' -f $profile.project.code)
$lines += ''
$lines += '**Repos (implementation targets)**'
$lines += ('- frontend: {0}' -f $profile.repos.frontend)
$lines += ('- backend (.NET): {0}' -f $profile.repos.backend_dotnet)
$lines += ('- gitops: {0}' -f $profile.repos.gitops)

if ($null -ne $profile.repos.liquibase_db -and -not [string]::IsNullOrWhiteSpace([string]$profile.repos.liquibase_db)) {
  $lines += ('- liquibase_db: {0}' -f $profile.repos.liquibase_db)
}

$lines += ''
$lines += 'Agent hint: checkout and implement changes in the repositories above based on the issue scope.'

$bodyText = ($lines -join "`n")

$token = $env:GITHUB_TOKEN
if ([string]::IsNullOrWhiteSpace($token)) {
  throw 'Missing GITHUB_TOKEN'
}

$repo = $env:GITHUB_REPOSITORY
if ([string]::IsNullOrWhiteSpace($repo)) {
  throw 'Missing GITHUB_REPOSITORY'
}

$uri = "https://api.github.com/repos/$repo/issues/$issueNumber/comments"
$headers = @{
  Authorization = "Bearer $token"
  Accept        = 'application/vnd.github+json'
  'X-GitHub-Api-Version' = '2022-11-28'
}

Invoke-RestMethod -Method Post -Uri $uri -Headers $headers -ContentType 'application/json; charset=utf-8' -Body (@{ body = $bodyText } | ConvertTo-Json -Compress) | Out-Null

Write-Host ("Commented on issue #{0}" -f $issueNumber)
