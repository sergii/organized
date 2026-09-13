# Organized

**Organized** is an open knowledge base for making better decisions about spaces, possessions, routines, and everyday organization.

It exists to turn useful but often tacit everyday judgment into explicit, reusable, evidence-aware knowledge for both people and software.

## What this repository is

**The repository is the open knowledge base first.**

Agents, applications, APIs, websites, blog posts, landing pages, YouTube videos, Threads, TikTok, Instagram, and other outputs are consumers or projections of this knowledge. They are not separate sources of truth.

That distinction matters: the repository is optimized for durable concepts, claims, cases, provenance, uncertainty, localization, and validation rather than for the UX or SEO needs of one product.

Organized ranges from simple questions such as *“Where should I keep this?”* to complex situations such as moving, downsizing, inherited belongings, cluttered rooms, possessions held by other people, self-storage, and deciding what should continue to exist in your life.

## Core idea

A lot of useful everyday knowledge is tacit. Some people naturally see that a shelf is in the wrong place, that an item is expensive to keep, that a room needs capacity before organization, or that an emotional reason is being presented as a practical one.

Organized makes that knowledge explicit when doing so adds value through repeatable decisions, non-obvious principles, trade-offs, exceptions, provenance, reusable workflows, or learning from real outcomes.

It deliberately does **not** try to encode every piece of common sense.

## Knowledge loop

```text
external sources      user questions      real-world sessions
       \                    |                    /
        \                   |                   /
                         observations
                              |
                 knowledge / gaps / conflicts
                              |
                            cases
                              |
                    recommendations / action
                              |
                           outcomes
                              |
                              +------> observations
```

See [`docs/knowledge-lifecycle.md`](docs/knowledge-lifecycle.md).

## Model

Durable knowledge:

- **Principles** - durable claims expected to generalize.
- **Heuristics** - useful shortcuts or ranking aids with limits.
- **Practices** - concrete reusable techniques.
- **Anti-patterns** - approaches that tend to fail under known conditions.
- **Concepts** - stable vocabulary.
- **Cases** - reusable situations that compose knowledge into workflows.

Learning and provenance:

- **Sessions**, **Outcomes**, **Observations**, **Sources**, **Questions**, **Gaps**, and **Conflicts**.

See [`docs/knowledge-model.md`](docs/knowledge-model.md).

## Runtime consumption

Canonical knowledge stays in YAML and Git. Consumers can generate a deterministic JSONL projection for ingestion into PostgreSQL, lexical search, embeddings, or another runtime index:

```bash
bundle exec ruby scripts/export_runtime.rb
```

The generated `dist/organized-v1.jsonl` is a build artifact, not a second source of truth. Each line includes stable identity and revision metadata, retrieval text, source path, and the complete canonical record as JSON.

See [`docs/runtime-export.md`](docs/runtime-export.md).

## World state is separate from knowledge

An item can belong to one person, physically sit with another, be located elsewhere, and still require future action. `ownership`, `custody`, `location`, and `disposition` are deliberately separate concepts.

See [`docs/world-model.md`](docs/world-model.md).

## First living case

The first case is **decluttering in constrained space**: a small room is already full of furniture, boxes, papers, unknown belongings, and items with unclear ownership or value. The first goal is not visual tidiness. It is to create enough capacity to make good decisions.

- [`cases/ORG-CASE-0001.yml`](cases/ORG-CASE-0001.yml)
- [`sessions/ORG-SES-0001.yml`](sessions/ORG-SES-0001.yml)
- [`gaps/ORG-GAP-0001.yml`](gaps/ORG-GAP-0001.yml)
- [`conflicts/ORG-CF-0001.yml`](conflicts/ORG-CF-0001.yml)

## Languages

English is the canonical editorial language. Ukrainian is a first-class human-facing localization.

- [`locales/en.yml`](locales/en.yml)
- [`locales/uk.yml`](locales/uk.yml)
- [`locales/glossary.yml`](locales/glossary.yml)

Localizable canonical units have `revision`; each localized entry has `source_revision`. Validation fails when a translation is missing or stale.

See [`docs/localization.md`](docs/localization.md).

## Validation

Schemas are executable contracts, not documentation-only files.

```bash
bundle install
bundle exec ruby scripts/validate.rb
bundle exec ruby scripts/export_runtime.rb tmp/organized-v1.jsonl
```

CI validates:

- per-type JSON Schemas;
- unique IDs and filename/ID agreement;
- referential integrity for `ORG-*` references;
- one-way relationship policy;
- English and Ukrainian locale completeness;
- locale `source_revision` freshness;
- the consumer-facing runtime export contract.

## Repository layout

```text
organized/
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
├── schemas/
├── scripts/
└── docs/
```

## Licensing

Knowledge and content are licensed under **CC BY 4.0**. Code, schemas, validation tooling, and GitHub workflow infrastructure are licensed under **MIT**. Third-party material cited by `sources/` remains under its original terms.

See [`LICENSE.md`](LICENSE.md).

## Status

Early foundation. Current durable units are drafts and mostly `working_hypothesis`. The next value comes from real sessions and credible external sources, not from rapidly multiplying principles.
