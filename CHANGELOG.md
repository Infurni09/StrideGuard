# Changelog

All notable changes to StrideGuard are documented here.

## [1.0.0] — 2025 (GitLab AI Hackathon submission)

### Added
- Initial agent configuration (`config.yaml`) for the GitLab Duo Agent Platform
- Dual trigger support: MR events (opened/updated) and `needs-threat-model` label
- Full STRIDE analysis system prompt covering all six threat categories
- Severity scoring rubric: Critical / High / Medium / Low
- Structured JSON threat record schema for consistent issue creation
- `gitlab:create_issue` integration with per-threat issue template
- `gitlab:close_issue` integration for auto-resolving threats on MR update
- `gitlab:create_note` / `gitlab:update_note` for MR summary comment
- `gitlab:list_issues` deduplication to prevent duplicate issues on re-runs
- Issue template with CWE references, remediation checklist, OWASP links
- MR comment template with severity breakdown table
- Label taxonomy: `strideguard`, `security`, `stride::<category>`, `severity::<level>`
- Two realistic test MR diffs: payments endpoint and auth bypass
- MIT License
- Contributing guide
- GitHub/GitLab import script (`setup.sh`)
