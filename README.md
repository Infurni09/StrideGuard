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

After each analysis, StrideGuard posts a summary table as a comment on the MR,
epic, or issue showing severity, category, affected component, and a direct link
to the created issue.

---

## STRIDE categories covered

| Letter | Category | What StrideGuard looks for |
|--------|----------|---------------------------|
| S | Spoofing | Missing auth, weak token validation, session issues |
| T | Tampering | Unsanitized input, missing integrity checks, SQLi |
| R | Repudiation | Audit log gaps, missing user ID in log entries |
| I | Info Disclosure | Secrets in code, PII in logs, verbose error messages |
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

Copy the `.gitlab/agents/strideguard/config.yaml` file from this repository into
your project's `.gitlab/agents/` directory, or point the agent registration at
this repository directly.

### Step 3 — Grant the agent permissions

The agent needs these permissions on your project:

- `create_issue` — to create threat issues
- `update_issue` / `close_issue` — to manage resolved threats
- `create_note` — to post MR comments

Configure these in **Settings → Duo agents → strideguard → Permissions**.

### Step 4 — Test it

Open a merge request in your project. StrideGuard should trigger automatically
and analyze the diff. To test the label trigger, create an issue describing a
new feature and apply the `needs-threat-model` label.

---

## Configuration

The agent is configured entirely in `.gitlab/agents/strideguard/config.yaml`.

### Scope which files are analyzed

By default, StrideGuard reads source files (`.py`, `.go`, `.js`, `.ts`, `.rb`,
`.java`, `.cs`), Dockerfiles, and common permission/auth config files. To add
or remove file patterns, edit the `context.repository_files.include` list.

### Change which events trigger the agent

The default triggers are `merge_request` (opened/updated) and label events on
epics and issues. To restrict to MRs only, remove the `label_event` trigger block.

### Customize the analysis prompt

The analysis logic lives in the `prompt` field of `config.yaml`. You can tune
severity scoring, add project-specific threat patterns, or restrict to certain
STRIDE categories by editing it directly. A standalone copy is in `prompts/stride_analysis.md`.

---

## Repository structure

```
strideguard/
├── .gitlab/
│   └── agents/
│       └── strideguard/
│           └── config.yaml          Agent definition (triggers, context, tools, prompt)
├── prompts/
│   └── stride_analysis.md           Standalone copy of the analysis prompt
├── templates/
│   ├── issue_template.md            Reference format for per-threat GitLab issues
│   └── mr_comment_template.md       Reference format for MR summary comment
├── tests/
│   └── sample_mr_diffs/
│       ├── payments_endpoint.diff   Realistic test diff (multiple threats)
│       └── auth_bypass.diff         Auth-focused test diff
├── setup.sh                         Import/push helper script
├── LICENSE                          MIT License
└── README.md
```

---

## How issues are labeled

Every issue created by StrideGuard carries these labels for easy filtering:

- `strideguard` — all issues created by this agent
- `security` — integrates with existing security workflows
- `stride::spoofing` / `stride::tampering` / etc. — category
- `severity::critical` / `severity::high` / `severity::medium` / `severity::low`

---

## Using the test diffs

The repository includes two test MR diffs in `tests/sample_mr_diffs/`:

- `payments_endpoint.diff` — a payments API with 5 STRIDE violations (SQL injection,
  hardcoded API key, missing auth, no rate limiting, PII in response)
- `auth_bypass.diff` — an auth service update with a debug bypass and an IDOR vulnerability

To use a test diff: create a branch, apply the diff with `git apply`, and open a MR.

---

## Contributing

Contributions are welcome. Please open an issue before submitting a large PR.
All original work is subject to the MIT License.

---

## License

MIT — see [LICENSE](./LICENSE).
