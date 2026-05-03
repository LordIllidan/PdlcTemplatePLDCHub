# Walidacja CI konfiguracji PLDC Hub

CI w `.github/workflows/ci.yml` uruchamia skrypty PowerShell (`pwsh`) na runnerze Ubuntu:

- `scripts/ci/Validate-PdlcSolution.ps1` — sprawdza, że:
  - istnieje `config/current-solution.json`
  - `active_profile_file` wskazuje na plik w `config/solutions/`
  - profil ma wymagane pola oraz poprawne URL-e `https://github.com/{owner}/{repo}`
- `scripts/ci/Validate-Docs.ps1` — sprawdza, że:
  - istnieje niepusty `context.md`
  - istnieje katalog `docs/changes/`
  - na PR wymagana jest zmiana w `docs/changes/*.md`

## Dlaczego JSON + PowerShell

JSON jest łatwy do walidacji lokalnie na Windows (bez dodatkowych parserów), a `pwsh` jest dostępny zarówno lokalnie, jak i w GitHub Actions.
