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

## Runtime consumption

The files in this repository are the canonical authoring representation of Organized knowledge. A consuming application may compile or synchronize them into another runtime form such as normalized JSON, PostgreSQL rows, a search index, or a vector index. Those runtime forms are projections, not competing sources of truth.

The default runtime hypothesis is:

```text
raw user message
  -> structured situation / world state
  -> retrieve the smallest relevant Organized knowledge set
  -> combine with stable behavior instructions
  -> model reasoning and answer composition
```

Do not inject the whole repository into every model request by default. A capable model already has broad prior knowledge; Organized is more useful when it makes important domain rules explicit and helps steer attention toward the few that matter in the current situation.

Keep three layers distinct:

- **behavior instructions** - how the model should behave, for example preserve uncertainty, avoid invented facts, and prefer actionable guidance;
- **domain knowledge** - reusable Organized principles, heuristics, practices, concepts, and case logic;
- **personal/world state** - facts, goals, constraints, ownership, custody, locations, and unresolved decisions for a particular person and situation.

A prompt is a temporary projection of these layers for one inference call. Domain records are not prompts and should not be hardcoded into a product-specific system instruction merely because they will eventually appear in model context.

Retrieval is part of product reasoning and should remain observable. Consumers should be able to record which knowledge IDs and revisions were selected for a recommendation so behavior can be reproduced, evaluated, and improved.

See [`eval-findings.md`](eval-findings.md) for the current experimental evidence behind this runtime direction.

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

The `related` field on durable knowledge is also directional. It means "this unit points to these other durable units as useful context or dependencies." It does **not** imply symmetry. A reverse `related`, `referenced_by`, `used_by`, or similar edge is derived from the repository graph rather than stored manually.

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

Localizable durable units and cases have an integer `revision`. Locale entries store `source_revision`; CI rejects stale translations when revisions differ.

`i18n_key` is intentionally not stored because it can be derived from type and ID.

See [`localization.md`](localization.md).

## Schema policy

Entity shapes are strict (`additionalProperties: false`). There is no arbitrary `extensions` escape hatch. When a reusable field proves useful in a real case, add it deliberately to the appropriate type schema so agents can validate and depend on it.

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

Do not encode obvious facts merely because they can be encoded. A unit earns its place when explicit representation improves consistency, transfer, evidence tracking, decision quality, case composition, retrieval, or future learning.
