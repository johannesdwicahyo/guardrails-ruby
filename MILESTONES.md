# guardrails-ruby — Milestones

> **Source of truth:** https://github.com/johannesdwicahyo/guardrails-ruby/milestones
> **Last synced:** 2026-04-14

This file mirrors the GitHub milestones for this repo. Edit the milestone or issues on GitHub and re-sync, do not hand-edit.

## v1.0.0 — Production Ready (**open**)

_Internationalization, streaming support, performance benchmarks, dashboard/reporting, and full documentation for stable release._

- [ ] #30 Add: Streaming LLM response support
- [ ] #31 Add: International PII patterns by locale
- [ ] #32 Add: Performance benchmarks and optimization
- [ ] #33 Add: Dashboard and reporting
- [ ] #34 Add: pattern-ruby integration for intent routing
- [ ] #35 Add: Comprehensive documentation and guides
- [ ] #36 Add: CI/CD pipeline

## v0.5.0 — Advanced Features (**open**)

_Check composition, conditional checks, rate limiting, audit log, YAML policy files, and dry-run mode._

- [ ] #24 Add: Check composition (AND, OR, NOT)
- [ ] #25 Add: Conditional checks
- [ ] #26 Add: Rate limiting check
- [ ] #27 Add: Persistent audit log
- [ ] #28 Add: YAML policy files
- [ ] #29 Add: Dry-run mode

## v0.4.0 — Rails & Middleware (**open**)

_Complete Rails integration with logging, metrics, Action Cable streaming support, and improved middleware._

- [ ] #20 Add: Rails logger integration
- [ ] #21 Add: Metrics and telemetry integration
- [ ] #22 Add: Action Cable streaming support
- [ ] #23 Improve: Middleware to support multiple LLM client interfaces

## v0.3.0 — LLM-Powered Checks (**open**)

_Add LLM-based checks for nuanced validation: prompt injection, toxicity, topic classification, relevance, and custom LLM check._

- [ ] #14 Add: LLM judge infrastructure
- [ ] #15 Add: LLM-powered prompt injection detection
- [ ] #16 Add: LLM-powered toxicity detection
- [ ] #17 Add: LLM-powered topic classification
- [ ] #18 Add: LLM-powered relevance check
- [ ] #19 Add: Custom LLM check with user-defined prompt

## v0.2.0 — Missing Deterministic Checks (**closed**)

_Implement remaining deterministic checks: language detection, code execution detection, disclaimer enforcement._

- [x] #9 Add: Language detection check
- [x] #10 Add: Code execution detection check
- [x] #11 Add: Disclaimer enforcement check
- [x] #12 Improve: PII detection for international formats
- [x] #13 Improve: Prompt injection patterns from PIPE dataset

## v0.1.1 — Bug Fixes (**closed**)

_Fix known bugs and code quality issues in the initial release._

- [x] #1 Fix: nil input crashes all checks with NoMethodError
- [x] #2 Fix: KeywordFilter redaction doesn't produce sanitized text
- [x] #3 Fix: Topic check uses substring matching causing false positives
- [x] #4 Fix: Example basic.rb uses wrong parameter name for max_length
- [x] #5 Fix: Email regex has redundant pipe in character class
- [x] #6 Refactor: Simplify Guard#run_checks sanitization tracking
- [x] #7 Improve: Toxic language check needs more patterns
- [x] #8 Add: CHANGELOG.md
