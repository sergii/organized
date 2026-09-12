# Knowledge model

Organized is an **open knowledge base first**. Applications, agents, APIs, websites, and content channels consume or project the knowledge; they are not competing sources of truth.

The repository separates durable knowledge, real-world evidence, and presentation.

## Design goals

1. Human-readable without special tooling.
2. Machine-validatable and safe to consume programmatically.
3. Stable IDs for references across agents and applications.
4. Evidence-aware: principles, heuristics, observations, source claims, gaps, and conflicts are not the same thing.
5. Case-driven: complex guidance composes smaller durable units.
6. Localizable without duplicating derived identifiers.
7. Honest about uncertainty and disagreement.
8. Evolutionary: add structure when real cases justify it.

## Durable knowledge

### Principle

A durable claim that is expected to generalize across situations. Principles use `statement` as their canonical English claim.

### Heuristic

A practical shortcut or ranking aid with known limitations. A heuristic is not an automatic decision rule.

### Practice

A concrete reusable way of doing something.

### Anti-pattern

A tempting approach that predictably creates failure or unnecessary work under known conditions.

### Concept

Stable vocabulary used by other units. Concepts use `definition`, not `statement`.

### Case

A reusable situation with context, objectives, constraints, and a workflow that composes durable knowledge. Cases are orchestration, not duplicated knowledge.

## Learning and provenance

- **Session** - one concrete attempt to work through a case.
- **Outcome** - a change that was actually observed after actions or a session.
- **Observation** - a normalized report, direct observation, source claim, or explicit inference.
- **Source** - provenance for external material.
- **Question** - a user question worth tracking because it may expose reusable knowledge or a gap.
- **Gap** - an explicit unknown.
- **Conflict** - competing claims or strategies whose boundaries are not yet resolved.

## One-way references

Do not maintain backlinks by hand.

Examples:

- observation -> knowledge it supports or challenges;
- session -> case;
- outcome -> session;
- gap -> case / observations / sources;
- conflict -> case / observations / sources;
- knowledge -> external sources it relies on.

Reverse relationships are computed from the repository graph. This prevents pairs of files from silently disagreeing.

## Stable IDs

- `ORG-PR-*` - principle
- `ORG-HEU-*` - heuristic
- `ORG-PRA-*` - practice
- `ORG-AP-*` - anti-pattern
- `ORG-CON-*` - concept
- `ORG-CASE-*` - case
- `ORG-SES-*` - session
- `ORG-OBS-*` - observation
- `ORG-OUT-*` - outcome
- `ORG-SRC-*` - source
- `ORG-Q-*` - question
- `ORG-GAP-*` - gap
- `ORG-CF-*` - conflict

IDs stay stable when wording changes.

## Revisions and localization

Localizable durable units and cases have an integer `revision`. Locale entries store `source_revision`; CI rejects stale translations.

`i18n_key` is intentionally not stored because it can be derived from type and ID.

See [`localization.md`](localization.md).

## Schema policy

Top-level entity shapes are strict (`additionalProperties: false`). Experimental, type-specific fields may be placed under an explicit `extensions` object rather than leaking arbitrary fields into the canonical shape.

Schemas use JSON Schema draft 2020-12 and declare `$id`. The validator checks schemas, unique IDs, filename/ID agreement, referential integrity, one-way backlink policy, locale completeness, and locale revision freshness.

## Evidence status

Durable knowledge may use:

- `working_hypothesis`
- `community_practice`
- `expert_practice`
- `evidence_supported`
- `contested`

A good-sounding idea starts as a working hypothesis. It does not become evidence-supported because it has been written in YAML.

## What should not be encoded

Do not encode obvious facts merely because they can be encoded. A unit earns its place when explicit representation improves consistency, transfer, evidence tracking, decision quality, case composition, or future learning.
