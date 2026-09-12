# Localization

English is the canonical editorial language for durable knowledge. Ukrainian is a first-class human-facing localization.

## Derived lookup

Knowledge files do not store an `i18n_key`. The lookup is derived from entity type and stable ID:

- durable knowledge -> `knowledge.<ORG-ID>`
- cases -> `cases.<ORG-ID>`

This avoids duplicating data that can be computed deterministically.

## Revision tracking

Every localizable canonical entity has an integer `revision`.

Every localized entry has `source_revision`. A translation is current only when the two values match. CI fails when a localized entry is missing or stale.

Increment a canonical entity's `revision` when a change can require a translation update. Pure formatting, ordering, or metadata changes that do not affect human-facing meaning do not require a revision bump.

## Glossary

[`locales/glossary.yml`](../locales/glossary.yml) records deliberate terminology choices. Canonical machine vocabulary stays in English, but Ukrainian prose should not contain unexplained English terms merely because the schema uses them.

Prefer a natural phrase over a forced one-word translation when necessary.

## Operational records

Sessions, observations, outcomes, questions, gaps, conflicts, and source metadata are operational/provenance records. They are not required to have full parallel translations unless promoted into reusable public knowledge.
