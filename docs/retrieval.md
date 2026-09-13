# Retrieval Contract v0.1

Organized retrieval sits between a structured Situation Model and the runtime knowledge projection.

```text
messy user input
  -> Situation Model v0.1
  -> retrieval/ranking
  -> small relevant Organized context
  -> model answer composition
```

The v0.1 implementation is deliberately deterministic and model-free. It exists to make the retrieval boundary observable before adding embeddings, a vector database, or another AI call.

## Runtime search text

`organized-v1.jsonl` now carries `search_texts` for three views of each knowledge record:

- `canonical` - canonical record text;
- `en` - English localization text;
- `uk` - Ukrainian localization text.

This allows a Ukrainian Situation Model to rank canonical English knowledge without requiring a translation model at retrieval time.

The canonical YAML remains the source of truth. Localized search text is a generated runtime projection.

## Baseline ranker

`scripts/retrieve_runtime.rb` implements `lexical-idf-prefix5-v0.1`.

It:

1. flattens the Situation Model into query text;
2. tokenizes Unicode words;
3. uses a small prefix normalization to reduce simple inflection differences;
4. computes inverse-document-frequency weights across the runtime knowledge set;
5. ranks records by overlapping terms;
6. returns matched terms and the text views that caused the match.

This is a baseline, not the intended final retrieval algorithm. It is intentionally easy to inspect and reproduce.

## Ranking is separate from selection

There is no hardcoded `max 3` policy in this contract. By default the retriever returns every positive-scoring candidate in rank order. A caller may supply a limit for a particular experiment or product decision.

That distinction is important:

```text
ranker
  = which records appear more relevant

selection policy
  = how many records are worth injecting into model context
```

The earlier evals showed that a fixed retrieval budget can cause one relevant rule to displace another. v0.1 therefore does not encode a permanent knowledge budget.

## CLI

First build the runtime export:

```bash
bundle exec ruby scripts/export_runtime.rb dist/organized-v1.jsonl
```

Then provide a Situation Model v0.1 object as JSON or YAML:

```bash
bundle exec ruby scripts/retrieve_runtime.rb situation.json dist/organized-v1.jsonl 5
```

The result follows `schemas/retrieval-result-v0.1.schema.yml` and includes stable knowledge IDs, revisions, scores, matched terms, and matched locale views.

## Known limitations

- lexical similarity is not semantic similarity;
- prefix normalization is intentionally crude and is not a language-specific stemmer;
- the current score is useful for deterministic ordering, not as calibrated probability;
- exact ranking can change as the knowledge corpus or localized wording changes;
- this layer does not decide whether a model needs more context after the first candidates are retrieved.

A later runtime consumer may replace this ranker with embeddings, hybrid search, reranking, or an adaptive selector while preserving the same observable boundary.
