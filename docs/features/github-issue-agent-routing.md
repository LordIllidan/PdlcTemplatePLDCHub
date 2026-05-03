# GitHub Issue routing dla agentów

Workflow `.github/workflows/pdlc-issue-routing.yml` uruchamia się przy `issues: opened`.

Skrypt `scripts/ci/Post-IssueRouteComment.ps1`:

- wczytuje aktywny profil z `config/current-solution.json`
- waliduje go tak samo jak CI
- dodaje komentarz do issue z listą docelowych repozytoriów

## Jak z tego korzystają agenty

Agent powinien potraktować komentarz jako **hint routingu**, ale kanoniczne źródło prawdy nadal są pliki w `config/`.
