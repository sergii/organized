# Runtime export

Organized is authored and reviewed as versioned YAML in Git. Applications should not need to parse the repository graph directly on every request, so the repository exposes a small, deterministic runtime contract.

## Export

```bash
bundle exec ruby scripts/export_runtime.rb
```

The default output is:

```text
dist/organized-v1.jsonl
```

A custom path can be supplied as the first argument:

```bash
bundle exec ruby scripts/export_runtime.rb tmp/organized.jsonl
```

The generated file is a runtime projection, not a second source of truth. It is safe to regenerate from the canonical YAML at any time.

## Record contract

Each JSONL line conforms to `schemas/runtime-knowledge-record-v1.schema.yml` and contains:

- `contract_version` - version of the consumer-facing export shape;
- `id`, `type`, `slug`, `revision`, `status` - stable record identity and lifecycle metadata;
- `evidence_status` when present in the canonical record;
- `summary` - the canonical statement, definition, or case situation summary;
- `retrieval_text` - deterministic search text derived from the record, intended for lexical, embedding, or hybrid indexing;
- `source_path` - canonical repository path for traceability;
- `content` - the complete validated YAML record represented as JSON.

The first contract intentionally includes durable knowledge and cases only:

```text
principles
heuristics
practices
anti-patterns
concepts
cases
```

Sessions, observations, outcomes, gaps, conflicts, questions, and sources remain evidence/learning records. A consumer may index those separately later, but they are not part of the v1 advice-retrieval contract.

## Consumer model

A product such as Rechibox can treat the export as an ingestion boundary:

```text
Organized YAML
  -> validate
  -> organized-v1.jsonl
  -> PostgreSQL / search index / vector index
  -> retrieve relevant IDs and revisions
  -> temporary model context
```

The database or search index is a projection. It must not become an independently edited copy of Organized knowledge.

For reproducibility, consumers should record at least the selected knowledge `id` and `revision` alongside the model request or resulting recommendation.

## Design constraints

The exporter is deliberately deterministic and contains no model calls. It does not rank records, create embeddings, or decide how many records should be retrieved. Those are runtime consumer concerns and should remain observable rather than hidden inside the knowledge build step.

Generated `dist/` files are build artifacts and should not be hand-edited or treated as canonical knowledge.
