# DEVPOST SUBMISSION TEXT — STRIDEGUARD
# Copy each section into the corresponding Devpost field.
# =====================================================


## PROJECT NAME
StrideGuard


## TAGLINE (max 60 chars)
AI threat modeling on every merge request. Automatically.


## TEXT DESCRIPTION
(Paste this into the "Description" field on Devpost)
---

### What it does

StrideGuard is an AI agent built on the GitLab Duo Agent Platform that
automatically performs STRIDE threat modeling on merge requests and epics —
before vulnerabilities reach production.

Every time a developer opens or updates a merge request, StrideGuard triggers
automatically. It reads the full diff and relevant source files, reasons through
all six STRIDE categories (Spoofing, Tampering, Repudiation, Information
Disclosure, Denial of Service, Elevation of Privilege), and creates a structured
GitLab issue for every threat it identifies. Each issue includes the affected
file and line number, severity rating, CWE reference, plain-English description
of the exploit path, and specific remediation steps.

A summary comment is posted on the MR showing a severity-sorted table of all
threats with direct links to their issues. When the developer pushes a fix,
StrideGuard re-runs, closes resolved issues automatically, and updates the
comment — the threat model stays in sync with the code throughout review.

A second trigger mode lets teams apply the `needs-threat-model` label to any
GitLab epic or issue to trigger a pre-implementation threat model. The agent
analyzes the feature description and generates threats *before any code is
written*, shifting security left all the way to the planning phase.


### The problem it solves

Threat modeling is universally recognized as valuable and universally avoided
because it requires a calendar invite, a security engineer's time, and a
feature that's already half-built — at which point fixing architectural problems
is expensive. This is a textbook "AI Paradox" bottleneck: the process has clear
value but the manual toil makes it unsustainable at scale.

Existing tools don't solve this. SAST tools (Semgrep, CodeQL, Snyk) match known
vulnerability syntax patterns. They don't reason about architectural threat
categories or apply structured security methodology. GitLab's own SAST, DAST,
and dependency scanning all operate at the code level. None of them generate
pre-implementation threat models from feature descriptions.

StrideGuard is the only agent that applies STRIDE methodology at the MR and
planning layer, in real time, with zero human effort.


### How it's built

StrideGuard uses all three pillars of the GitLab Duo Agent Platform:

**Triggers** — Two trigger types: `merge_request` events (opened/updated) and
`label_event` on the `needs-threat-model` label applied to epics or issues.

**Context** — The agent reads the MR diff, changed source files (Python, Go,
JS, TypeScript, Ruby, Java, C#, Dockerfiles, RBAC configs, auth configs), and
the linked epic or issue description. Context is scoped intentionally — the
agent reads permission and auth config files specifically because auth
vulnerabilities frequently live in config, not just code.

**Tools** — The agent uses five GitLab tools in a deliberate sequence:
`gitlab:list_issues` to check for existing StrideGuard issues (prevents
duplicates on re-runs), `gitlab:create_issue` for each new threat,
`gitlab:close_issue` for resolved threats, and `gitlab:create_note` /
`gitlab:update_note` to maintain a single living summary comment per MR.

The analysis logic is defined in a detailed system prompt
(`prompts/stride_analysis.md`) that specifies exact threat patterns per
category, a four-tier severity rubric, a JSON threat record schema used
before any tool calls, and precise tool call ordering. This structured approach
ensures consistent, reproducible output across runs.


### STRIDE categories and what StrideGuard detects

- **Spoofing** — missing or bypassable authentication, weak token validation,
  session fixation, insecure SSO implementations
- **Tampering** — unsanitized user input reaching databases or file systems,
  SQL injection via f-strings or concatenation, missing integrity checks,
  deserialization of untrusted data
- **Repudiation** — actions performed without audit log entries, log entries
  missing user ID or timestamp, audit logs writable by the actor
- **Information Disclosure** — hardcoded secrets or API keys, PII written to
  logs, stack traces in error responses, overly permissive CORS
- **Denial of Service** — endpoints with no rate limiting, unbounded database
  queries, file upload without size validation, no circuit breakers
- **Elevation of Privilege** — BOLA/IDOR vulnerabilities, missing role checks
  before privileged operations, admin functionality accessible to non-admins


### Impact

Every engineering team that ships code has this bottleneck. The highest-value
targets are organizations with compliance obligations — SOC 2, HIPAA, PCI-DSS —
where threat modeling is technically required but rarely done rigorously.
StrideGuard makes continuous, comprehensive threat modeling a zero-cost default.


---


## TECHNOLOGIES USED
(Select/type these in the Devpost technologies field)

- GitLab Duo Agent Platform
- GitLab CI/CD
- YAML
- Markdown


---


## VIDEO SCRIPT NOTES
(Reference for recording your demo — not submitted to Devpost directly)

Recommended flow for the 3-minute video:

0:00–0:20  Open payments_endpoint.diff as a new MR. Show the diff briefly —
           point out the raw f-string SQL query and the hardcoded Stripe key.

0:20–0:50  StrideGuard triggers. Show the agent activity log in GitLab as it
           reads the diff. Narrate: "StrideGuard is reading the diff and
           running STRIDE analysis right now — no one scheduled this."

0:50–1:40  Show four issues being created in real time. Name each one:
           "High: SQL injection via unsanitized order_id",
           "High: Hardcoded Stripe secret key in source",
           "Medium: No authentication on /api/payments/initiate",
           "Medium: PII and secret prefix returned in API response".

1:40–2:10  Show the MR comment. Walk through the severity table. Click one
           issue link to show the full issue with CWE reference and
           remediation checklist.

2:10–2:40  Push a commit that adds parameterized queries and removes the
           hardcoded key. StrideGuard re-runs. Show the SQL injection and
           hardcoded key issues closing automatically. Comment updates.

2:40–3:00  Switch to an epic. Apply the needs-threat-model label. Show
           StrideGuard running from the description alone — "this is the
           proactive mode, threat modeling before a single line is written."


---


## INSTALLATION / TESTING INSTRUCTIONS
(Paste into the Devpost "Testing Instructions" field)
---

### Prerequisites

- GitLab 17.0+ with GitLab Duo Agent Platform enabled
- A GitLab project with Maintainer access

### Steps

1. Clone or fork this repository:
   https://gitlab.com/gitlab-ai-hackathon/strideguard

2. In your GitLab project, go to:
   Settings → Duo agents → New agent

3. Point the agent to `.gitlab/agents/strideguard/config.yaml`
   in this repository (or copy the config into your own project's
   `.gitlab/agents/` directory).

4. Grant the agent the following permissions under
   Settings → Duo agents → strideguard → Permissions:
   - create_issue
   - update_issue
   - close_issue
   - create_note

5. Open any merge request in your project. StrideGuard triggers automatically.

6. To test the label trigger: create an issue describing a new feature and
   apply the `needs-threat-model` label.

### Test diffs included

The repository includes two test MR diffs in `tests/sample_mr_diffs/`:

- `payments_endpoint.diff` — a realistic payments API with 5 STRIDE violations
  (SQL injection, hardcoded API key, missing auth, no rate limiting, PII in
  response). Use this for your primary demo.

- `auth_bypass.diff` — an auth service update with a debug bypass parameter
  and an IDOR vulnerability.

To use a test diff: create a branch, apply the diff with `git apply`, and
open a MR. StrideGuard will analyze it immediately.
