# Konfiguracja rozwiązania PLDC (`pdlc-solution`)

To repo przechowuje **konfigurację rozwiązania** jako pliki JSON:

- `config/current-solution.json` — wskazuje aktywny profil (`active_profile_file`)
- `config/solutions/*.json` — profile z linkami do repozytoriów implementacyjnych

## Minimalny kontrakt profilu

W pliku profilu muszą istnieć:

- `project.name` — czytelna nazwa projektu
- `project.code` — krótki kod (np. do branchy / tagów)
- `repos.frontend` — URL repo frontu (Angular)
- `repos.backend_dotnet` — URL repo API (.NET)
- `repos.gitops` — URL repo GitOps (Flux)

Opcjonalnie:

- `repos.liquibase_db` — URL repo migracji bazy (Liquibase)

## Zmiana aktywnego profilu

1. Dodaj nowy plik w `config/solutions/`.
2. Ustaw `active_profile_file` w `config/current-solution.json`.
3. Zrób PR i dodaj notatkę w `docs/changes/`.
