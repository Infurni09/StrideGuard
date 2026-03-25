# StrideGuard — Hackathon Submission

**Hackathon:** GitLab AI Hackathon
**Track:** GitLab Duo Agent Platform
**License:** MIT

---

## Project name

**StrideGuard**

## Tagline

AI threat modeling on every merge request. Automatically.

---

## Text description

### What it does

StrideGuard is an AI agent built on the GitLab Duo Agent Platform that automatically
performs STRIDE threat modeling on merge requests and epics — before vulnerabilities
reach production.

Every time a developer opens or updates a merge request, StrideGuard triggers
automatically. It reads the full diff and relevant source files, reasons through
all six STRIDE categories (Spoofing, Tampering, Repudiation, Information Disclosure,
Denial of Service, Elevation of Privilege), and creates a structured GitLab issue
for every threat it identifies. Each issue includes:

- The affected file and line number
- Severity rating (critical / high / medium / low)
- CWE reference where applicable
- Plain-English description of the exploit path
- Specific remediation steps
- A resolution checklist for the developer

A summary comment is posted on the MR showing a severity-sorted table of all
threats with direct links to their issues. When the developer pushes a fix,
StrideGuard re-runs, closes resolved issues automatically, and updates the comment
— the threat model stays in sync with the code throughout review.

A second trigger mode lets teams apply the `needs-threat-model` label to any
GitLab epic or issue to trigger a pre-implementation threat model. The agent
analyzes the feature description and generates design risks *before any code is
written*, shifting security left all the way to the planning phase.

### The problem it solves

Threat modeling is universally recognized as valuable and universally avoided
because it requires a calendar invite, a security engineer's time, and a feature
that is already half-built — at which point fixing architectural problems is
expensive. This is a textbook "AI Paradox" bottleneck: the process has clear
value but the manual toil makes it unsustainable at scale.

Existing tools do not solve this. SAST tools (Semgrep, CodeQL, Snyk) match known
vulnerability syntax patterns. They do not reason about architectural threat
categories or apply structured security methodology. GitLab's own SAST, DAST,
and dependency scanning all operate at the code level. None generates
pre-implementation threat models from feature descriptions.

StrideGuard is the only agent that applies STRIDE methodology at the MR and
planning layer, in real time, with zero human scheduling effort.

### How it uses the GitLab Duo Agent Platform

StrideGuard uses all three pillars of the platform:

**Triggers** — Two trigger types:
- `merge_request` events (`opened` / `updated`) — fires on every MR change
- `label` event on `needs-threat-model` — fires when applied to any issue or epic

**Context** — The agent reads:
- `merge_request_diff` — the actual code change being reviewed
- `repository_files` — source files (Python, Go, JS/TS, Ruby, Java, C#, Dockerfiles,
  RBAC configs, auth configs) for full context beyond the diff
- `issue_description` and `epic_description` — for label-triggered pre-implementation analysis

**Tools** — Five GitLab tools used in a deliberate sequence:
1. `gitlab:list_issues` — checks for existing open StrideGuard issues to prevent duplicates
2. `gitlab:create_issue` — creates one issue per new threat with full structured content
3. `gitlab:close_issue` — closes issues for threats resolved in an updated MR
4. `gitlab:create_note` — posts the summary comment on first analysis
5. `gitlab:update_note` — updates the existing comment on re-runs (single living comment)

### STRIDE categories and what StrideGuard detects

| Category | What StrideGuard looks for |
|----------|---------------------------|
| Spoofing | Missing or bypassable auth, weak token validation, session fixation, insecure SSO |
| Tampering | Unsanitized input reaching databases or files, SQL injection, missing integrity checks, deserialization |
| Repudiation | Actions without audit log entries, log entries missing user ID or timestamp, writable audit logs |
| Information Disclosure | Hardcoded secrets, PII in logs, stack traces in responses, overly permissive CORS |
| Denial of Service | No rate limiting, unbounded queries, file upload without size validation, no circuit breakers |
| Elevation of Privilege | BOLA/IDOR, missing permission checks before privileged operations, admin routes accessible to users |

---

## Features and functionality

- **Zero-configuration for developers** — no developer action required; analysis runs automatically
- **Structured, actionable issues** — every issue has ID, severity, CWE, description, remediation, checklist
- **Label taxonomy** — `strideguard`, `security`, `stride::<category>`, `severity::<level>` on every issue
- **Deduplication** — checks open issues before creating to prevent duplicates on re-runs
- **Auto-resolution** — closes issues automatically when threats disappear from updated diffs
- **Living MR comment** — single comment updated in place, not spammed on every re-run
- **Pre-implementation mode** — label-triggered analysis from feature descriptions
- **Automatic cleanup** — removes `needs-threat-model` label and adds `threat-model-complete` after analysis

---

## Installation

See [TESTING.md](./TESTING.md) for complete step-by-step installation and testing instructions.

**Quick summary:**

1. Clone: `git clone https://github.com/Infurni09/StrideGuard.git`
2. Register the agent in your GitLab project under **Settings → Duo agents**
3. Point it to `.gitlab/agents/strideguard/config.yaml`
4. Grant permissions: `create_issue`, `update_issue`, `close_issue`, `create_note`, `update_note`
5. Open a merge request — StrideGuard triggers automatically

---

## Testing instructions

Full testing instructions with sample diffs and expected outputs are in [TESTING.md](./TESTING.md).

Two sample MR diffs are included in `tests/sample_mr_diffs/`:

- `payments_endpoint.diff` — a payments API with 5 STRIDE violations across 4 categories
  (use this for your primary demo)
- `auth_bypass.diff` — an auth service update with a debug bypass and an IDOR vulnerability

---

## Demo video

*(Link to be added before submission — see TESTING.md for the recommended demo flow)*

Recommended demo flow (3 minutes):

1. Apply `payments_endpoint.diff` and open an MR — show StrideGuard triggering
2. Show 4–5 issues being created in real time, walk through one issue
3. Show the MR comment severity table, click an issue link
4. Push a fix commit — show StrideGuard closing resolved issues and updating the comment
5. Apply `needs-threat-model` label to a feature issue — show pre-implementation analysis

---

## Third-party integrations

StrideGuard uses only first-party GitLab tools provided by the Duo Agent Platform:
`gitlab:create_issue`, `gitlab:update_issue`, `gitlab:close_issue`,
`gitlab:create_note`, `gitlab:update_note`, `gitlab:list_issues`.

No third-party SDKs, APIs, or data sources are used. No API keys are required.

---

## License

MIT License — see [LICENSE](./LICENSE).

All original work in this repository (agent configuration YAML, prompt files,
templates, scripts, documentation) is subject to the MIT License and GitLab's
Developer Certificate of Origin v1.1.
