# Organized evals

This directory contains reproducible experiments for measuring whether Organized knowledge materially improves model behavior on real household-organization problems.

The user input stays intentionally messy and human. The model, not the fixture author, must infer a structured situation before grounded variants use Organized knowledge.

## Current pipeline

```text
raw user input
  -> structured situation extraction
  -> semantic knowledge retrieval
  -> three answer conditions
       A: naked model, raw user input only
       B: full case + all linked Organized knowledge
       C: structured situation + small retrieved knowledge set
  -> blind preference judge
  -> hidden-expectation coverage judge
  -> JSON artifact with outputs, mappings, latency, tokens, coverage, and wins
```

The preference judge measures usefulness without seeing which condition produced each response. The coverage judge separately measures whether scenario-specific reasoning properties were actually present. Keep these metrics separate: higher knowledge coverage does not necessarily imply a better final answer.

`EVAL_REPETITIONS` controls repeated blind answer/judge trials. Situation extraction and knowledge selection are currently performed once per scenario run and reused across repetitions, so the harness does not yet measure retrieval variance.

## Scenarios

- `ORG-EVAL-0001` - constrained cluttered room and premature storage purchases.
- `ORG-EVAL-0002` - mixed ownership, sentimental value, sunk purchase price, and resale transaction cost.
- `ORG-EVAL-0003` - repeated movement without state change and stale active inventory.

See [`../docs/eval-findings.md`](../docs/eval-findings.md) for the current experimental findings and limitations.

## Run locally

```bash
OPENAI_API_KEY=... \
OPENAI_MODEL=gpt-5.6-sol \
OPENAI_REASONING_EFFORT=high \
EVAL_REPETITIONS=5 \
bundle exec ruby evals/bin/run.rb ORG-EVAL-0001
```

Local runs call the model API directly and can spend credits. The GitHub Actions safety gate described below does not apply to direct local execution.

Generated run artifacts are written under `tmp/evals/` and are not source-of-truth knowledge.

## GitHub Actions safety gate

Fixture validation remains enabled and does not call a model API.

Paid model runs are **disabled by default**. The `run-eval` job is fail-closed and runs only when the repository Actions variable `OPENAI_EVALS_ENABLED` is explicitly set to `true`.

The `OPENAI_API_KEY` Actions secret may remain configured while paid evals are disabled. The secret alone cannot start a paid run.

To re-enable paid CI evals later:

1. Set repository Actions variable `OPENAI_EVALS_ENABLED=true`.
2. Trigger `workflow_dispatch`, or update the ephemeral request on `eval-runner`.
3. Remove or set the variable to anything other than `true` to disable paid runs again.

The ephemeral request file is intentionally not stored on `main`; see [`requests/README.md`](requests/README.md).
