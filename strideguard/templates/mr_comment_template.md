# StrideGuard MR Comment Template — Agent Instructions

This file documents the format StrideGuard uses when calling `gitlab:create_note`
or `gitlab:update_note` on a merge request. The agent reads this as a reference
and constructs the comment body inline — it is not processed as a Liquid template.

---

## When threats are found

```markdown
## StrideGuard Threat Model — <YYYY-MM-DD HH:MM UTC>

StrideGuard identified **<N> threat(s)** across <M> STRIDE categories.

### Findings

| ID | Severity | Category | Component | Issue |
|----|----------|----------|-----------|-------|
| `STRIDE-T-1` | high | Tampering | `api/payments.py` | #<issue_iid> |
| `STRIDE-I-1` | high | Information Disclosure | `api/payments.py` | #<issue_iid> |
| `STRIDE-S-1` | medium | Spoofing | `api/payments.py` | #<issue_iid> |

*(one row per threat, sorted by severity descending: critical → high → medium → low)*

### Severity breakdown

| Severity | Count |
|----------|-------|
| 🔴 critical | <N> |
| 🟠 high     | <N> |
| 🟡 medium   | <N> |
| 🔵 low      | <N> |

> ⚠️ **Action required:** This MR contains critical or high severity threats.
> Please address the linked issues before merging.
> *(omit this block if no critical or high threats)*

---
StrideGuard re-analyzes automatically on each new commit. Resolved threats are
closed automatically. To trigger a manual re-analysis, close and re-open the MR.

*[StrideGuard](https://github.com/Infurni09/StrideGuard) — AI Threat Modeling Agent*
```

---

## When no threats are found

```markdown
## StrideGuard Threat Model — <YYYY-MM-DD HH:MM UTC>

✅ No threats identified. StrideGuard reviewed all six STRIDE categories against the
changed code and found no actionable security concerns.

If you believe this is incorrect, add the `needs-threat-model` label to this MR
to trigger a manual re-analysis with a broader context window.

*[StrideGuard](https://github.com/Infurni09/StrideGuard) — AI Threat Modeling Agent*
```

---

## Label-triggered comment (on epic or issue)

When the agent is triggered by the `needs-threat-model` label on an issue or epic,
it posts the same findings table as a comment on the triggering issue/epic. The
framing changes slightly — threats are described as design risks, not bugs:

```markdown
## StrideGuard Pre-Implementation Threat Model — <YYYY-MM-DD HH:MM UTC>

StrideGuard analyzed the feature description and identified **<N> design risk(s)**
to address before implementation begins.

### Risks to design for

| ID | Severity | Category | Component / Area | Issue |
|----|----------|----------|-----------------|-------|
| `STRIDE-S-1` | high | Spoofing | Authentication layer | #<issue_iid> |

*(same table structure as MR comment)*

### Severity breakdown

*(same table as MR comment)*

---
These risks were identified from the feature description alone. Re-run threat
modeling after implementation by applying the `needs-threat-model` label again.

*[StrideGuard](https://github.com/Infurni09/StrideGuard) — AI Threat Modeling Agent*
```

---

## Update vs. create behavior

- **First run on an MR:** call `gitlab:create_note`. Store the returned note ID.
- **Subsequent runs on the same MR:** call `gitlab:update_note` with the existing
  note ID (found by scanning existing notes for one containing "StrideGuard Threat Model").
  Replace the entire comment body — do not append.
