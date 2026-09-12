# Organized

**Organized** is an open knowledge base for making better decisions about spaces, possessions, routines, and everyday organization.

It is designed for two audiences at the same time:

- **people**, who need clear, practical guidance;
- **agents and applications**, which need explicit, structured knowledge they can reason over and reuse.

Organized is not only about tidy homes or storage. It ranges from simple questions such as *“Where should I keep this?”* to complex situations such as moving, downsizing, inherited belongings, cluttered rooms, shared ownership, self-storage, and deciding what should continue to exist in your life.

## Core idea

A lot of useful everyday knowledge is tacit. Some people naturally see that a shelf is in the wrong place, that an item is expensive to keep, that a room needs capacity before organization, or that a sentimental object is being justified as a practical one.

Organized tries to make that knowledge explicit without turning common sense into needless bureaucracy.

We make knowledge explicit when doing so adds value through one or more of:

- repeatable decision frameworks;
- non-obvious principles;
- trade-offs and failure modes;
- exceptions and counterexamples;
- reusable workflows;
- provenance and evidence;
- accumulated outcomes from real cases.

## More than a static knowledge base

Organized is intended to learn from both external knowledge and real use.

```text
books / articles / research
professional practice
community experience
user questions
real-world sessions
          │
          ▼
        inbox
          │
          ▼
 observations / normalized claims
          │
          ▼
 knowledge / gaps / conflicts
          │
          ▼
         cases
          │
          ▼
 recommendations
          │
          ▼
         action
          │
          ▼
        outcome
          │
          └──────────────► observations
```

See [`docs/knowledge-lifecycle.md`](docs/knowledge-lifecycle.md).

## Knowledge model

Durable knowledge currently uses:

- **Principles** - durable rules that generalize across situations.
- **Heuristics** - useful shortcuts that are not universally true.
- **Practices** - concrete ways of doing something.
- **Anti-patterns** - approaches that look useful but often fail.
- **Concepts** - vocabulary needed to reason consistently.
- **Cases** - reusable situations that compose multiple knowledge units into a workflow.

Learning and provenance use:

- **Sessions** - concrete attempts to work through a case.
- **Outcomes** - what actually changed after actions or sessions.
- **Observations** - normalized facts, reports, inferences, or source claims.
- **Sources** - provenance for external knowledge.
- **Questions** - user questions that may expose missing knowledge.
- **Gaps** - explicit unknowns.
- **Conflicts** - competing claims or strategies whose boundaries still need to be understood.

A case does not replace the knowledge base. It selects and sequences the knowledge that matters for a particular situation.

See [`docs/knowledge-model.md`](docs/knowledge-model.md).

## Knowledge vs personal world state

Organized also separates general guidance from the state of a particular person's physical world.

An item can be owned by one person, physically held by another, stored somewhere else, and still require future action. Ownership, custody, location, and disposition are separate facts.

See [`docs/world-model.md`](docs/world-model.md).

## First living case

The first working case is **decluttering in constrained space**: a small room is already full of furniture, boxes, papers, unknown belongings, and items with unclear ownership or value. The goal is not to make it look tidy. The first goal is to create enough capacity to make good decisions.

- Case: [`cases/ORG-CASE-0001.yml`](cases/ORG-CASE-0001.yml)
- Planned real-world session: [`sessions/ORG-SES-0001.yml`](sessions/ORG-SES-0001.yml)
- Open knowledge gap: [`gaps/ORG-GAP-0001.yml`](gaps/ORG-GAP-0001.yml)
- Open strategy conflict: [`conflicts/ORG-CF-0001.yml`](conflicts/ORG-CF-0001.yml)

## Languages

English is the canonical working language. Ukrainian is maintained as a first-class localization.

Reusable human-facing copy lives in locale files:

- [`locales/en.yml`](locales/en.yml)
- [`locales/uk.yml`](locales/uk.yml)

Stable IDs connect localized content to the underlying knowledge units. Operational records such as raw observations and sessions do not need to duplicate every field in every language unless they are promoted into reusable published knowledge.

This allows the same source of truth to later power documentation, an API, applications, blog posts, landing pages, YouTube scripts, Threads, TikTok, Instagram, and other projections.

Ukrainian introduction: [`README.uk.md`](README.uk.md).

## Repository layout

```text
organized/
├── README.md
├── README.uk.md
├── docs/
│   ├── knowledge-model.md
│   ├── knowledge-lifecycle.md
│   └── world-model.md
├── knowledge/
│   ├── principles/
│   ├── heuristics/
│   └── concepts/
├── cases/
├── sessions/
├── outcomes/
├── observations/
├── questions/
├── gaps/
├── conflicts/
├── sources/
├── inbox/
├── locales/
│   ├── en.yml
│   └── uk.yml
└── schemas/
```

The structure is intentionally evolutionary. We will grow the model from real cases instead of designing a large ontology in advance.

## Status

Early foundation. Current knowledge units are drafts and should be treated as working hypotheses until they gain stronger provenance, counterexamples, external sources, and real-world outcomes.
