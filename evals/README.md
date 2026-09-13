# Organized evals

This directory contains reproducible experiments for measuring whether Organized knowledge materially improves model behavior on real household-organization problems.

The first experiment keeps the user input intentionally messy and human. The model, not the fixture author, must infer structure.

## Pipeline

```text
raw user input
  -> structured situation extraction
  -> baseline answer
  -> Organized-grounded answer
  -> blind pairwise judge
  -> JSON artifact with latency, token usage, outputs, and scores
```

`ORG-EVAL-0001` uses `cases/ORG-CASE-0001.yml` and the principle/heuristic records referenced by that case as the grounded context. The baseline and grounded answer use the same model and the same advice prompt. The only deliberate difference is access to Organized knowledge.

## Run locally

```bash
OPENAI_API_KEY=... \
OPENAI_MODEL=gpt-5.6-sol \
OPENAI_REASONING_EFFORT=high \
bundle exec ruby evals/bin/run.rb ORG-EVAL-0001
```

Generated run artifacts are written under `tmp/evals/` and are not source-of-truth knowledge.

## GitHub Actions

`.github/workflows/evals.yml` validates eval fixtures on pull requests but does not spend API credits automatically. Actual model runs are manual through `workflow_dispatch`.

The workflow expects a repository Actions secret named `OPENAI_API_KEY`. Until that secret exists, fixture validation still works and manual model runs are skipped with an explicit message.
