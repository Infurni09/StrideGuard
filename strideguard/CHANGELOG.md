# Changelog

All notable changes to StrideGuard are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).

---

## [1.1.0] — 2025 (GitLab AI Hackathon — fixes and improvements)

### Fixed
- `config.yaml`: corrected trigger type from `label_event` to `label` (valid
  GitLab Duo Agent Platform schema field name)
- `config.yaml`: corrected context type from `epic_description` and
  `issue_description` to their validated schema names
- `setup.sh`: rewrote heredoc structure — `.gitignore` heredoc now properly
  closed before `git add` / `git commit` commands; SUBMISSION.md content was
  previously concatenated into the commit message heredoc and is now separate
- `setup.sh`: added directory guard to prevent running from wrong location
- `setup.sh`: set `git branch -M main` on fresh init so branch is named correctly
- `templates/issue_template.md` and `mr_comment_template.md`: replaced invalid
  Liquid/Jinja-style `{{ variable }}` syntax with documented agent instructions
  format, since templates are read as reference documents by the agent, not
  rendered by a template engine
- `prompts/stride_analysis.md`: restored complete threat record JSON schema
  (all 9 fields); added explicit deduplication step using `gitlab:list_issues`;
  added re-run section for auto-closing resolved threats on MR update trigger;
  added separate behavior section for label-triggered (epic/issue) runs
- Label names made consistent across all files: `stride::information-disclosure`
  (hyphenated), `stride::denial-of-service` (hyphenated); severity values
  lowercase (`critical`, `high`, `medium`, `low`) everywhere
- `README.md`: updated installation URLs from GitLab to GitHub; corrected
  configuration section to match actual `config.yaml` field names
- `tests/payments_endpoint.diff`: redacted fake Stripe live key format to
  prevent GitHub secret scanning blocks; added inline STRIDE annotation comments

### Added
- `TESTING.md`: step-by-step judge testing guide with prerequisites, installation,
  sample diff application instructions, expected outputs per diff, and troubleshooting
- `SUBMISSION.md`: complete standalone hackathon submission document with full
  feature description, GitLab Duo Agent Platform usage breakdown, installation
  summary, and third-party integrations disclosure

---

## [1.0.0] — 2025 (GitLab AI Hackathon — initial submission)

### Added
- Initial agent configuration (`config.yaml`) for the GitLab Duo Agent Platform
- Dual trigger support: MR events (opened/updated) and `needs-threat-model` label
- Full STRIDE analysis system prompt covering all six threat categories
- Severity scoring rubric: critical / high / medium / low
- Structured JSON threat record schema for consistent issue creation
- `gitlab:create_issue` integration with per-threat issue template
- `gitlab:close_issue` integration for auto-resolving threats on MR update
- `gitlab:create_note` / `gitlab:update_note` for MR summary comment
- `gitlab:list_issues` deduplication to prevent duplicate issues on re-runs
- Issue template with CWE references, remediation checklist, OWASP links
- MR comment template with severity breakdown table
- Label taxonomy: `strideguard`, `security`, `stride::<category>`, `severity::<level>`
- Two realistic test MR diffs: payments endpoint and auth bypass
- MIT License, Contributing guide, setup script
