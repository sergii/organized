# Knowledge model

Organized separates **knowledge**, **world state**, **evidence**, and **presentation**.

The knowledge layer contains durable concepts, relationships, constraints, workflows, trade-offs, and evidence-aware guidance. The personal world model describes what physically exists for a particular person. Operational records capture sessions, outcomes, observations, questions, conflicts, and knowledge gaps. Locale files contain human-facing wording. Future channel-specific content such as a YouTube script or an Instagram post should be generated from these layers rather than becoming the source of truth.

## Design goals

1. Human-readable without special tooling.
2. Stable IDs so agents and applications can reference knowledge reliably.
3. Localizable without duplicating the underlying logic.
4. Evidence-aware: a rule, heuristic, observation, source claim, and opinion are not the same thing.
5. Case-driven: complex guidance should compose smaller knowledge units.
6. Progressive depth: simple questions should receive simple guidance, while complex cases can expose deeper reasoning.
7. Learn from use: real sessions and outcomes should be able to improve the knowledge base.
8. Preserve uncertainty: explicit gaps and conflicts are better than false certainty.
9. Small initial ontology: add structure only when real cases require it.

## Durable knowledge units

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

A reusable situation with context, objectives, constraints, stages, and references to relevant knowledge units.

Cases are orchestration, not duplicated knowledge.

## Learning and provenance entities

### Session

One concrete attempt to work through a case in the real world. A session records starting context, constraints, actions, observations, and outcomes.

### Outcome

A change observed after an action or session. Outcomes can be quantitative, qualitative, or both.

### Observation

A normalized statement about something directly observed, reported by a participant, inferred, or extracted as a claim from a source.

### Source

Provenance for an external artifact such as a book, article, study, professional guide, video, interview, manual, or community discussion.

### Question

A captured user question. Repeated or difficult questions can reveal missing or overly implicit knowledge.

### Gap

An explicit unknown or unresolved research question.

### Conflict

A preserved disagreement between claims or strategies. Conflicts should record when each position appears to work rather than forcing premature universal answers.

## Stable IDs

Durable knowledge:

- `ORG-PR-*` - principle
- `ORG-HEU-*` - heuristic
- `ORG-PRA-*` - practice
- `ORG-AP-*` - anti-pattern
- `ORG-CON-*` - concept
- `ORG-CASE-*` - case

Learning and provenance:

- `ORG-SES-*` - session
- `ORG-OUT-*` - outcome
- `ORG-OBS-*` - observation
- `ORG-SRC-*` - source
- `ORG-Q-*` - question
- `ORG-GAP-*` - knowledge gap
- `ORG-CF-*` - conflict

IDs should remain stable even when titles or wording change.

## Knowledge vs personal world state

General knowledge should not be mixed with a person's inventory.

```text
Organized knowledge
       +
personal world state
       +
goal and constraints
       ↓
contextual recommendation
```

See [`world-model.md`](world-model.md).

## Localization

Structured files reference an `i18n_key` when the entity has reusable human-facing copy. Human-facing text is stored in locale files such as `locales/en.yml` and `locales/uk.yml`.

English is currently the canonical editorial language, but localized text is not secondary output. Ukrainian should be maintained alongside English for published knowledge.

Operational records such as sessions and observations do not need duplicate prose in every locale unless they are promoted into reusable or published knowledge.

## Evidence status

A knowledge unit can start as a useful working hypothesis before it has external evidence. We should say that explicitly rather than pretending every good-sounding principle is proven.

Suggested states:

- `working_hypothesis`
- `community_practice`
- `expert_practice`
- `evidence_supported`
- `contested`

Knowledge units can attach sources, observations, outcomes, counterexamples, and confidence separately.

## Learning lifecycle

```text
external sources + user questions + real sessions
                    ↓
                  inbox
                    ↓
       observations / normalized claims
                    ↓
          compare / challenge / test
                    ↓
          knowledge / gaps / conflicts
                    ↓
                  cases
                    ↓
              recommendations
                    ↓
                  action
                    ↓
                 outcome
                    ↓
               observations
```

See [`knowledge-lifecycle.md`](knowledge-lifecycle.md).

## Content projections

A future content pipeline may look like this:

```text
knowledge + case + audience + intent + channel
                     ↓
YouTube / blog / Threads / TikTok / Instagram / landing page / app / API
```

A TikTok hook, a long-form article, and an agent instruction may look completely different while still expressing the same underlying knowledge.

## What should not be encoded

Do not encode obvious facts just because they can be encoded.

A knowledge unit earns its place when explicit representation improves consistency, transfer, evidence tracking, decision quality, case composition, or future learning.
