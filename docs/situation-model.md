# Situation Model v0.1

The Situation Model is the runtime boundary between messy human input and domain-knowledge retrieval. It is not canonical household knowledge and it is not a full inventory schema.

Its purpose is to preserve what is known, what is wanted, what constrains action, and what remains uncertain without collapsing inference into fact.

```text
raw input
  -> Situation Model
  -> retrieve relevant Organized records
  -> compose model context
```

## Core rules

- Facts are grounded in the user's words or direct observation.
- Hypotheses are explicitly inferred and carry confidence.
- Uncertainty is first-class; missing information is not silently invented.
- Goals describe desired outcomes, not recommendations.
- Constraints describe limits that affect feasible actions.
- Entities are lightweight references for things explicitly relevant to the current situation, not a permanent item model.
- `raw_input` is retained so downstream systems can audit interpretation.

The v0.1 contract deliberately avoids recommendations, action plans, knowledge IDs, retrieval results, and product-specific UI state.

## Why this stays small

A Situation Model should help retrieval and reasoning, not become a second ontology. New fields should be added only after real Rechibox conversations show that the existing contract loses important information.

The schema lives at `schemas/situation-model-v0.1.schema.yml`; examples live at `examples/situations/v0.1.yml`.
