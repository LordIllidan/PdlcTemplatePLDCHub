# Kontekst repozytorium (PDLC Hub)

To repozytorium **nie jest aplikacją**. Jest **źródłem prawdy dla konfiguracji rozwiązania PLDC**: nazwa projektu oraz linki do repozytoriów, w których agent CI/CD ma wykonywać pracę inżynierską.

## Kanoniczne pliki

- `config/current-solution.json` — wskazuje aktywny profil (`active_profile_file`).
- `config/solutions/*.json` — profile rozwiązań (linki do FE/BE/GitOps i opcjonalnie innych repo).

## Zasady utrzymania

- Zmiana aktywnego profilu albo treści profilu wymaga PR i wpisu w `docs/changes/`.
- Nie commituj sekretów (tokenów). To repo powinno zawierać wyłącznie publiczne URL-e do GitHub.

## Integracja z agentami

Agenty powinny:

1. Wczytać `config/current-solution.json`.
2. Rozwiązać ścieżkę profilu względem katalogu `config/`.
3. Użyć pól `repos.*` jako docelowych repozytoriów do checkoutu i zmian kodu.
