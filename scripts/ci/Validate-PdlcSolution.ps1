$ErrorActionPreference = 'Stop'

Import-Module (Join-Path $PSScriptRoot 'PdlcConfig.psm1') -Force

$repoRoot = Get-RepoRoot
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

if ($null -ne $profile.repos.liquibase_db -and -not [string]::IsNullOrWhiteSpace([string]$profile.repos.liquibase_db)) {
  Assert-GitHubHttpsRepoUrl ([string]$profile.repos.liquibase_db) 'repos.liquibase_db'
}

$allowedRepoKeys = @('frontend', 'backend_dotnet', 'gitops', 'liquibase_db', 'orchestrator')
$extra = $profile.repos.PSObject.Properties.Name | Where-Object { $_ -notin $allowedRepoKeys }
if ($extra.Count -gt 0) {
  throw ("Unsupported repos keys: " + ($extra -join ', '))
}

if ($null -ne $profile.repos.orchestrator -and -not [string]::IsNullOrWhiteSpace([string]$profile.repos.orchestrator)) {
  Assert-GitHubHttpsRepoUrl ([string]$profile.repos.orchestrator) 'repos.orchestrator'
}

$relProfile = ConvertTo-RepoRelativePath -RepoRoot $repoRoot -AbsolutePath $profilePath
Write-Host ("OK: active profile -> {0}" -f $relProfile)
