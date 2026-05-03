# Change: Add repos.orchestrator to hub profile

## Summary

Profil rozwiązania w hubie może zawierać opcjonalne `repos.orchestrator` (URL repo `*-control`); szablon `sample.json` i walidacja CI zostały rozszerzone.

## Verification

- `pwsh ./scripts/ci/Validate-PdlcSolution.ps1`

## Context Updates

- `docs/features/pdlc-solution-config.md`
