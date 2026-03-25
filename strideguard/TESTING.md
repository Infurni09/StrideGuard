# StrideGuard — Judge Testing Guide

This guide walks evaluators through installing and testing StrideGuard end-to-end.

---

## Prerequisites

- GitLab 17.0+ with GitLab Duo Agent Platform enabled on your instance or group
- A GitLab project where you have **Maintainer** access
- Git installed locally

Estimated setup time: **5–10 minutes**

---

## Step 1 — Get the agent configuration

Clone or fork this repository:

```bash
git clone https://github.com/Infurni09/StrideGuard.git
cd StrideGuard
```

The only file GitLab requires is `.gitlab/agents/strideguard/config.yaml`.
Everything else (prompts, templates, tests) is reference documentation.

---

## Step 2 — Register the agent in your GitLab project

1. In your GitLab project, navigate to **Settings → Duo agents → New agent**
2. Name the agent `strideguard`
3. Point it to `.gitlab/agents/strideguard/config.yaml` in this repository
   (or copy the file into your project's `.gitlab/agents/strideguard/` directory)
4. Click **Register**

---

## Step 3 — Grant the agent permissions

In **Settings → Duo agents → strideguard → Permissions**, grant:

| Permission | Why |
|-----------|-----|
| `create_issue` | Creates one issue per threat found |
| `update_issue` | Updates issue metadata on re-runs |
| `close_issue` | Closes issues for resolved threats |
| `create_note` | Posts the summary comment on the MR |
| `update_note` | Updates the summary comment on subsequent runs |

---

## Step 4 — Test the MR trigger (payments_endpoint.diff)

This diff intentionally contains **5 STRIDE violations** across 4 categories.

```bash
# In your test project
git checkout -b test/strideguard-payments-demo
git apply < path/to/StrideGuard/tests/sample_mr_diffs/payments_endpoint.diff
git commit -am "demo: add payments endpoint with known vulnerabilities"
git push origin test/strideguard-payments-demo
```

Then open a merge request from `test/strideguard-payments-demo` into `main`.

**Expected output — StrideGuard should:**

1. Trigger automatically when the MR is opened
2. Create **4–5 issues** labeled `strideguard`, `security`, `stride::*`, `severity::*`
3. Post a summary comment on the MR with a severity-sorted findings table

**Expected threats from payments_endpoint.diff:**

| ID | Severity | Category | What to look for |
|----|----------|----------|-----------------|
| STRIDE-T-1 | high | Tampering | SQL injection via f-string `order_id` query |
| STRIDE-I-1 | high | Information Disclosure | Hardcoded Stripe API key in source |
| STRIDE-S-1 | medium | Spoofing | No authentication on `/api/payments/initiate` |
| STRIDE-I-2 | medium | Information Disclosure | `db_path` and key prefix returned in API response |
| STRIDE-R-1 | low | Repudiation | Audit log entry missing `user_id` field |

---

## Step 5 — Test the re-run and auto-close behavior (auth_bypass.diff)

```bash
git checkout -b test/strideguard-auth-demo
git apply < path/to/StrideGuard/tests/sample_mr_diffs/auth_bypass.diff
git commit -am "demo: add auth bypass and IDOR vulnerability"
git push origin test/strideguard-auth-demo
```

Open a MR. StrideGuard creates issues for the threats found.

Then push a second commit that removes the `bypass_auth` query parameter:

```bash
# Edit services/auth/token_validator.go to remove the bypass block
git commit -am "fix: remove debug bypass_auth parameter"
git push
```

**Expected:** StrideGuard re-runs, closes the spoofing issue for the bypass,
and updates the MR comment. The IDOR issue (GetUserProfile with no auth check)
should remain open.

---

## Step 6 — Test the label trigger (pre-implementation threat model)

1. Create a new issue in your GitLab project with a feature description, e.g.:

   > "Add a file upload endpoint that allows authenticated users to upload
   > profile pictures. Files are stored in S3 and the URL is saved in the
   > users table. No size limit is enforced client-side."

2. Apply the label `needs-threat-model` to the issue.

**Expected output — StrideGuard should:**

1. Trigger from the label event (no MR required)
2. Create issues for design risks (e.g., no file size validation → DoS,
   no MIME type check → stored XSS, no virus scanning → malware upload)
3. Post a summary comment on the **issue** (not on any MR)
4. Remove `needs-threat-model` and add `threat-model-complete`

---

## What good output looks like

### Issue title
```
[STRIDE-T-1] [HIGH] SQL injection via unsanitized order_id parameter
```

### Issue labels
```
strideguard · security · stride::tampering · severity::high
```

### MR comment (abridged)
```
## StrideGuard Threat Model — 2025-01-15 14:32 UTC

StrideGuard identified 5 threat(s) across 4 STRIDE categories.

| ID         | Severity | Category              | Component          | Issue |
|------------|----------|-----------------------|--------------------|-------|
| STRIDE-T-1 | high     | Tampering             | api/payments.py    | #42   |
| STRIDE-I-1 | high     | Information Disclosure | api/payments.py   | #43   |
...
```

---

## Troubleshooting

| Symptom | Likely cause | Fix |
|---------|-------------|-----|
| Agent does not trigger | Agent not registered or wrong config path | Re-check Step 2 |
| Agent triggers but creates no issues | Missing `create_issue` permission | Re-check Step 3 |
| No MR comment posted | Missing `create_note` permission | Re-check Step 3 |
| Label trigger does not fire | Wrong label name (must be exactly `needs-threat-model`) | Check label spelling |
| Issues created but not closed on re-run | `close_issue` permission missing | Re-check Step 3 |
