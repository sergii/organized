# Eval findings

This note captures the current engineering findings from the first Organized retrieval experiments. It is not evidence that the domain principles themselves are scientifically validated.

## Setup

Runs used `gpt-5.6-sol` with high reasoning effort and five blind repetitions per scenario. Each repetition compared three conditions:

- **naked** - raw user message with the common advice prompt;
- **full** - structured situation plus the full case and all linked knowledge;
- **retrieved** - structured situation plus a small semantically selected subset of linked knowledge.

A blind preference judge measured practical answer quality. A separate hidden-expectation judge measured scenario-specific reasoning coverage.

## Current results

| Scenario | Condition | Avg coverage | Avg input tokens | Avg total tokens | Preference wins |
| --- | --- | ---: | ---: | ---: | ---: |
| ORG-EVAL-0001 | naked | 95.0% | 136 | 832 | 0 |
| ORG-EVAL-0001 | full | 100.0% | 2798 | 3579 | 2 |
| ORG-EVAL-0001 | retrieved | 100.0% | 1170 | 1866 | 0 |
| ORG-EVAL-0002 | naked | 90.0% | 173 | 1457 | 0 |
| ORG-EVAL-0002 | full | 100.0% | 3012 | 4386 | 0 |
| ORG-EVAL-0002 | retrieved | 100.0% | 1309 | 2674 | 1 |
| ORG-EVAL-0003 | naked | 86.0% | 196 | 1333 | 0 |
| ORG-EVAL-0003 | full | 97.2% | 3585 | 5290 | 0 |
| ORG-EVAL-0003 | retrieved | 85.8% | 1367 | 2492 | 2 |

The remaining repetitions were ties. These samples are intentionally small and should not be treated as statistically conclusive.

An additional experimental ORG-EVAL-0002 run added atomic ownership/sentimental knowledge records on the `eval-runner` branch. Retrieval changed from `ORG-PR-0005`, `ORG-PR-0006`, `ORG-HEU-0001` to `ORG-PR-0005`, `ORG-PR-0006`, `ORG-PR-0007`; retrieved coverage changed from 100.0% to 96.6%. This did not establish that more atomic records automatically improve retrieval, so those experimental additions should not be promoted merely to optimize this benchmark.

## What the experiments currently suggest

A strong frontier model already reconstructs much common household-organizing advice. Organized should therefore not be justified as a large prompt that teaches a model obvious facts.

The more promising role is **attention steering**: represent reusable decision rules explicitly, infer the current situation, retrieve the smallest relevant subset, and let the model compose the human response.

Full context consistently improved formal coverage, but it consumed substantially more input tokens and could introduce irrelevant concerns or cognitive load. In ORG-EVAL-0003, full context had the best coverage while retrieved context had the strongest blind preference result. Therefore knowledge coverage and answer quality must remain separate metrics.

Retrieval is product logic, not plumbing. A fixed `max 3` budget can omit an independent dimension even when the missing record is relevant. Future retrieval should be observable and may need an adaptive stopping rule rather than a fixed count.

Knowledge granularity also matters, but atomizing a case into more records is not automatically beneficial. Additional records increase the selection problem and can displace another useful rule.

## Important limitations

- Five repetitions per scenario are too few for statistical claims.
- The same model family generated and judged responses, so self-preference bias remains possible.
- Retrieval selection happened once per scenario run and was reused across repetitions; retrieval variance was not measured.
- Hidden expectation labels are evaluator fixtures, not a complete ontology of answer quality.
- These tests measure a pipeline that includes situation extraction for grounded conditions, not a pure knowledge-only intervention.

## Current default architecture hypothesis

```text
raw user message
  -> situation model
  -> retrieve a small relevant set of Organized records
  -> combine with stable behavior instructions
  -> model reasoning / answer composition
```

Do not inject the whole repository by default. Do not hardcode domain rules into a product-specific prompt when they belong in Organized. Keep canonical knowledge versioned independently from runtime indexes and prompt projections.
