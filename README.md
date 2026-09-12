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

## Knowledge model

Organized currently uses these building blocks:

- **Principles** - durable rules that generalize across situations.
- **Heuristics** - useful shortcuts that are not universally true.
- **Practices** - concrete ways of doing something.
- **Anti-patterns** - approaches that look useful but often fail.
- **Concepts** - vocabulary needed to reason consistently.
- **Cases** - real situations that compose multiple knowledge units into a workflow.

A case does not replace the knowledge base. It selects and sequences the knowledge that matters for a particular situation.

## First case

The first working case is **decluttering in constrained space**: a small room is already full of furniture, boxes, papers, unknown belongings, and items with unclear ownership or value. The goal is not to make it look tidy. The first goal is to create enough capacity to make good decisions.

See [`cases/ORG-CASE-0001.yml`](cases/ORG-CASE-0001.yml).

## Languages

English is the canonical working language. Ukrainian is maintained as a first-class localization.

Human-facing copy lives in locale files:

- [`locales/en.yml`](locales/en.yml)
- [`locales/uk.yml`](locales/uk.yml)

Stable IDs connect localized content to the underlying knowledge units. This allows the same knowledge to later power documentation, an API, applications, blog posts, landing pages, YouTube scripts, Threads, TikTok, Instagram, and other projections without making any one content format the source of truth.

Ukrainian introduction: [`README.uk.md`](README.uk.md).

## Repository layout

```text
organized/
├── README.md
├── README.uk.md
├── docs/
│   └── knowledge-model.md
├── knowledge/
│   ├── principles/
│   └── heuristics/
├── cases/
├── locales/
│   ├── en.yml
│   └── uk.yml
└── schemas/
```

The structure is intentionally small. We will grow the taxonomy from real cases instead of designing a large ontology in advance.

## Status

Early foundation. Current knowledge units are drafts and should be treated as working hypotheses until they gain stronger provenance, counterexamples, and evidence.
