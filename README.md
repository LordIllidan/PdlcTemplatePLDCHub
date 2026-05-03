# PdlcTemplatePLDCHub

Repozytorium-szablon „hubu” PLDC: trzyma **jedną aktywną konfigurację rozwiązania** (nazwa projektu + linki do repozytoriów kodu), żeby agenty CI/CD mogły **wskazać, gdzie implementować zmiany** po utworzeniu issue.

## Jak to działa (krótko)

- Aktywny profil jest w `config/current-solution.json` (pole `active_profile_file`).
- Profil zawiera m.in. `project` oraz `repos` (`frontend`, `backend_dotnet`, `gitops`, opcjonalnie inne).
- CI waliduje spójność plików przy każdym PR/pushu do `main`.
- Workflow `Pdlc Issue routing` dodaje komentarz do nowego issue z podsumowaniem aktywnej konfiguracji (dla ludzi i dla agentów).

## Start po utworzeniu repo z tego szablonu

1. Skopiuj `config/solutions/sample.json` jako `config/solutions/<twoj-profil>.json` i uzupełnij linki.
2. Ustaw `active_profile_file` w `config/current-solution.json` na swój plik profilu.
3. Zrób PR z krótkim opisem w `docs/changes/` (wymóg bramki dokumentacji zmian).

Szczegóły: `docs/features/pdlc-solution-config.md`.
