# Knowledge lifecycle

Organized is not a static encyclopedia. It is a learning system that turns external knowledge, questions, and real-world outcomes into reusable guidance.

## Inputs

Knowledge can enter the system from several independent streams:

1. **Real-world sessions** - a person applies guidance in an actual space or situation.
2. **External sources** - books, articles, research, professional practice, community discussions, videos, manuals, and operator guides.
3. **Questions** - repeated user questions reveal where existing knowledge is missing, unstable, or too implicit.
4. **Existing knowledge** - contradictions and weak evidence inside the repository can themselves create research tasks.

## Lifecycle

```text
books / articles / research
professional practice
community experience
user questions
real-world sessions
          │
          ▼
        INBOX
          │
   normalize / extract
          │
          ▼
     OBSERVATIONS
          │
 compare / challenge / test
          │
 ┌────────┼─────────┐
 ▼        ▼         ▼
KNOWLEDGE CONFLICTS GAPS
 │
 ▼
CASES
 │
 ▼
RECOMMENDATIONS
 │
 ├──────┬────────┐
 ▼      ▼        ▼
APP   AGENT   CONTENT
 │
 ▼
ACTION
 │
 ▼
OUTCOME
 │
 └──────────────► OBSERVATIONS
```

The purpose of this loop is not to make every human action measurable. It is to capture enough evidence to discover where guidance works, fails, conflicts, or needs context.

## Capture first, curate later

Do not force people to author knowledge while they are doing physical work.

During a session, capture only what is cheap and useful:

- what the person was trying to achieve;
- relevant constraints;
- what action was taken;
- what happened;
- what surprised or blocked them;
- what decision remained unresolved.

A later curation step can turn this into observations, candidate principles, heuristics, conflicts, or gaps.

## Session vs case

A **case** is a reusable type of situation, such as `decluttering a constrained room`.

A **session** is one concrete attempt by a person to work through a case in the real world.

A single case may accumulate hundreds of sessions. Sessions are evidence, not canonical guidance.

## Observation

An observation is a normalized statement about something that happened, was noticed, or was reported.

Observations should distinguish:

- direct observation;
- participant report;
- inferred interpretation;
- extracted claim from an external source.

An observation may support, weaken, refine, or contradict a knowledge unit.

## Outcome

An outcome records what changed after an action or session.

Useful outcomes may be quantitative, qualitative, or both:

- floor space freed;
- number of items removed;
- time spent;
- number of unresolved decisions;
- user-reported stress or confidence;
- whether the room became usable;
- whether the same problem returned later.

Do not invent precision when the data is approximate.

## Source

A source records provenance for external claims. A source can be a book, article, study, professional guide, community discussion, video, interview, or another stable artifact.

Sources do not automatically make a claim true. They establish where a claim came from and allow later comparison.

## Gap

A gap is an explicit statement that the system does not yet know enough.

Examples:

- guidance exists but has not been tested under severe space constraints;
- two strategies conflict and context does not yet explain why;
- a repeated user question has no reusable knowledge unit;
- a principle sounds plausible but lacks real-world support.

A gap is a healthy system state. Organized should prefer an explicit unknown over false certainty.

## Conflict

A conflict preserves disagreement instead of flattening it into a single answer.

A conflict should record:

- the competing claims or strategies;
- their sources or supporting observations;
- contexts in which each appears to work;
- unresolved questions;
- current resolution status.

The goal is often not to declare one side universally correct, but to identify the contextual boundary between them.

## Promotion

Not every observation becomes knowledge.

A candidate earns promotion when explicit representation improves one or more of:

- consistency;
- transfer between cases;
- decision quality;
- evidence tracking;
- explanation of trade-offs;
- detection of exceptions;
- future learning.

Promotion should preserve provenance. A principle derived from three observations and one expert source should remain traceable to them.

## Publication

Published content is a projection, not the source of truth.

```text
knowledge + case + audience + intent + channel
                     ↓
     blog / YouTube / TikTok / Threads /
     Instagram / landing page / app / API
```

Operational records such as sessions and observations may remain language-neutral. Reusable human-facing knowledge should expose stable localization keys and maintain English and Ukrainian copy.