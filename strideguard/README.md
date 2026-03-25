# StrideGuard

> AI-powered threat modeling agent for GitLab. Automatically analyzes merge
> requests and epics using the STRIDE methodology and creates structured
> security issues — before vulnerabilities reach production.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](./LICENSE)
[![GitLab Duo Agent Platform](https://img.shields.io/badge/GitLab%20Duo-Agent%20Platform-orange)](https://docs.gitlab.com/ee/user/gitlab_duo/)

---

## What it does

StrideGuard runs automatically when:

1. **A merge request is opened or updated** — analyzes the diff against all six
   STRIDE categories and creates a labeled GitLab issue for each threat found.
   On re-runs, it closes issues for threats that have been resolved.

2. **The `needs-threat-model` label is applied** to an epic or issue — performs
   a pre-implementation threat model from the description alone, so security
   concerns are surfaced before a line of code is written.

After each analysis, StrideGuard posts a summary comment on the MR, epic, or
issue showing severity, category, affected component, and a direct link to the
created issue.

---

## STRIDE categories covered

| Letter | Category | What StrideGuard looks for |
|--------|----------|---------------------------|
| S | Spoofing | Missing auth, weak token validation, session issues |
| T | Tampering | Unsanitized input, missing integrity checks, SQLi |
| R | Repudiation | Audit log gaps, missing user ID in log entries |
| I | Information Disclosure | Secrets in code, PII in logs, verbose error messages |
| D | Denial of Service | Missing rate limits, unbounded queries, no timeouts |
| E | Elevation of Privilege | BOLA/IDOR, missing permission checks, privilege escalation |

---

## Installation

### Prerequisites

- GitLab 17.0+ with GitLab Duo Agent Platform enabled
- A GitLab project where you have Maintainer access

### Step 1 — Clone this repository

```bash
git clone https://github.com/Infurni09/StrideGuard.git
cd StrideGuard
```

### Step 2 — Register the agent with your GitLab project

In your GitLab project, go to:
**Settings → Duo agents → New agent**

Name it `strideguard` and point it to `.gitlab/agents/strideguard/config.yaml`
from this repository (or copy the file into your own project's `.gitlab/agents/`
directory).

### Step 3 — Grant the agent permissions

In **Settings → Duo agents → strideguard → Permissions**, grant:

- `create_issue` — to create threat issues
- `update_issue` / `close_issue` — to manage resolved threats
- `create_note` / `update_note` — to post and update the MR summary comment

### Step 4 — Test it

Open a merge request in your project. StrideGuard triggers automatically.

For a full testing walkthrough including sample diffs and expected outputs,
see [TESTING.md](./TESTING.md).

---

## Configuration

The agent is configured in `.gitlab/agents/strideguard/config.yaml`.

### Scope which files are analyzed

By default, StrideGuard reads source files (`.py`, `.go`, `.js`, `.ts`, `.rb`,
`.java`, `.cs`), Dockerfiles, and common permission/auth config files. To add
or remove file patterns, edit the `context.repository_files.include` list.

### Change which events trigger the agent

The default triggers are `merge_request` (opened/updated) and `label` events on
issues and epics. To restrict to MRs only, remove the `label` trigger block.

### Customize the system prompt

The analysis logic lives in `prompts/stride_analysis.md`. You can tune severity
scoring, add project-specific threat patterns, or restrict to certain STRIDE
categories by editing this file. The `config.yaml` references it via `instructions:`.

---

## Repository structure

```
strideguard/
├── .gitlab/
│   └── agents/
│       └── strideguard/
│           └── config.yaml          Agent definition (triggers, context, tools)
├── prompts/
│   └── stride_analysis.md           System prompt: complete STRIDE analysis instructions
├── templates/
│   ├── issue_template.md            Reference format for per-threat GitLab issues
│   └── mr_comment_template.md       Reference format for MR summary comment
├── tests/
│   └── sample_mr_diffs/
│       ├── payments_endpoint.diff   Test diff: payments API with 5 STRIDE violations
│       └── auth_bypass.diff         Test diff: auth bypass + IDOR vulnerability
├── setup.sh                         Git init and push helper script
├── TESTING.md                       Step-by-step judge testing guide
├── SUBMISSION.md                    Full hackathon submission document
├── CHANGELOG.md                     Version history
├── CONTRIBUTING.md                  Contribution guidelines
├── LICENSE                          MIT License
└── README.md
```

---

## How issues are labeled

Every issue created by StrideGuard carries these labels for easy filtering:

| Label | Purpose |
|-------|---------|
| `strideguard` | All StrideGuard-generated issues |
| `security` | Integrates with existing security workflows |
| `stride::spoofing` | STRIDE category (one per issue) |
| `stride::tampering` | — |
| `stride::repudiation` | — |
| `stride::information-disclosure` | — |
| `stride::denial-of-service` | — |
| `stride::elevation-of-privilege` | — |
| `severity::critical` | Severity (one per issue) |
| `severity::high` | — |
| `severity::medium` | — |
| `severity::low` | — |

---

## Using the test diffs

Two test MR diffs are included in `tests/sample_mr_diffs/`:

**`payments_endpoint.diff`** — a realistic payments API with 5 STRIDE violations:
SQL injection via f-string, hardcoded API key, missing authentication, PII in
response, and audit log missing user ID. Use this for your primary demo.

**`auth_bypass.diff`** — an auth service update with a debug bypass parameter
(`bypass_auth=true` grants superuser access) and an IDOR vulnerability in
`GetUserProfile`.

To apply a diff:
```bash
git checkout -b test/stride-demo
git apply < tests/sample_mr_diffs/payments_endpoint.diff
git commit -am "demo: add intentionally vulnerable payments endpoint"
git push origin test/stride-demo
# Then open a MR
```

---

## Contributing

Contributions are welcome. Please open an issue before submitting a large PR.
All original work in this repository is subject to the MIT License and
[GitLab's Developer Certificate of Origin v1.1](https://docs.gitlab.com/ee/legal/developer_certificate_of_origin.html).

---

## License

MIT — see [LICENSE](./LICENSE).
