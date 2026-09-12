# Knowledge model

Organized separates **knowledge** from **presentation**.

The knowledge layer should contain durable concepts, relationships, constraints, workflows, trade-offs, and evidence. Locale files contain human-facing wording. Future channel-specific content such as a YouTube script or an Instagram post should be generated from the knowledge layer rather than becoming the source of truth.

## Design goals

1. Human-readable without special tooling.
2. Stable IDs so agents and applications can reference knowledge reliably.
3. Localizable without duplicating the underlying logic.
4. Evidence-aware: a rule, heuristic, observation, and opinion are not the same thing.
5. Case-driven: complex guidance should compose smaller knowledge units.
6. Progressive depth: simple questions should receive simple guidance, while complex cases can expose deeper reasoning.
7. Small initial ontology: add structure only when real cases require it.

## Knowledge unit types

### Principle

A durable rule that tends to generalize across domains and situations.

Example: `Touch things to change their state, not merely their location.`

### Heuristic

A practical shortcut that is useful under known conditions but should not be treated as universally true.

Example: prioritize actions that free a lot of space with little effort and high decision certainty.

### Practice

A concrete implementation technique.

Example: create one temporary working zone before processing difficult categories in a crowded room.

### Anti-pattern

A tempting approach that often creates work without improving the actual state of the system.

Example: repeatedly moving undecided items between surfaces.

### Concept

A stable term used by multiple knowledge units.

Examples: ownership, custody, location, disposition, replacement cost, space burden, mental inventory.

### Case

A situation with context, objectives, constraints, stages, and references to relevant knowledge units.

Cases are orchestration, not duplicated knowledge.

## Stable IDs

Initial prefixes:

- `ORG-PR-*` - principle
- `ORG-HEU-*` - heuristic
- `ORG-PRA-*` - practice
- `ORG-AP-*` - anti-pattern
- `ORG-CON-*` - concept
- `ORG-CASE-*` - case

IDs should remain stable even when titles or wording change.

## Localization

The structured files reference an `i18n_key`. Human-facing text is stored in locale files such as `locales/en.yml` and `locales/uk.yml`.

English is currently the canonical editorial language, but localized text is not secondary output. Ukrainian should be maintained alongside English for published knowledge.

The underlying reasoning fields remain language-independent whenever practical.

## Evidence status

A knowledge unit can start as a useful working hypothesis before it has external evidence. We should say that explicitly rather than pretending every good-sounding principle is proven.

Suggested states:

- `working_hypothesis`
- `community_practice`
- `expert_practice`
- `evidence_supported`
- `contested`

Future units can attach sources, observations, outcomes, counterexamples, and confidence separately.

## Content projections

A future content pipeline may look like this:

```text
knowledge unit / case
        ↓
locale
        ↓
audience + intent + channel
        ↓
YouTube / blog / Threads / TikTok / Instagram / landing page / app / API
```

A TikTok hook, a long-form article, and an agent instruction may look completely different while still expressing the same underlying knowledge.

## What should not be encoded

Do not encode obvious facts just because they can be encoded.

A knowledge unit earns its place when explicit representation improves consistency, transfer, evidence tracking, decision quality, case composition, or future learning.
