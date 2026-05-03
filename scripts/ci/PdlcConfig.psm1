$ErrorActionPreference = 'Stop'

function Get-RepoRoot {
  return (Resolve-Path (Join-Path $PSScriptRoot '..' '..')).Path
}

function Assert-NonEmptyString {
  param(
    [Parameter(Mandatory = $true)][string]$Value,
    [Parameter(Mandatory = $true)][string]$Field
  )

  if ([string]::IsNullOrWhiteSpace($Value)) {
    throw "$Field is required"
  }
}

function Assert-GitHubHttpsRepoUrl {
  param(
    [Parameter(Mandatory = $true)][string]$Value,
    [Parameter(Mandatory = $true)][string]$Field
  )

  Assert-NonEmptyString $Value $Field

  try {
    $uri = [Uri]$Value
  } catch {
    throw "$Field must be a valid URL"
  }

  if ($uri.Scheme -ne 'https') { throw "$Field must use https" }
  if ($uri.Host -ne 'github.com') { throw "$Field must point to github.com" }

  $segments = @($uri.AbsolutePath.Split('/', [System.StringSplitOptions]::RemoveEmptyEntries))
  if ($segments.Count -lt 2) {
    throw "$Field must look like https://github.com/{owner}/{repo}"
  }
}

function Resolve-UnderConfig {
  param(
    [Parameter(Mandatory = $true)][string]$RepoRoot,
    [Parameter(Mandatory = $true)][string]$ConfigRelativePath
  )

  Assert-NonEmptyString $ConfigRelativePath 'active_profile_file'

  if ($ConfigRelativePath -notmatch '^solutions/') {
    throw "active_profile_file must be a relative path under config/ starting with solutions/"
  }

  if ($ConfigRelativePath -match '(^|/)\.\.(/|$)') {
    throw "active_profile_file must not contain path traversal segments"
  }

  $full = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot 'config' $ConfigRelativePath))
  $configRoot = [System.IO.Path]::GetFullPath((Join-Path $RepoRoot 'config'))

  if (-not $full.StartsWith($configRoot + [System.IO.Path]::DirectorySeparatorChar, [System.StringComparison]::Ordinal) -and ($full -ne $configRoot)) {
    throw "Resolved profile path escapes config/: $ConfigRelativePath"
  }

  return $full
}

function ConvertTo-RepoRelativePath {
  param(
    [Parameter(Mandatory = $true)][string]$RepoRoot,
    [Parameter(Mandatory = $true)][string]$AbsolutePath
  )

  $rootFull = [System.IO.Path]::GetFullPath($RepoRoot)
  $absFull = [System.IO.Path]::GetFullPath($AbsolutePath)

  if (-not $absFull.StartsWith($rootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
    throw "Path is not under repo root: $AbsolutePath"
  }

  $rel = $absFull.Substring($rootFull.Length).TrimStart([char[]]@([System.IO.Path]::DirectorySeparatorChar, [System.IO.Path]::AltDirectorySeparatorChar))
  return ($rel -replace '\\', '/')
}

Export-ModuleMember -Function @(
  'Get-RepoRoot',
  'Resolve-UnderConfig',
  'Assert-NonEmptyString',
  'Assert-GitHubHttpsRepoUrl',
  'ConvertTo-RepoRelativePath'
)
