# Contributing to StrideGuard

Thank you for your interest in StrideGuard. This document covers how to contribute,
how the project is structured, and the licensing requirements for the GitLab AI Hackathon.

## Licensing

All original work in this repository is subject to the **MIT License** and
[GitLab's Developer Certificate of Origin v1.1](https://docs.gitlab.com/ee/legal/developer_certificate_of_origin.html).

By contributing, you certify that you have the right to submit your contribution
under the MIT License.

## How to contribute

1. Fork this repository
2. Create a branch: `git checkout -b feat/your-feature-name`
3. Make your changes
4. Commit with a descriptive message
5. Open a merge request / pull request

## What we welcome

- New STRIDE pattern detection rules in `prompts/stride_analysis.md`
- Support for additional file types in `config.yaml`
- Improved issue or comment templates in `templates/`
- Additional test diffs in `tests/sample_mr_diffs/`
- Documentation improvements

## What we don't accept

- Changes that reduce the agent's safety or accuracy
- Contributions that violate any third-party license
- Breaking changes to the `config.yaml` schema without a migration path

## Questions

Open an issue in the GitLab repository.
