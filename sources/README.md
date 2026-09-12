# Sources

This directory stores provenance for external knowledge used by Organized.

A source may be a book, article, research paper, professional guide, community discussion, video, interview, manual, or another stable artifact.

## Important distinction

A source is evidence of **where a claim came from**, not proof that the claim is universally true.

Organized should preserve:

- the source identity;
- the specific claim extracted from it;
- relevant context;
- agreement or disagreement with other sources;
- observations that support or challenge it;
- uncertainty and known exceptions.

## Workflow

```text
source
  ↓
extract claim
  ↓
normalize as observation or candidate knowledge
  ↓
compare with existing units
  ↓
support / refine / conflict / gap
```

Do not create fake source records to make a working hypothesis look better supported than it is. If a principle currently comes only from reasoning or one real-life report, keep its evidence status honest.

Source records use `ORG-SRC-*` IDs and should follow `schemas/source.schema.yml`.
